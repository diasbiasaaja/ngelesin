import 'package:flutter/material.dart';

class JadwalHariIni extends StatelessWidget {
  final VoidCallback onTap;

  const JadwalHariIni({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Text(
              "Jadwal Hari Ini",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }
}

class JadwalGuruCard extends StatelessWidget {
  final String namaGuru;
  final String mapel;
  final String jam;
  final VoidCallback onDetail;

  const JadwalGuruCard({
    super.key,
    required this.namaGuru,
    required this.mapel,
    required this.jam,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(child: Icon(Icons.person)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaGuru,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(mapel),
                Text(jam, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(onPressed: onDetail, child: const Text("Detail")),
        ],
      ),
    );
  }
}
