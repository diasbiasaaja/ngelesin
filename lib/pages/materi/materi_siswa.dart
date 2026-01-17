import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/materi_card.dart';
import 'materi_siswa_detail.dart';

class MateriSiswaPage extends StatelessWidget {
  const MateriSiswaPage({super.key});

  String _formatTanggal(String dateStr) {
    // yyyy-MM-dd -> dd/MM/yyyy
    try {
      final p = dateStr.split("-");
      return "${p[2]}/${p[1]}/${p[0]}";
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Murid belum login")));
    }

    final muridUid = user.uid;

    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final bookingRef = db.child("bookings/$muridUid");

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
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
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
      ),

      // ===== BODY =====
      body: StreamBuilder<DatabaseEvent>(
        stream: bookingRef.onValue,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.snapshot.value == null) {
            return const Center(child: Text("Belum ada materi"));
          }

          final raw = snap.data!.snapshot.value;
          if (raw is! Map) return const Center(child: Text("Belum ada materi"));

          // ✅ ambil booking status accepted
          final accepted = raw.entries
              .map((e) {
                final data = e.value as Map;
                return {
                  "bookingId": e.key.toString(),
                  "guruNama": (data["guruNama"] ?? "-").toString(),
                  "mapel": (data["mapel"] ?? "-").toString(),
                  "tanggal": (data["tanggal"] ?? "-").toString(),
                  "jam": (data["jam"] ?? "-").toString(),
                  "status": (data["status"] ?? "").toString(),
                };
              })
              .where((b) => b["status"] == "accepted")
              .toList();

          if (accepted.isEmpty) {
            return const Center(child: Text("Belum ada booking accepted"));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: accepted.map((b) {
              final bookingId = b["bookingId"]!;
              final guruNama = b["guruNama"]!;
              final mapel = b["mapel"]!;
              final tanggal = _formatTanggal(b["tanggal"]!);
              final jam = b["jam"]!;

              return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: FirebaseFirestore.instance
                    .collection("materi")
                    .doc(bookingId)
                    .collection("items")
                    .limit(1)
                    .get(),
                builder: (context, materiSnap) {
                  // ✅ kalau belum ada materi sama sekali -> masih boleh tampil tapi status kosong
                  final hasMateri =
                      materiSnap.hasData && (materiSnap.data!.docs.isNotEmpty);

                  return MateriCard(
                    namaGuru: guruNama,
                    mapel: mapel,
                    tanggal: tanggal,
                    jam: jam,
                    onDetail: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MateriDetailSiswaPage(
                            bookingId: bookingId,
                            guruNama: guruNama,
                            mapel: mapel,
                            tanggal: tanggal,
                            jam: jam,
                          ),
                        ),
                      );
                    },
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
