import 'package:flutter/material.dart';
import '../chat/chat_page.dart';
import '../theme/chat_theme.dart';

final guruChatTheme = ChatTheme(
  appBarColor: const Color(0xff22345C),
  guruBubble: const Color(0xff22345C),
  muridBubble: const Color(0xffE5E9F2),
  inputBarColor: const Color(0xffF5F7FA),
  sendButtonColor: const Color(0xff22345C),
);

class PesanGuruPage extends StatelessWidget {
  const PesanGuruPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChatPage(title: "Rudi SD", theme: guruChatTheme);
  }
}
