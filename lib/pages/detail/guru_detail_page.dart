import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/guru_model.dart';
import '../booking/booking_page.dart';
import '/chat/chat_page.dart';
import 'package:ngelesin/theme/chat_theme.dart';

class GuruDetailPage extends StatelessWidget {
  final Guru guru;

  const GuruDetailPage({super.key, required this.guru});

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

  Future<String> _getNamaMurid(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("murid")
          .doc(uid)
          .get();

      if (!doc.exists) return uid;

      final data = doc.data() as Map<String, dynamic>;
      final nama = (data["nama"] ?? "").toString();

      return nama.isNotEmpty ? nama : uid;
    } catch (_) {
      return uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ambil ulang data guru dari Firestore
    final guruDocRef = FirebaseFirestore.instance
        .collection("guru")
        .doc(guru.uid);

    return Scaffold(
      appBar: AppBar(title: Text(guru.nama)),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: guruDocRef.snapshots(),
        builder: (context, snap) {
          // fallback
          final data = snap.data?.data() ?? {};

          final nama = (data["nama"] ?? guru.nama).toString();

          // mapel di UI kamu memang "SD Matematika"
          // di firestore kamu mapel_sd berupa list, jadi kita fallback ke guru.mapel
          final mapel = guru.mapel;

          final bio = (data["bio"] ?? guru.bio).toString();

          // di firestore kamu: sertifikat_url, bukan fotoUrl
          final fotoUrl =
              (data["foto_url"] ??
                      guru.fotoUrl ??
                      "assets/images/user_dummy.png")
                  .toString();

          // ✅ rating avg & count sesuai firestore kamu
          final rating = _toDouble(data["rating_avg"]);
          final ratingCount = _toInt(data["rating_count"]);

          // ✅ harga
          final hargaPerJam = _toInt(data["harga_per_jam"] ?? guru.hargaPerJam);

          // harga kelompok sesuai field kamu di GuruListPage:
          final harga1_5 = _toInt(data["harga_1_5"]);
          final harga6_10 = _toInt(data["harga_6_10"]);

          HargaKelompok? hargaKelompok;
          if (harga1_5 > 0 || harga6_10 > 0) {
            hargaKelompok = HargaKelompok(
              harga1_5: harga1_5 > 0 ? harga1_5 : hargaPerJam,
              harga6_10: harga6_10 > 0 ? harga6_10 : hargaPerJam,
            );
          } else {
            hargaKelompok = guru.hargaKelompok;
          }

          // ✅ bikin guru terbaru buat ke booking
          final newGuru = Guru(
            uid: guru.uid,
            nama: nama,
            mapel: mapel,
            bio: bio,
            fotoUrl: fotoUrl,
            rating: rating,
            totalUlasan: ratingCount,
            ulasan: const [],
            hargaPerJam: hargaPerJam,
            hargaKelompok: hargaKelompok,
            jarakKm: guru.jarakKm,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(fotoUrl),
                    onBackgroundImageError: (_, __) {},
                  ),
                ),

                const SizedBox(height: 12),

                Center(
                  child: Column(
                    children: [
                      Text(
                        nama,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(mapel),
                      Text(
                        "⭐ ${rating.toStringAsFixed(1)} ($ratingCount ulasan)",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Tentang Guru",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(bio),

                const SizedBox(height: 20),

                const Text(
                  "Harga",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                _HargaBox(
                  title: "Harga 1 Orang / Sesi",
                  value: "Rp $hargaPerJam",
                ),

                if (hargaKelompok != null) ...[
                  const SizedBox(height: 8),
                  _HargaBox(
                    title: "Harga 1–5 Orang / Sesi",
                    value: "Rp ${hargaKelompok.harga1_5}",
                  ),
                  const SizedBox(height: 8),
                  _HargaBox(
                    title: "Harga 6–10 Orang / Sesi",
                    value: "Rp ${hargaKelompok.harga6_10}",
                  ),
                ],

                const SizedBox(height: 20),

                const Text(
                  "Ulasan",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // ✅ ULASAN dari collection reviews
                // ✅ ULASAN dari collection reviews (ANTI ERROR)
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection("reviews")
                      .where("guruUid", isEqualTo: guru.uid)
                      .snapshots(),
                  builder: (context, reviewSnap) {
                    // ✅ tampilkan error biar kelihatan masalahnya
                    if (reviewSnap.hasError) {
                      debugPrint("REVIEWS ERROR: ${reviewSnap.error}");
                      return Text(
                        "Gagal memuat ulasan: ${reviewSnap.error}",
                        style: const TextStyle(color: Colors.red),
                      );
                    }

                    if (reviewSnap.connectionState == ConnectionState.waiting) {
                      return const Text(
                        "Memuat ulasan...",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    if (!reviewSnap.hasData || reviewSnap.data!.docs.isEmpty) {
                      debugPrint("REVIEWS KOSONG: guruUid=${guru.uid}");
                      return const Text(
                        "Belum ada ulasan",
                        style: TextStyle(color: Colors.grey),
                      );
                    }

                    final reviews = reviewSnap.data!.docs;

                    // ✅ sort manual berdasarkan createdAt kalau ada
                    reviews.sort((a, b) {
                      final ad = a.data();
                      final bd = b.data();

                      final at = ad["createdAt"];
                      final bt = bd["createdAt"];

                      DateTime aTime = DateTime(2000);
                      DateTime bTime = DateTime(2000);

                      if (at is Timestamp) aTime = at.toDate();
                      if (bt is Timestamp) bTime = bt.toDate();

                      return bTime.compareTo(aTime); // terbaru dulu
                    });

                    debugPrint(
                      "REVIEWS ADA: ${reviews.length} untuk guruUid=${guru.uid}",
                    );

                    return Column(
                      children: reviews.map((doc) {
                        final d = doc.data();

                        final rating = (d["rating"] is num)
                            ? (d["rating"] as num).toDouble()
                            : 0.0;

                        final komentar = (d["ulasan"] ?? "-").toString();

                        final muridUid = (d["muridUid"] ?? "-").toString();

                        return FutureBuilder<String>(
                          future: _getNamaMurid(muridUid),
                          builder: (context, namaSnap) {
                            final namaMurid = namaSnap.data ?? muridUid;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.person, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "$namaMurid • ⭐ ${rating.toStringAsFixed(1)}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(komentar),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 30),

                Row(
                  children: [
                    // ================= CHAT =================
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                title: nama,
                                theme: chatThemeDefault,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.chat),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // ================= BOOKING =================
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingPage(guru: newGuru),
                            ),
                          );
                        },
                        child: const Text(
                          "Booking",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HargaBox extends StatelessWidget {
  final String title;
  final String value;

  const _HargaBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1F3556),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
