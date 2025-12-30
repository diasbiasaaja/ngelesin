import 'package:flutter/material.dart';
import '../theme/chat_theme.dart';
import 'chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final ChatTheme theme;

  const ChatPage({super.key, required this.title, required this.theme});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: widget.theme.appBarColor,
        elevation: 0,
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= BODY =================
      body: Column(
        children: [
          // ===== CHAT LIST =====
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                ChatBubble(
                  text: "Halo, saya ingin tanya jadwal les",
                  isGuru: false,
                  theme: widget.theme,
                ),
                ChatBubble(
                  text: "Halo, silakan. Jadwal kapan?",
                  isGuru: true,
                  theme: widget.theme,
                ),
              ],
            ),
          ),

          // ===== INPUT (WA STYLE) =====
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: widget.theme.inputBarColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Tulis pesan...",
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: _scrollToBottom,
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: widget.theme.sendButtonColor,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        _textController.clear();
                        _scrollToBottom();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
