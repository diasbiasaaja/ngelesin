import 'package:flutter/material.dart';
import '../theme/chat_theme.dart';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool isGuru;
  final ChatTheme theme;

  const ChatBubble({
    super.key,
    required this.text,
    required this.isGuru,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isGuru ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: isGuru ? theme.guruBubbleColor : theme.muridBubbleColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isGuru ? theme.guruTextColor : theme.muridTextColor,
          ),
        ),
      ),
    );
  }
}
