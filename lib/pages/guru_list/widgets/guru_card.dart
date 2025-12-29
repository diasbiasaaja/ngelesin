import 'package:flutter/material.dart';
import '../../../models/guru_model.dart';

class GuruCard extends StatelessWidget {
  final GuruModel guru;
  final VoidCallback onDetail;

  const GuruCard({super.key, required this.guru, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4FB),
        borderRadius: BorderRadius.circular(14),
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
                  guru.nama,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(guru.mapel),
                const SizedBox(height: 4),
                Text(
                  "${guru.tanggal} • ${guru.jam}",
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          ElevatedButton(onPressed: onDetail, child: const Text("Detail")),
        ],
      ),
    );
  }
}
