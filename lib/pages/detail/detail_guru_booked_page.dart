import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailGuruBookedPage extends StatefulWidget {
  final String guruUid; // UID guru di Firestore
  final String bookingId; // key booking di RTDB

  const DetailGuruBookedPage({
    super.key,
    required this.guruUid,
    required this.bookingId,
  });

  @override
  State<DetailGuruBookedPage> createState() => _DetailGuruBookedPageState();
}

class _DetailGuruBookedPageState extends State<DetailGuruBookedPage> {
  final ulasanC = TextEditingController();
  int rating = 5;
  bool isSubmitting = false;

  // helper convert hargaType ke label
  String paketLabel(String hargaType) {
    if (hargaType == "group1_5") return "Kelompok 1–5";
    if (hargaType == "group6_10") return "Kelompok 6–10";
    return "1 Orang";
  }

  Future<void> _submitReview({
    required String guruUid,
    required String bookingId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Siswa belum login");

      setState(() => isSubmitting = true);

      // 1) simpan review
      await FirebaseFirestore.instance.collection("reviews").add({
        "guruUid": guruUid,
        "muridUid": user.uid,
        "bookingId": bookingId,
        "rating": rating,
        "ulasan": ulasanC.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      // 2) update rating agregat di guru
      // ambil data lama
      final guruRef = FirebaseFirestore.instance
          .collection("guru")
          .doc(guruUid);

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(guruRef);

        final data = snap.data() as Map<String, dynamic>? ?? {};
        final oldAvg = (data["rating_avg"] is num)
            ? (data["rating_avg"] as num).toDouble()
            : 0.0;
        final oldCount = (data["rating_count"] is int)
            ? (data["rating_count"] as int)
            : int.tryParse("${data["rating_count"]}") ?? 0;

        final newCount = oldCount + 1;
        final newAvg = ((oldAvg * oldCount) + rating) / newCount;

        tx.update(guruRef, {"rating_avg": newAvg, "rating_count": newCount});
      });

      ulasanC.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ulasan berhasil dikirim ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal kirim ulasan: $e")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  void dispose() {
    ulasanC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Siswa belum login")));
    }

    final muridUid = user.uid;

    // ✅ RTDB
    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final bookingRef = db.child("bookings/$muridUid/${widget.bookingId}");

    // ✅ Firestore guru
    final guruRef = FirebaseFirestore.instance
        .collection("guru")
        .doc(widget.guruUid);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Guru"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: guruRef.get(),
        builder: (context, guruSnap) {
          if (!guruSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!guruSnap.data!.exists) {
            return const Center(child: Text("Data guru tidak ditemukan"));
          }

          final guruData = guruSnap.data!.data() as Map<String, dynamic>;
          final namaGuru = (guruData["nama"] ?? "-").toString();
          final mapel = (guruData["mapel"] ?? "-").toString();
          final bio = (guruData["bio"] ?? "-").toString();

          final ratingAvg = (guruData["rating_avg"] is num)
              ? (guruData["rating_avg"] as num).toDouble()
              : 0.0;
          final ratingCount = (guruData["rating_count"] is int)
              ? guruData["rating_count"] as int
              : int.tryParse("${guruData["rating_count"]}") ?? 0;

          final hargaSingle = guruData["hargaPerJam"];
          final harga15 = guruData["harga1_5"];
          final harga610 = guruData["harga6_10"];

          return FutureBuilder<DataSnapshot>(
            future: bookingRef.get(),
            builder: (context, bookingSnap) {
              if (bookingSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!bookingSnap.hasData || bookingSnap.data!.value == null) {
                return const Center(
                  child: Text("Data booking tidak ditemukan"),
                );
              }

              final raw = bookingSnap.data!.value;
              if (raw is! Map) {
                return const Center(child: Text("Format booking tidak valid"));
              }

              final bookingData = Map<String, dynamic>.from(raw);

              final tanggal = (bookingData["tanggal"] ?? "-").toString();
              final jam = (bookingData["jam"] ?? "-").toString();
              final status = (bookingData["status"] ?? "-").toString();
              final hargaType = (bookingData["hargaType"] ?? "single")
                  .toString();

              final totalHargaRaw = bookingData["totalHarga"];
              final totalHarga = (totalHargaRaw is int)
                  ? totalHargaRaw
                  : int.tryParse("$totalHargaRaw") ?? 0;

              final tanggalFormatted = _formatTanggal(tanggal);

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ===== avatar =====
                    Center(
                      child: CircleAvatar(
                        radius: 54,
                        backgroundColor: Colors.deepPurple.shade100,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Center(
                      child: Text(
                        namaGuru,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    Center(
                      child: Column(
                        children: [
                          Text(
                            mapel,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${ratingAvg.toStringAsFixed(1)} ($ratingCount ulasan)",
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ===== Tentang =====
                    const Text(
                      "Tentang Guru",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(bio, style: const TextStyle(height: 1.4)),

                    const SizedBox(height: 18),

                    // ===== Harga =====
                    const Text(
                      "Harga",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _HargaTile(
                      "Harga 1 Orang / Sesi",
                      "Rp ${hargaSingle ?? '-'}",
                    ),
                    _HargaTile(
                      "Harga 1–5 Orang / Sesi",
                      "Rp ${harga15 ?? '-'}",
                    ),
                    _HargaTile(
                      "Harga 6–10 Orang / Sesi",
                      "Rp ${harga610 ?? '-'}",
                    ),

                    const SizedBox(height: 18),

                    // ===== BOOKING INFO =====
                    const Text(
                      "Booking Kamu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    _InfoBooking("Paket", paketLabel(hargaType)),
                    _InfoBooking("Tanggal", tanggalFormatted),
                    _InfoBooking("Jam", jam),
                    _InfoBooking("Status", status.toUpperCase()),
                    _InfoBooking("Total", "Rp $totalHarga"),

                    const SizedBox(height: 18),

                    // ===== ULASAN FORM =====
                    const Text(
                      "Ulasan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // rating bintang
                    Row(
                      children: List.generate(5, (i) {
                        final index = i + 1;
                        return IconButton(
                          onPressed: () => setState(() => rating = index),
                          icon: Icon(
                            index <= rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),

                    TextField(
                      controller: ulasanC,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Tulis ulasan kamu...",
                        filled: true,
                        fillColor: const Color(0xFFF7F7F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ===== BOTTOM BUTTON =====
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Fitur chat nanti ya 😄"),
                                ),
                              );
                            },
                            child: const Icon(Icons.chat_bubble_outline),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () => _submitReview(
                                    guruUid: widget.guruUid,
                                    bookingId: widget.bookingId,
                                  ),
                            child: Text(
                              isSubmitting ? "Mengirim..." : "Kirim Ulasan",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTanggal(String yyyyMMdd) {
    try {
      final dt = DateTime.parse(yyyyMMdd);
      return DateFormat("dd / MM / yyyy").format(dt);
    } catch (_) {
      return yyyyMMdd;
    }
  }
}

class _HargaTile extends StatelessWidget {
  final String label;
  final String value;

  const _HargaTile(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C3557),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
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

class _InfoBooking extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBooking(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text("$title: ", style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
