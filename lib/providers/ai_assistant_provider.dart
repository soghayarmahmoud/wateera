import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wateera/models/ai_message_model.dart';

class AiAssistantProvider extends ChangeNotifier {
  final List<AiMessage> _messages = [];
  bool _isLoading = false;

  List<AiMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> sendMessage(String text) async {
    _messages.add(AiMessage(text: text, isMe: true));
    _isLoading = true;
    notifyListeners();

    try {
      final apiKey = "AIzaSyAxeEDPI_o9M24XA5nblfqXtSfix0C01nQ";
     

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
        final generatedText = data['candidates'][0]['content']['parts'][0]['text'];
        _messages.add(AiMessage(text: generatedText, isMe: false));
      } else {
        _messages.add(AiMessage(text: 'Error: ${response.reasonPhrase}', isMe: false));
      }
    } catch (e) {
      _messages.add(AiMessage(text: 'Error: $e', isMe: false));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
