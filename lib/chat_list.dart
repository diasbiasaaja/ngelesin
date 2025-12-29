import 'package:flutter/material.dart';
import '../chat/chat_user.dart';
import 'pesan_guru.dart';

// warna tema
const yellowAcc = Color(0xFFFFC947);

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== TITLE =====
            const Text(
              "CHAT",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            // ===== GARIS KUNING =====
            Container(
              width: 480,
              height: 4,
              decoration: BoxDecoration(
                color: yellowAcc,
                borderRadius: BorderRadius.circular(8),
              ),
            ),

            const SizedBox(height: 16),

            // ===== LIST CHAT =====
            ChatUserTile(
              name: "Rudi SD",
              hasUnread: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PesanGuruPage()),
                );
              },
            ),

            const SizedBox(height: 12),

            ChatUserTile(name: "Bayu SD", onTap: () {}),
          ],
        ),
      ),
    );
  }
}
