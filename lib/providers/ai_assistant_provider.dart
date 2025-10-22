// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wateera/models/ai_message_model.dart';
import 'package:wateera/models/goal_model.dart';
import 'package:wateera/models/note_model.dart';
import 'package:wateera/models/task_model.dart';
import 'package:wateera/providers/goal_provider.dart';
import 'package:wateera/providers/note_provider.dart';
import 'package:wateera/providers/task_provider.dart';
import 'package:uuid/uuid.dart';

class AiAssistantProvider extends ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();
  late final GenerativeModel _model;

  // الـ Providers اللي هنحتاجها
  final TaskProvider _taskProvider;
  final NoteProvider _noteProvider;
  final GoalProvider _goalProvider;

  // Constructor لاستقبال الـ Providers
  AiAssistantProvider(
    this._taskProvider,
    this._noteProvider,
    this._goalProvider,
  ) {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: apiKey);
  }

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    _messages.add(AiMessage(text: text, isMe: true));
    notifyListeners();

    // First try to handle as a direct command
    if (await _handleCommand(text)) {
      return;
    }

    // If not a direct command, use AI to interpret and potentially execute
    _isLoading = true;
    notifyListeners();

    try {
      // Enhanced prompt for better AI understanding
      final enhancedPrompt =
          '''
You are a productivity assistant for the Wateera app. You can help users create tasks, notes, and goals through natural language.

User request: "$text"

If the user wants to:
1. Create a task: Respond with "TASK_CREATE:" followed by JSON format: {"title": "task title", "date": "YYYY-MM-DD", "startTime": "HH:MM", "endTime": "HH:MM"}
2. Create a note: Respond with "NOTE_CREATE:" followed by JSON format: {"title": "note title", "content": "note content"}
3. Create a goal: Respond with "GOAL_CREATE:" followed by JSON format: {"title": "goal title", "endTime": "YYYY-MM-DD", "description": "optional description", "priority": "low|medium|high"}

If the request is not about creating tasks, notes, or goals, respond naturally as a helpful assistant.

Examples:
- "Create a task to buy groceries tomorrow at 2 PM to 3 PM" → TASK_CREATE:{"title": "Buy groceries", "date": "2024-10-23", "startTime": "14:00", "endTime": "15:00"}
- "Add a note about meeting with John" → NOTE_CREATE:{"title": "Meeting with John", "content": "Meeting with John"}
- "Set a goal to finish the project by next Friday" → GOAL_CREATE:{"title": "Finish the project", "endTime": "2024-10-25", "description": "Complete project work", "priority": "high"}
''';

      final content = [Content.text(enhancedPrompt)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        final aiResponse = response.text!;

        // Check if AI wants to create something
        if (await _handleAIResponse(aiResponse)) {
          return;
        }

        // Otherwise, show the AI response
        _messages.add(AiMessage(text: aiResponse, isMe: false));
      } else {
        _messages.add(
          AiMessage(text: 'Error: No response from AI', isMe: false),
        );
      }
    } on GenerativeAIException catch (e) {
      _messages.add(
        AiMessage(text: 'Error from AI service: ${e.message}', isMe: false),
      );
    } catch (e) {
      _messages.add(AiMessage(text: 'Error: $e', isMe: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تم حذف الـ context من هنا
  Future<bool> _handleCommand(String text) async {
    if (text.startsWith('add task:')) {
      try {
        final parts = text.substring('add task:'.length).trim().split(',');
        if (parts.length == 4) {
          final title = parts[0].trim();
          final date = DateTime.parse(parts[1].trim());
          final startTime = parts[2].trim();
          final endTime = parts[3].trim();
          final task = Task(
            id: _uuid.v4(),
            title: title,
            date: date,
            startTime: startTime,
            endTime: endTime,
          );
          //  ===== الجزء اللي تم تعديله (استخدام الـ Provider المحقون) =====
          _taskProvider.addTask(task);
          _messages.add(
            AiMessage(text: 'Task "$title" added successfully.', isMe: false),
          );
          notifyListeners();
          return true;
        } else {
          _messages.add(
            AiMessage(
              text:
                  'Invalid format. Use: add task: <title>, <YYYY-MM-DD>, <HH:MM>, <HH:MM>',
              isMe: false,
            ),
          );
          notifyListeners();
          return true;
        }
      } catch (e) {
        _messages.add(AiMessage(text: 'Error adding task: $e', isMe: false));
        notifyListeners();
        return true;
      }
    } else if (text.startsWith('add note:')) {
      try {
        final content = text.substring('add note:'.length).trim();
        final title = content.substring(
          0,
          content.length > 20 ? 20 : content.length,
        );
        final note = Note(
          id: _uuid.v4(),
          title: title,
          content: content,
          createdAt: DateTime.now(),
        );
        //  ===== الجزء اللي تم تعديله (استخدام الـ Provider المحقون) =====
        _noteProvider.addNote(note);
        _messages.add(AiMessage(text: 'Note added successfully.', isMe: false));
        notifyListeners();
        return true;
      } catch (e) {
        _messages.add(AiMessage(text: 'Error adding note: $e', isMe: false));
        notifyListeners();
        return true;
      }
    } else if (text.startsWith('add goal:')) {
      try {
        final parts = text.substring('add goal:'.length).trim().split(',');
        if (parts.length == 2) {
          final title = parts[0].trim();
          final endTime = DateTime.parse(parts[1].trim());
          //  ===== الجزء اللي تم تعديله (استخدام الـ Provider المحقون) =====
          _goalProvider.addGoal(title, endTime);
          _messages.add(
            AiMessage(text: 'Goal "$title" added successfully.', isMe: false),
          );
          notifyListeners();
          return true;
        } else {
          _messages.add(
            AiMessage(
              text: 'Invalid format. Use: add goal: <title>, <YYYY-MM-DD>',
              isMe: false,
            ),
          );
          notifyListeners();
          return true;
        }
      } catch (e) {
        _messages.add(AiMessage(text: 'Error adding goal: $e', isMe: false));
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  // Handle AI-generated responses for creating tasks, notes, and goals
  Future<bool> _handleAIResponse(String aiResponse) async {
    try {
      if (aiResponse.startsWith('TASK_CREATE:')) {
        final jsonStr = aiResponse.substring('TASK_CREATE:'.length).trim();
        final data = jsonDecode(jsonStr);

        final task = Task(
          id: _uuid.v4(),
          title: data['title'],
          date: DateTime.parse(data['date']),
          startTime: data['startTime'],
          endTime: data['endTime'],
        );

        await _taskProvider.addTask(task);
        _messages.add(
          AiMessage(
            text: '✅ Task "${task.title}" created successfully!',
            isMe: false,
          ),
        );
        notifyListeners();
        return true;
      } else if (aiResponse.startsWith('NOTE_CREATE:')) {
        final jsonStr = aiResponse.substring('NOTE_CREATE:'.length).trim();
        final data = jsonDecode(jsonStr);

        final note = Note(
          id: _uuid.v4(),
          title: data['title'],
          content: data['content'],
          createdAt: DateTime.now(),
        );

        await _noteProvider.addNote(note);
        _messages.add(
          AiMessage(
            text: '📝 Note "${note.title}" created successfully!',
            isMe: false,
          ),
        );
        notifyListeners();
        return true;
      } else if (aiResponse.startsWith('GOAL_CREATE:')) {
        final jsonStr = aiResponse.substring('GOAL_CREATE:'.length).trim();
        final data = jsonDecode(jsonStr);

        // Parse priority
        GoalPriority priority = GoalPriority.medium;
        if (data['priority'] != null) {
          switch (data['priority'].toLowerCase()) {
            case 'low':
              priority = GoalPriority.low;
              break;
            case 'high':
              priority = GoalPriority.high;
              break;
            default:
              priority = GoalPriority.medium;
          }
        }

        await _goalProvider.addGoal(
          data['title'],
          DateTime.parse(data['endTime']),
          description: data['description'] ?? '',
          priority: priority,
        );

        _messages.add(
          AiMessage(
            text: '🎯 Goal "${data['title']}" created successfully!',
            isMe: false,
          ),
        );
        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      _messages.add(
        AiMessage(text: 'Error processing AI response: $e', isMe: false),
      );
      notifyListeners();
      return true;
    }
  }
}
