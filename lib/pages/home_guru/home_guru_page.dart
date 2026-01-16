import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/custom_navbar.dart';
import 'guru_home_content.dart';
import '../jadwal/jadwal_page.dart';
import '../../chat/chat_list.dart';
import '../materi/MateriPage.dart';
import '../profile/profile_page.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class HomeGuruPage extends StatefulWidget {
  const HomeGuruPage({super.key});

  @override
  State<HomeGuruPage> createState() => _HomeGuruPageState();
}

class _HomeGuruPageState extends State<HomeGuruPage> {
  int selectedIndex = 0;

  String namaGuru = "Guru"; // ✅ fallback biar ga blank
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  Future<void> _loadGuru() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // ✅ kalau ga login jangan ngegantung
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('guru')
          .doc(user.uid)
          .get();

      // ✅ kalau doc ga ada jangan ngegantung
      if (!doc.exists) {
        setState(() => isLoading = false);
        return;
      }

      setState(() {
        namaGuru = (doc.data()?['nama'] ?? "Guru").toString();
        isLoading = false;
      });
    } catch (e) {
      // ✅ kalau error jangan ngegantung
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final pages = [
      GuruHomeContent(namaGuru: namaGuru),
      const JadwalPage(),
      const ChatListPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowAcc,
        elevation: 10,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MateriPage()),
          );
        },
        child: const Icon(
          Icons.menu_book_rounded,
          size: 30,
          color: Colors.black,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomNavbar(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
      ),

      body: IndexedStack(index: selectedIndex, children: pages),
    );
  }
}
