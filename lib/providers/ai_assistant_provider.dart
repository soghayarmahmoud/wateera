import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
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

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(BuildContext context, String text) async {
    _messages.add(AiMessage(text: text, isMe: true));
    notifyListeners();

    if (await _handleCommand(context, text)) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null) {
        throw Exception('GEMINI_API_KEY not found in .env file');
      }

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': text}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
          _messages.add(AiMessage(text: generatedText, isMe: false));
        } else {
          _messages.add(AiMessage(text: 'Error: No response from AI', isMe: false));
        }
      } else {
        _messages.add(AiMessage(text: 'Error: ${response.reasonPhrase}\n${response.body}', isMe: false));
      }
    } catch (e) {
      _messages.add(AiMessage(text: 'Error: $e', isMe: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _handleCommand(BuildContext context, String text) async {
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
          Provider.of<TaskProvider>(context, listen: false).addTask(task);
          _messages.add(AiMessage(text: 'Task "$title" added successfully.', isMe: false));
          notifyListeners();
          return true;
        } else {
          _messages.add(AiMessage(text: 'Invalid format. Use: add task: <title>, <YYYY-MM-DD>, <HH:MM>, <HH:MM>', isMe: false));
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
        final title = content.substring(0, content.length > 20 ? 20 : content.length);
        final note = Note(
          id: _uuid.v4(),
          title: title,
          content: content,
          createdAt: DateTime.now(),
        );
        Provider.of<NoteProvider>(context, listen: false).addNote(note);
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
          Provider.of<GoalProvider>(context, listen: false).addGoal(title, endTime);
          _messages.add(AiMessage(text: 'Goal "$title" added successfully.', isMe: false));
          notifyListeners();
          return true;
        } else {
          _messages.add(AiMessage(text: 'Invalid format. Use: add goal: <title>, <YYYY-MM-DD>', isMe: false));
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