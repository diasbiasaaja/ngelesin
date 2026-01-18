import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/chat_theme.dart';
import 'chat_bubble.dart';
import 'chat_servise.dart';

class ChatPage extends StatefulWidget {
  final String title;
  final ChatTheme theme;

  final String muridUid;
  final String guruUid;

  const ChatPage({
    super.key,
    required this.title,
    required this.theme,
    required this.muridUid,
    required this.guruUid,
  });

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

    // ✅ reset unread pas masuk
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      ChatService.markAsRead(
        muridUid: widget.muridUid,
        guruUid: widget.guruUid,
        readerUid: uid,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Silakan login")));
    }

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

      body: Column(
        children: [
          // ===== CHAT LIST realtime =====
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: ChatService.streamMessages(
                muridUid: widget.muridUid,
                guruUid: widget.guruUid,
              ),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text("Belum ada pesan"));
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  children: docs.map((d) {
                    final data = d.data();
                    final senderId = (data["senderId"] ?? "").toString();
                    final text = (data["text"] ?? "").toString();

                    final isGuru = senderId == widget.guruUid;

                    return ChatBubble(
                      text: text,
                      isGuru: isGuru,
                      theme: widget.theme,
                    );
                  }).toList(),
                );
              },
            ),
          ),

          // ===== INPUT =====
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
                      onPressed: () async {
                        final text = _textController.text.trim();
                        if (text.isEmpty) return;

                        _textController.clear();

                        await ChatService.sendMessage(
                          muridUid: widget.muridUid,
                          guruUid: widget.guruUid,
                          senderId: uid,
                          text: text,
                        );

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
