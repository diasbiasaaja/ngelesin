import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/custom_navbar.dart';

import 'guru_home_content.dart';
import '../jadwal/jadwal_page.dart';
import '../../chat/chat_list.dart';
import '../materi/MateriPage.dart';
import '../profile/profile_page.dart';

// ================= THEME =================
const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class HomeGuruPage extends StatefulWidget {
  const HomeGuruPage({super.key});

  @override
  State<HomeGuruPage> createState() => _HomeGuruPageState();
}

class _HomeGuruPageState extends State<HomeGuruPage> {
  int selectedIndex = 0;

  String? namaGuru;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGuru();
  }

  // ================= LOAD DATA GURU =================
  Future<void> _loadGuru() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('guru')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      setState(() {
        namaGuru = doc['nama'];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      GuruHomeContent(namaGuru: namaGuru!), // 🔥 KIRIM NAMA GURU
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

      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
    );
  }
}
