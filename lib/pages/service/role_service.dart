import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  static Future<String?> getRole() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final guruDoc = await FirebaseFirestore.instance
        .collection("guru")
        .doc(uid)
        .get();
    if (guruDoc.exists) return "guru";

    final siswaDoc = await FirebaseFirestore.instance
        .collection("siswa")
        .doc(uid)
        .get();
    if (siswaDoc.exists) return "siswa";

    return null;
  }
}
