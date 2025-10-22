// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wateera/models/ai_message_model.dart';
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
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    _messages.add(AiMessage(text: text, isMe: true));
    notifyListeners();

    // تم حذف الـ context من هنا
    if (await _handleCommand(text)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Use the GenerativeModel to generate content
      final content = [Content.text(text)];
      final response = await _model.generateContent(content);

      if (response.text != null) {
        _messages.add(AiMessage(text: response.text!, isMe: false));
      } else if (response.candidates != null &&
          response.candidates.isNotEmpty) {
        final candidate = response.candidates![0];
        if (candidate.finishReason != null) {
          _messages.add(
            AiMessage(
              text:
                  'AI response was blocked or empty (Reason: ${candidate.finishReason})',
              isMe: false,
            ),
          );
        } else {
          _messages.add(
            AiMessage(
              text: 'Error: No text content in AI response.',
              isMe: false,
            ),
          );
        }
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
}
