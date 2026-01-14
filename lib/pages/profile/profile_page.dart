import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';
import 'edit_addres_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String collectionName = "guru";
  bool roleLoaded = false;

  @override
  void initState() {
    super.initState();
    _detectRole();
  }

  Future<void> _detectRole() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final guruDoc = await _firestore.collection("guru").doc(uid).get();
      if (guruDoc.exists) {
        setState(() {
          collectionName = "guru";
          roleLoaded = true;
        });
        return;
      }

      final muridDoc = await _firestore.collection("murid").doc(uid).get();
      if (muridDoc.exists) {
        setState(() {
          collectionName = "murid";
          roleLoaded = true;
        });
        return;
      }

      setState(() => roleLoaded = true);
    } catch (e) {
      setState(() => roleLoaded = true);
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> _userStream() {
    final uid = _auth.currentUser?.uid;
    return _firestore.collection(collectionName).doc(uid).snapshots();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PROFIL"), centerTitle: true),
      body: !roleLoaded
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _userStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: const [
                      SizedBox(height: 24),
                      CircleAvatar(radius: 40),
                      SizedBox(height: 12),
                      CircularProgressIndicator(),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      const CircleAvatar(radius: 40),
                      const SizedBox(height: 12),
                      const Text("Data user tidak ditemukan"),
                      const SizedBox(height: 32),
                      _menu(
                        context,
                        "Data Pribadi",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ),
                      ),
                      _menu(
                        context,
                        "Alamat",
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditAddressPage(),
                          ),
                        ),
                      ),
                      _menu(context, "Keluar", _logout),
                    ],
                  );
                }

                final data = snapshot.data!.data()!;
                final String nama = (data["nama"] ?? "-").toString();

                // optional foto kalau ada
                final String? fotoUrl = data["foto_url"];

                return Column(
                  children: [
                    const SizedBox(height: 24),

                    CircleAvatar(
                      radius: 40,
                      backgroundImage: (fotoUrl != null && fotoUrl.isNotEmpty)
                          ? NetworkImage(fotoUrl)
                          : null,
                      child: (fotoUrl == null || fotoUrl.isEmpty)
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      nama,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 32),

                    _menu(
                      context,
                      "Data Pribadi",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      ),
                    ),

                    _menu(
                      context,
                      "Alamat",
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditAddressPage(),
                        ),
                      ),
                    ),

                    _menu(context, "Keluar", _logout),
                  ],
                );
              },
            ),
    );
  }

  static Widget _menu(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
