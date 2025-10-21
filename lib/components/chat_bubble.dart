import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/w.png'),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.bottomRight,
                  child: IconButton(
                    icon: Icon(Icons.copy, size: 16, color: isMe ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Copied to clipboard')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isMe)
          const CircleAvatar(
            backgroundImage: AssetImage('assets/images/user.jpg'),
          ),
      ],
    );
  }
}
