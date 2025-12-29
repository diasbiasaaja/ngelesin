import 'package:flutter/material.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

/// ================= JUDUL "JADWAL HARI INI" =================
class JadwalHariIni extends StatelessWidget {
  final VoidCallback onTap;

  const JadwalHariIni({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Jadwal Hari Ini",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                color: yellowAcc,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= CARD JADWAL GURU =================
class JadwalGuruCard extends StatelessWidget {
  final String namaGuru;
  final String mapel;
  final String jam;

  const JadwalGuruCard({
    super.key,
    required this.namaGuru,
    required this.mapel,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 22, child: Icon(Icons.person)),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaGuru,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(mapel, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(jam, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),

          ElevatedButton(onPressed: () {}, child: const Text("Detail")),
        ],
      ),
    );
  }
}
