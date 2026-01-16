import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/guru_model.dart';
import 'widgets/guru_card.dart';
import '../detail/guru_detail_page.dart';

class GuruListPage extends StatelessWidget {
  final String mapel;
  final String jenjang;

  const GuruListPage({super.key, required this.mapel, required this.jenjang});

  String _mapelField() {
    if (jenjang == "SD") return "mapel_sd";
    if (jenjang == "SMP") return "mapel_smp";
    return "mapel_sma";
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  Guru _toGuru(Map<String, dynamic> data) {
    return Guru(
      nama: (data["nama"] ?? "-").toString(),
      mapel: "$jenjang $mapel",
      bio: (data["bio"] ?? "").toString(),
      fotoUrl: (data["foto_url"] ?? "assets/images/user_dummy.png").toString(),

      rating: _toDouble(data["rating"]),
      totalUlasan: _toInt(data["total_ulasan"]),

      jarakKm: _toDouble(data["jarak_km"]),
      hargaPerJam: _toInt(data["harga_per_jam"]),

      hargaKelompok: (data["harga_1_5"] != null || data["harga_6_10"] != null)
          ? HargaKelompok(
              harga1_5: _toInt(data["harga_1_5"]),
              harga6_10: _toInt(data["harga_6_10"]),
            )
          : null,

      ulasan: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final field = _mapelField();

    final query = FirebaseFirestore.instance
        .collection("guru")
        .where(field, arrayContains: mapel);

    return Scaffold(
      appBar: AppBar(title: Text("$jenjang - $mapel")),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat data guru"));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text("Belum ada guru untuk $jenjang - $mapel"),
            );
          }

          final gurus = docs.map((d) => _toGuru(d.data())).toList();

          return ListView(
            padding: const EdgeInsets.all(20),
            children: gurus.map((g) {
              return GuruCard(
                guru: g,
                onDetail: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => GuruDetailPage(guru: g)),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
