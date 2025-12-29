import 'package:flutter/material.dart';

class MateriCard extends StatelessWidget {
  final String namaGuru;
  final String mapel;
  final String tanggal;
  final String jam;
  final VoidCallback onDetail;

  const MateriCard({
    super.key,
    required this.namaGuru,
    required this.mapel,
    required this.tanggal,
    required this.jam,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaGuru,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(mapel),
                const SizedBox(height: 6),
                Text("$tanggal • $jam"),
              ],
            ),
          ),
          ElevatedButton(onPressed: onDetail, child: const Text("Detail")),
        ],
      ),
    );
  }
}
