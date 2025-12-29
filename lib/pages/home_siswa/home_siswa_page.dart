import 'package:flutter/material.dart';
import 'home_siswa_content.dart';
import 'widgets/custum_navbarsiswa.dart';
import '../../chat_list.dart';
import '../../map_shell.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class HomeSiswaPage extends StatefulWidget {
  const HomeSiswaPage({super.key});

  @override
  State<HomeSiswaPage> createState() => _HomeSiswaPageState();
}

class _HomeSiswaPageState extends State<HomeSiswaPage> {
  int selectedIndex = 0;

  final pages = const [
    HomeSiswaContent(),
    Center(child: Text("Materi")),
    ChatListPage(),
    Center(child: Text("Profil")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      floatingActionButton: FloatingActionButton(
        backgroundColor: yellowAcc,
        shape: const CircleBorder(), // 🔥 bulat sempurna
        onPressed: () => showMapShell(context),
        child: const Icon(Icons.map_rounded, color: Colors.black),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: CustomNavbarsiswa(
        currentIndex: selectedIndex,
        onTap: (i) => setState(() => selectedIndex = i),
      ),

      body: IndexedStack(index: selectedIndex, children: pages),
    );
  }
}
