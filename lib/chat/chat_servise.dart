import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  static final _fs = FirebaseFirestore.instance;

  /// ✅ chatId 1 room per pasangan uid (murid-guru)
  static String chatId(String uidA, String uidB) {
    final list = [uidA, uidB]..sort();
    return "${list[0]}_${list[1]}";
  }

  /// ✅ create chat doc kalau belum ada
  static Future<void> ensureChat({
    required String muridUid,
    required String guruUid,
  }) async {
    final id = chatId(muridUid, guruUid);
    final ref = _fs.collection("chats").doc(id);

    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      "muridUid": muridUid,
      "guruUid": guruUid,
      "members": [muridUid, guruUid],
      "lastMessage": "",
      "lastTime": FieldValue.serverTimestamp(),
      "createdAt": FieldValue.serverTimestamp(),

      // ✅ unread per user
      "unread": {muridUid: 0, guruUid: 0},
    });
  }

  /// ✅ kirim pesan
  static Future<void> sendMessage({
    required String muridUid,
    required String guruUid,
    required String senderId,
    required String text,
  }) async {
    final id = chatId(muridUid, guruUid);
    final chatRef = _fs.collection("chats").doc(id);

    await ensureChat(muridUid: muridUid, guruUid: guruUid);

    final receiverId = (senderId == muridUid) ? guruUid : muridUid;

    // 1) simpan message
    final msgRef = chatRef.collection("messages").doc();
    await msgRef.set({
      "senderId": senderId,
      "text": text,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 2) update chat meta + unread receiver
    await chatRef.set({
      "lastMessage": text,
      "lastTime": FieldValue.serverTimestamp(),
      "members": [muridUid, guruUid],
      "muridUid": muridUid,
      "guruUid": guruUid,

      "unread": {muridUid: 0, guruUid: 0},
    }, SetOptions(merge: true));

    await chatRef.update({"unread.$receiverId": FieldValue.increment(1)});
  }

  /// ✅ mark as read
  static Future<void> markAsRead({
    required String muridUid,
    required String guruUid,
    required String readerUid,
  }) async {
    final id = chatId(muridUid, guruUid);
    final chatRef = _fs.collection("chats").doc(id);

    await chatRef.set({
      "unread": {readerUid: 0},
    }, SetOptions(merge: true));
  }

  /// ✅ stream messages
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamMessages({
    required String muridUid,
    required String guruUid,
  }) {
    final id = chatId(muridUid, guruUid);
    return _fs
        .collection("chats")
        .doc(id)
        .collection("messages")
        .orderBy("createdAt", descending: false)
        .snapshots();
  }

  /// ✅ stream chat list untuk user login
  static Stream<QuerySnapshot<Map<String, dynamic>>> streamChatsForUser(
    String uid,
  ) {
    return _fs
        .collection("chats")
        .where("members", arrayContains: uid)
        .snapshots();
  }
}
