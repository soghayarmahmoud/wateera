import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/chat_bubble.dart';
import 'package:wateera/components/message_input_field.dart';
import 'package:wateera/providers/ai_assistant_provider.dart';

class AiAssistantScreen extends StatelessWidget {
  const AiAssistantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<AiAssistantProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  reverse: true,
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return ChatBubble(
                      message: message.text,
                      isMe: message.isMe,
                    );
                  },
                );
              },
            ),
          ),
          if (context.watch<AiAssistantProvider>().isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          MessageInputField(
            onSend: (message) {
              Provider.of<AiAssistantProvider>(context, listen: false).sendMessage(message);
            },
          ),
        ],
      ),
    );
  }
}