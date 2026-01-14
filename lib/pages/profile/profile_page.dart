import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page_guru.dart';
import 'edit_addres_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  /// mengambil stream data guru berdasarkan uid login
  Stream<DocumentSnapshot<Map<String, dynamic>>> _guruStream() {
    final uid = _auth.currentUser?.uid;
    return _firestore.collection("guru").doc(uid).snapshots();
  }

  /// logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pop(context); // balik
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PROFIL"), centerTitle: true),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _guruStream(),
        builder: (context, snapshot) {
          // loading (tampilan tetap, hanya nunggu data)
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

          // kalau belum login / data tidak ada
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Column(
              children: [
                const SizedBox(height: 24),
                const CircleAvatar(radius: 40),
                const SizedBox(height: 12),
                const Text("Data guru tidak ditemukan"),
                const SizedBox(height: 32),
                _menu(
                  context,
                  "Data Pribadi",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),
                _menu(
                  context,
                  "Alamat",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditAddressPage()),
                  ),
                ),
                _menu(context, "Keluar", _logout),
              ],
            );
          }

          final data = snapshot.data!.data()!;

          // field dari Firestore (sesuai register guru kamu)
          final String nama = (data["nama"] ?? "-").toString();

          /// foto profile: karena data guru belum ada foto,
          /// kita tampilkan icon default (TIDAK merubah UI, tetap CircleAvatar)
          /// kalau nanti kamu punya field foto_url, tinggal ganti bagian ini.
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

              Text(nama, style: const TextStyle(fontWeight: FontWeight.bold)),

              const SizedBox(height: 32),

              _menu(
                context,
                "Data Pribadi",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                ),
              ),

              _menu(
                context,
                "Alamat",
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditAddressPage()),
                ),
              ),

              _menu(context, "Keluar", _logout),
            ],
          );
        },
      ),
    );
  }

  Widget _menu(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
