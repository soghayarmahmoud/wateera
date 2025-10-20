import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wateera/components/chat_bubble.dart';
import 'package:wateera/components/message_input_field.dart';
import 'package:wateera/providers/ai_assistant_provider.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('AI Assistant'),
      ),
      body: Stack(
        children: [
          Consumer<AiAssistantProvider>(
            builder: (context, provider, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
              return ListView.builder(
                controller: _scrollController,
                itemCount: provider.messages.length,
                padding: EdgeInsets.only(bottom: 80 + keyboardHeight),
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
          Positioned(
            bottom: keyboardHeight,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (context.watch<AiAssistantProvider>().isLoading)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                MessageInputField(
                  onSend: (message) {
                    Provider.of<AiAssistantProvider>(context, listen: false)
                        .sendMessage(context, message);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
