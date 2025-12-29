import 'package:flutter/material.dart';
import 'widgets/materi_card.dart';
import 'materi_siswa_detail.dart';

class MateriSiswaPage extends StatelessWidget {
  const MateriSiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // ===== APP BAR =====
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          automaticallyImplyLeading: false,

          elevation: 0,
          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Materi",
                    style: TextStyle(
                      color: Color.fromARGB(255, 10, 10, 10),
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
              ],
            ),
          ),
        ),
        // ===== BODY =====
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          MateriCard(
            namaGuru: "Pak Budi",
            mapel: "Matematika",
            tanggal: "15/12/2025",
            jam: "12.00 - 15.00",
            onDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MateriDetailSiswaPage(),
                ),
              );
            },
          ),

          MateriCard(
            namaGuru: "Bu Rina",
            mapel: "IPA",
            tanggal: "17/12/2025",
            jam: "13.00 - 15.00",
            onDetail: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MateriDetailSiswaPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
