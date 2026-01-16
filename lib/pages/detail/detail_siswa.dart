import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../models/teaching_request.dart';

class DetailSiswaPage extends StatelessWidget {
  final TeachingRequest request;
  final bool showAcceptButton;

  // ✅ TAMBAHAN biar gak error & konsisten key
  final String guruNama;

  const DetailSiswaPage({
    super.key,
    required this.request,
    required this.guruNama,
    this.showAcceptButton = false,
  });

  // ✅ sanitize key untuk RTDB path
  String safeKey(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[.#$\[\]]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> _acceptRequest(BuildContext context) async {
    try {
      final guruKey = safeKey(guruNama);

      final db = FirebaseDatabase.instanceFor(
        app: FirebaseAuth.instance.app,
        databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
      ).ref();

      final bookingId = request.bookingId;
      final muridUid = request.muridUid;
      final totalHarga = request.harga;

      if (bookingId.isEmpty || muridUid.isEmpty) {
        throw Exception("bookingId/muridUid kosong");
      }

      // ✅ 1) update status di request guru jadi accepted
      final reqRef = db.child("requests_guru/$guruKey/$bookingId");
      await reqRef.update({"status": "accepted"});

      // ✅ 2) update booking murid juga jadi accepted
      final bookingRef = db.child("bookings/$muridUid/$bookingId");
      await bookingRef.update({"status": "accepted"});

      // ✅ 3) saldo guru baru bertambah saat accepted
      final saldoRef = db.child("saldo_guru/$guruKey/saldo");
      await saldoRef.runTransaction((current) {
        final cur = (current as int?) ?? 0;
        return Transaction.success(cur + totalHarga);
      });

      // ✅ 4) masuk sesi hari ini (optional)
      final sesiRef = db.child("guru_hari_ini/$guruKey/$bookingId");
      final snap = await reqRef.get();
      if (snap.exists) {
        await sesiRef.set(snap.value);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request diterima ✅ Saldo bertambah")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menerima: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggalFormatted = DateFormat(
      'dd / MM / yyyy',
    ).format(request.tanggal);

    final jamFormatted =
        "${request.jamMulai.format(context)} - ${request.jamSelesai.format(context)}";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Siswa"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= FOTO + NAMA =================
            Row(
              children: [
                const CircleAvatar(
                  radius: 36,
                  backgroundImage: AssetImage("assets/images/user_dummy.png"),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.namaSiswa,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${request.mapel} • ${request.jarak}",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 28),

            _InfoTile(
              title: "Jumlah Siswa",
              value: "${request.jumlahSiswa} Orang",
              icon: Icons.people,
            ),
            _InfoTile(
              title: "Tanggal Booking",
              value: tanggalFormatted,
              icon: Icons.calendar_today,
            ),
            _InfoTile(
              title: "Jam Belajar",
              value: jamFormatted,
              icon: Icons.schedule,
            ),
            _InfoTile(
              title: "Alamat",
              value: request.alamat,
              icon: Icons.location_on,
            ),
            _InfoTile(
              title: "Harga",
              value: "Rp ${request.harga} / sesi",
              icon: Icons.payments,
            ),

            const Spacer(),

            // ================= BUTTON TERIMA =================
            if (showAcceptButton)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _acceptRequest(context),
                  child: const Text(
                    "Terima",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
