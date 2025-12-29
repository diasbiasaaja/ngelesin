// lib/home_siswa.dart
import 'package:flutter/material.dart';
import 'map_shell.dart';
import 'chat_list.dart';

// -----------------------
// Theme colors (konstan dipakai di beberapa tempat)
const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

// -----------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  // placeholder pages — ganti dengan page nyata nanti
  final List<Widget> pages = [
    const HomeContent(), // index 0 -> content yang kamu punya
    const Center(child: Text("Materi (placeholder)")),
    ChatListPage(),
    const Center(child: Text("Profil (placeholder)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // biar FAB notch rapi
      resizeToAvoidBottomInset:
          false, // hindari layout shift ketika keyboard muncul
      backgroundColor: Colors.white,

      // FAB (kotak kuning sesuai permintaan)
      floatingActionButton: Container(
        height: 62,
        width: 62,
        decoration: BoxDecoration(
          color: yellowAcc,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => showMapShell(context),
          icon: const Icon(Icons.map_rounded, color: Colors.white, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Bottom navbar (terima currentIndex & onTap agar kontrol berada di parent)
      bottomNavigationBar: CustomNavbar(
        currentIndex: selectedIndex,
        onTap: (idx) => setState(() => selectedIndex = idx),
      ),

      // Body: gunakan IndexedStack supaya tiap tab menyimpan state
      body: IndexedStack(index: selectedIndex, children: pages),
    );
  }
}

/// ------------------
/// HOME CONTENT (dipisah agar clean)
/// ------------------
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    // paddingBottom memastikan konten tidak tertutup Navbar + FAB + safe area
    final double bottomPadding =
        MediaQuery.of(context).viewPadding.bottom +
        kBottomNavigationBarHeight +
        80;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            // Header premium
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A2A43), Color(0xFF1B3B5A)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius:
                        34, // 🔥 dari 28 → 34 biar lebih besar dan proporsional
                    backgroundColor: Colors.white,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        "assets/images/logo.png",
                        width: 55,
                        height: 55,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Collage Private",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Privat belajar yang lebih elegan",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Halo, Murid 👋",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // thin yellow accent line
            Container(height: 4, color: yellowAcc),

            const SizedBox(height: 20),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 8),
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: navy.withOpacity(0.5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Cari materi atau guru...",
                        style: TextStyle(color: navy.withOpacity(0.5)),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: navy.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        size: 20,
                        color: navy.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cards (lebih lengkap sesuai kurikulum)
            TingkatanCard(
              title: "SD",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.flag_circle_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_soccer_rounded, "name": "PJOK"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
              ],
            ),

            TingkatanCard(
              title: "SMP",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_basketball_rounded, "name": "PJOK"},
                {"icon": Icons.brush_rounded, "name": "Seni Budaya"},
                {"icon": Icons.handyman_rounded, "name": "Prakarya"},
              ],
            ),

            TingkatanCard(
              title: "SMA",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.history_edu_rounded, "name": "Sejarah"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "Agama"},
                // IPA
                {"icon": Icons.science_rounded, "name": "Fisika"},
                {"icon": Icons.bubble_chart_rounded, "name": "Kimia"},
                {"icon": Icons.biotech_rounded, "name": "Biologi"},
                // IPS
                {"icon": Icons.public_rounded, "name": "Geografi"},
                {"icon": Icons.groups_rounded, "name": "Sosiologi"},
                {"icon": Icons.attach_money_rounded, "name": "Ekonomi"},
                // Tambahan
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.sports_martial_arts_rounded, "name": "PJOK"},
              ],
            ),

            // small spacer (sudah ada bottom padding) — tidak perlu terlalu besar
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// TingkatanCard (refined look)
class TingkatanCard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> subjects;

  const TingkatanCard({super.key, required this.title, required this.subjects});

  @override
  State<TingkatanCard> createState() => _TingkatanCardState();
}

class _TingkatanCardState extends State<TingkatanCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    // compute visible subjects & full title before building widgets
    final visible = expanded
        ? widget.subjects
        : widget.subjects.take(3).toList();

    final fullTitle =
        {
          "SD": "Sekolah Dasar",
          "SMP": "Sekolah Menengah Pertama",
          "SMA": "Sekolah Menengah Atas",
        }[widget.title] ??
        widget.title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TITLE + GARIS KUNING
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fullTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 60,
                height: 3,
                decoration: BoxDecoration(
                  color: yellowAcc,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // SUBJECT GRID
          Wrap(
            spacing: 25,
            runSpacing: 20,
            children: visible.map((item) {
              return Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.white, Colors.grey.shade100],
                      ),
                      border: Border.all(color: navy.withOpacity(0.08)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 12,
                          offset: Offset(0, 6),
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(item["icon"], size: 34, color: navy),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      item["name"],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // CHIP BUTTON
          Center(
            child: GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: yellowAcc.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  expanded ? "Lihat Lebih Sedikit" : "Lihat Semua",
                  style: const TextStyle(
                    color: yellowAcc,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------
/// Custom bottom navigation bar with center notch for FAB
/// Stateless widget that accepts currentIndex & onTap callback.
/// ------------------
class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final List<_NavItem> items = const [
      _NavItem(icon: Icons.home_rounded, label: "Home"),
      _NavItem(icon: Icons.menu_book_rounded, label: "Materi"),
      _NavItem(icon: Icons.chat_bubble_rounded, label: "Chat"),
      _NavItem(icon: Icons.person_rounded, label: "Profil"),
    ];

    return BottomAppBar(
      color: navy,
      elevation: 12,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 65,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(items, 0),
            _buildNavItem(items, 1),

            const SizedBox(width: 20), // Space for FAB

            _buildNavItem(items, 2),
            _buildNavItem(items, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(List<_NavItem> items, int index) {
    final item = items[index];
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInBack,
          transitionBuilder: (child, anim) =>
              ScaleTransition(scale: anim, child: child),
          child: isSelected
              ? Text(
                  item.label,
                  key: ValueKey("text-$index"),
                  style: const TextStyle(
                    color: yellowAcc,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Icon(
                  item.icon,
                  key: ValueKey("icon-$index"),
                  color: Colors.white,
                  size: 26,
                ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
