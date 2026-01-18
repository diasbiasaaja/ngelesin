import 'package:flutter/material.dart';

class ChatListItem extends StatelessWidget {
  final String nama;
  final String pesan;
  final VoidCallback onTap;

  /// ✅ dot unread
  final bool showUnreadDot;

  const ChatListItem({
    super.key,
    required this.nama,
    required this.pesan,
    required this.onTap,
    this.showUnreadDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.deepPurple.shade100,
              child: const Icon(Icons.person, color: Colors.deepPurple),
            ),
            const SizedBox(width: 12),

            // text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pesan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // ✅ UNREAD DOT
            if (showUnreadDot)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
