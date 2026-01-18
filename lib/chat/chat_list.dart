import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/chat_theme.dart';
import 'chat_page.dart';
import 'chat_servise.dart';
import 'widgets/chat_list_item.dart';

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text("Silakan login")));
    }

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

      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ChatService.streamChatsForUser(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final docs = snap.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada chat"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((d) {
              final data = d.data();

              final muridUid = (data["muridUid"] ?? "").toString();
              final guruUid = (data["guruUid"] ?? "").toString();
              final lastMessage = (data["lastMessage"] ?? "").toString();

              // ✅ unread count untuk user login
              int unreadCount = 0;
              final unread = data["unread"];
              if (unread is Map) {
                final v = unread[uid];
                if (v is int) unreadCount = v;
                if (v is num) unreadCount = v.toInt();
              }
              final showDot = unreadCount > 0;

              // ✅ lawan chat uid
              final otherUid = uid == muridUid ? guruUid : muridUid;

              return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection(uid == muridUid ? "guru" : "murid")
                    .doc(otherUid)
                    .get(),
                builder: (context, userSnap) {
                  String nama = otherUid;
                  if (userSnap.hasData && userSnap.data!.exists) {
                    nama = (userSnap.data!.data()?["nama"] ?? otherUid)
                        .toString();
                  }

                  return ChatListItem(
                    nama: nama,
                    pesan: lastMessage.isEmpty
                        ? "(Belum ada pesan)"
                        : lastMessage,
                    showUnreadDot: showDot,
                    onTap: () async {
                      // ✅ reset unread
                      await ChatService.markAsRead(
                        muridUid: muridUid,
                        guruUid: guruUid,
                        readerUid: uid,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            title: nama,
                            theme: chatThemeDefault,
                            muridUid: muridUid,
                            guruUid: guruUid,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
