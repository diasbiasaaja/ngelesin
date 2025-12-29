import 'package:flutter/material.dart';

class MateriDetailSiswaPage extends StatelessWidget {
  const MateriDetailSiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,

          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // JUDUL
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Detail Materi",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // GARIS KUNING
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

                const SizedBox(height: 12),

                // 🔙 ARROW DI BAWAH GARIS
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== BODY =====
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ===== INFO GURU =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F4FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pak Budi",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("Matematika"),
                SizedBox(height: 6),
                Text(
                  "15/12/2025 • 12.00 - 15.00",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ===== LIST MATERI =====
          _materiItem(
            judul: "Persamaan Linear",
            deskripsi: "Penjelasan dasar persamaan linear satu variabel.",
            file: "materi_persamaan_linear.pdf",
          ),

          _materiItem(
            judul: "Latihan Soal",
            deskripsi: "Latihan soal untuk pemahaman siswa.",
            file: "latihan_soal.pdf",
          ),
        ],
      ),
    );
  }

  // ===== ITEM MATERI =====
  static Widget _materiItem({
    required String judul,
    required String deskripsi,
    required String file,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(blurRadius: 8, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(deskripsi),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.attach_file, size: 18),
              const SizedBox(width: 6),
              Text(file),
            ],
          ),
        ],
      ),
    );
  }
}
