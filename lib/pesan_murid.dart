import 'package:flutter/material.dart';
import '../chat/chat_page.dart';
import '../theme/chat_theme.dart';

final muridChatTheme = ChatTheme(
  appBarColor: Colors.green,
  guruBubble: Colors.blueGrey,
  muridBubble: Colors.greenAccent,
  inputBarColor: Colors.white,
  sendButtonColor: Colors.green,
);

class PesanMuridPage extends StatelessWidget {
  const PesanMuridPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatPage(title: "Guru Matematika", theme: muridChatTheme);
  }
}
