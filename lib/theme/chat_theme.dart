import 'package:flutter/material.dart';

class ChatTheme {
  final Color appBarColor;
  final Color guruBubbleColor;
  final Color muridBubbleColor;
  final Color guruTextColor;
  final Color muridTextColor;
  final Color inputBarColor;
  final Color sendButtonColor;

  const ChatTheme({
    required this.appBarColor,
    required this.guruBubbleColor,
    required this.muridBubbleColor,
    required this.guruTextColor,
    required this.muridTextColor,
    required this.inputBarColor,
    required this.sendButtonColor,
  });
}

// 🔥 THEME FIXED (AMAN & KONTRAS)
const chatThemeDefault = ChatTheme(
  appBarColor: Color(0xFF1E2F5C), // navy
  guruBubbleColor: Color(0xFF1E2F5C), // navy
  muridBubbleColor: Color(0xFFF1F2F6), // abu muda
  guruTextColor: Colors.white,
  muridTextColor: Colors.black87,
  inputBarColor: Colors.white,
  sendButtonColor: Color(0xFF1E2F5C),
);
