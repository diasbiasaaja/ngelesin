import 'package:flutter/material.dart';

class ChatUserTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  final bool hasUnread;

  const ChatUserTile({
    super.key,
    required this.name,
    required this.onTap,
    this.hasUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xff22345C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Color(0xff22345C)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name, style: const TextStyle(color: Colors.white)),
            ),
            if (hasUnread)
              const CircleAvatar(radius: 6, backgroundColor: Colors.yellow),
          ],
        ),
      ),
    );
  }
}
