import 'package:flutter/material.dart';

class CustomNavbarsiswa extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavbarsiswa({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(Icons.home, "Home"),
      _NavItem(Icons.menu_book, "Materi"),
      _NavItem(Icons.chat, "Pesan"),
      _NavItem(Icons.person, "Profil"),
    ];

    return BottomAppBar(
      color: const Color(0xFF0A2A43),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildItem(items, 0),
            _buildItem(items, 1),
            const SizedBox(width: 36),
            _buildItem(items, 2),
            _buildItem(items, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(List<_NavItem> items, int i) {
    final active = currentIndex == i;
    return GestureDetector(
      onTap: () => onTap(i),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            items[i].icon,
            color: active ? const Color(0xFFFFC947) : Colors.white,
          ),
          if (active)
            Text(
              items[i].label,
              style: const TextStyle(
                color: Color(0xFFFFC947),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
