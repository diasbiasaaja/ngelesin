import 'package:flutter/material.dart';
import '../../models/guru_model.dart';
import 'widgets/guru_card.dart';

class GuruListPage extends StatelessWidget {
  final String mapel;
  final String jenjang;

  const GuruListPage({super.key, required this.mapel, required this.jenjang});

  @override
  Widget build(BuildContext context) {
    // 🔥 DATA DUMMY (NANTI BACKEND)
    final List<GuruModel> gurus = [
      GuruModel(
        nama: "Pak Budi",
        mapel: "$jenjang $mapel",
        tanggal: "15/12/2025",
        jam: "12.00 - 15.00",
        jarak: 1.2,
        rating: 4.9,
      ),
      GuruModel(
        nama: "Bu Rina",
        mapel: "$jenjang $mapel",
        tanggal: "15/12/2025",
        jam: "16.00 - 18.00",
        jarak: 2.5,
        rating: 4.7,
      ),
    ];

    // 🔥 SORT: TERDEKAT → RATING
    gurus.sort((a, b) {
      final jarakCompare = a.jarak.compareTo(b.jarak);
      if (jarakCompare != 0) return jarakCompare;
      return b.rating.compareTo(a.rating);
    });

    return Scaffold(
      appBar: AppBar(title: Text("$jenjang - $mapel")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // garis kuning
            Container(
              width: 480,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView(
                children: gurus
                    .map(
                      (g) => GuruCard(
                        guru: g,
                        onDetail: () {
                          // nanti ke detail guru
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
