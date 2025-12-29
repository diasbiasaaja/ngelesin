import 'package:flutter/material.dart';
import 'chat_page.dart';
import 'widgets/chat_list_item.dart';
import '../theme/chat_theme.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,

          elevation: 0,
          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Chat",
                    style: TextStyle(
                      color: Color.fromARGB(255, 10, 10, 10),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // GARIS KUNING
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ChatListItem(
            nama: "Rudi SD",
            pesan: "Halo, silakan. Jadwal kapan?",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatPage(title: "Rudi SD", theme: chatThemeDefault),
                ),
              );
            },
          ),
          ChatListItem(
            nama: "Bu Rina",
            pesan: "Bisa hari Sabtu ya",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatPage(title: "Bu Rina", theme: chatThemeDefault),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
