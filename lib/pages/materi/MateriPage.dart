import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'materi_aplod_page.dart';

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  String shortId(String id) {
    if (id.length <= 6) return id;
    return id.substring(id.length - 6); // ambil 6 char terakhir
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Guru belum login")));
    }

    final guruUid = user.uid;

    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final jadwalRef = db.child("jadwal_guru/$guruUid");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A2A43),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Materi"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<DatabaseEvent>(
          stream: jadwalRef.onValue,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.hasData || snap.data!.snapshot.value == null) {
              return const Center(child: Text("Belum ada jadwal accepted"));
            }

            final raw = snap.data!.snapshot.value;
            if (raw is! Map) {
              return const Center(child: Text("Data jadwal tidak valid"));
            }

            final entries = raw.entries.toList();

            // ✅ hanya yang accepted
            final accepted = entries.where((e) {
              final data = e.value;
              if (data is Map) {
                return (data["status"] ?? "").toString() == "accepted";
              }
              return false;
            }).toList();

            if (accepted.isEmpty) {
              return const Center(child: Text("Belum ada jadwal accepted"));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MATERI",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                ...accepted.map((e) {
                  final bookingId = e.key.toString();
                  final data = e.value as Map;

                  final mapel = (data["mapel"] ?? "-").toString();
                  final muridNama = (data["muridNama"] ?? "-").toString();
                  final tanggal = (data["tanggal"] ?? "-").toString();
                  final jam = (data["jam"] ?? "-").toString();

                  return MateriTile(
                    title: "$mapel - $muridNama",
                    subtitle: "$tanggal • $jam",

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MateriUploadPage(
                            bookingId: bookingId,
                            guruUid: guruUid,
                            mapel: mapel,
                            muridNama: muridNama,
                            tanggal: tanggal,
                            jam: jam,
                            muridUid: '',
                          ),
                        ),
                      );
                    },
                    bookingLabel: '',
                  );
                }).toList(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class MateriTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String bookingLabel;
  final VoidCallback onTap;

  const MateriTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.bookingLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ fix overflow
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),
                Text(
                  bookingLabel,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFC947),
              foregroundColor: Colors.black,
            ),
            child: const Text("Masuk"),
          ),
        ],
      ),
    );
  }
}
