import 'package:flutter/material.dart';
import 'widgets/custom_navbar.dart';

import 'guru_home_content.dart';
import '../../jadwal_page.dart';
import '../../chat_list.dart';
import '../../MateriPage.dart';

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

  final pages = const [
    GuruHomeContent(),
    JadwalPage(),
    ChatListPage(),
    Center(child: Text("Profil (placeholder)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowAcc,
        elevation: 10,

        // 🔑 INI YANG NGUNCI BULAT SEMPURNA
        shape: const CircleBorder(),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MateriPage()),
          );
        },
        child: const Icon(
          Icons.menu_book_rounded, // 📘 icon buku
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
