import 'package:flutter/material.dart';
import '../../models/guru_model.dart';
import 'widgets/guru_card.dart';
import '../detail/guru_detail_page.dart';

class GuruListPage extends StatelessWidget {
  final String mapel;
  final String jenjang;

  const GuruListPage({super.key, required this.mapel, required this.jenjang});

  @override
  Widget build(BuildContext context) {
    final List<Guru> gurus = [
      Guru(
        nama: "Pak Budi",
        mapel: "SMA Matematika",
        bio: "Guru berpengalaman 10 tahun, fokus pemahaman konsep.",
        fotoUrl: "assets/images/user_dummy.png",
        rating: 4.9,
        totalUlasan: 23,
        jarakKm: 1.2,
        hargaPerJam: 100000,
        hargaKelompok: HargaKelompok(harga1_5: 80000, harga6_10: 65000),
        ulasan: [
          GuruUlasan(nama: "Rio", komentar: "Penjelasan mudah dimengerti"),
          GuruUlasan(nama: "Nanda", komentar: "Sabar dan ramah"),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("$jenjang - $mapel")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: gurus.map((g) {
          return Builder(
            builder: (context) {
              return GuruCard(
                guru: g,
                onDetail: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GuruDetailPage(guru: g)),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
