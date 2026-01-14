import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'jadwal.dart';

class JadwalSection extends StatefulWidget {
  const JadwalSection({super.key});

  @override
  State<JadwalSection> createState() => _JadwalSectionState();
}

class _JadwalSectionState extends State<JadwalSection> {
  bool showRiwayat = false;

  String _todayKey() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text("Silakan login untuk melihat jadwal"),
      );
    }

    // query booking siswa
    final bookingQuery = FirebaseFirestore.instance
        .collection("booking")
        .where("murid_uid", isEqualTo: uid)
        .orderBy("tanggal", descending: true);

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: bookingQuery.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final docs = snapshot.data!.docs;

        // ambil booking hari ini (tanggal hari ini)
        final today = _todayKey();
        final todayDocs = docs.where((d) {
          final t = d.data()["tanggal"];
          if (t == null) return false;

          final dt = (t as Timestamp).toDate();
          final key =
              "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
          return key == today;
        }).toList();

        // history = selain hari ini
        final historyDocs = docs.where((d) => !todayDocs.contains(d)).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= JADWAL HARI INI =================
            if (todayDocs.isNotEmpty) ...[
              JadwalHariIni(
                onTap: () {}, // nanti bisa scroll
              ),
              const SizedBox(height: 10),

              ...todayDocs.map((doc) {
                final data = doc.data();
                final guruNama = (data["guru_nama"] ?? "-").toString();
                final mapel = (data["mapel"] ?? "-").toString();
                final jam = (data["jam"] ?? "-").toString();

                return JadwalGuruCard(
                  namaGuru: guruNama,
                  mapel: mapel,
                  jam: jam,
                  onDetail: () {
                    // TODO: arahkan ke detail booking
                    debugPrint("detail booking: ${doc.id}");
                  },
                );
              }).toList(),
            ],

            // ================= RIWAYAT =================
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () => setState(() => showRiwayat = !showRiwayat),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    const Text(
                      "Riwayat",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    AnimatedRotation(
                      turns: showRiwayat ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),

            if (showRiwayat)
              Column(
                children: historyDocs.isEmpty
                    ? [
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text("Belum ada riwayat booking"),
                        ),
                      ]
                    : historyDocs.take(10).map((doc) {
                        final data = doc.data();
                        final guruNama = (data["guru_nama"] ?? "-").toString();
                        final mapel = (data["mapel"] ?? "-").toString();
                        final jam = (data["jam"] ?? "-").toString();

                        return JadwalGuruCard(
                          namaGuru: guruNama,
                          mapel: mapel,
                          jam: jam,
                          onDetail: () {
                            debugPrint("detail history: ${doc.id}");
                          },
                        );
                      }).toList(),
              ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}
