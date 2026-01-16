import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../../../../models/guru_model.dart';

class QRPaymentPage extends StatelessWidget {
  final Guru guru;
  final DateTime date;
  final TimeOfDay time;
  final int totalHarga;

  final String bookingId;
  final String muridUid;
  final String guruUid; // ✅ ini UID guru asli

  const QRPaymentPage({
    super.key,
    required this.guru,
    required this.date,
    required this.time,
    required this.totalHarga,
    required this.bookingId,
    required this.muridUid,
    required this.guruUid,
  });

  Future<void> _markAsPaid(BuildContext context) async {
    try {
      final db = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
      ).ref();

      // 1) update booking murid jadi paid
      final bookingRef = db.child("bookings/$muridUid/$bookingId");
      await bookingRef.update({"status": "paid"});

      // 2) kirim request ke guru (guruKey = UID)
      final requestRef = db.child("requests_guru/$guruUid/$bookingId");

      final snap = await bookingRef.get();
      if (snap.exists) {
        await requestRef.set(snap.value);
      } else {
        await requestRef.set({
          "bookingId": bookingId,
          "muridUid": muridUid,
          "guruUid": guruUid,
          "guruNama": guru.nama,
          "mapel": guru.mapel,
          "tanggal":
              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
          "jam":
              "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
          "totalHarga": totalHarga,
          "status": "paid",
          "createdAt": ServerValue.timestamp,
        });
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil ✅")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal simpan ke Firebase: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pembayaran")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pembayaran ke ${guru.nama}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Jadwal: ${date.day}/${date.month}/${date.year} • ${time.format(context)}",
            ),
            const SizedBox(height: 16),
            const Text(
              "Total Harga",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Rp $totalHarga",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            Center(
              child: Container(
                height: 220,
                width: 220,
                color: Colors.grey[300],
                child: const Center(child: Text("QR CODE")),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _markAsPaid(context);
                  Navigator.popUntil(context, (r) => r.isFirst);
                },
                child: const Text("Saya Sudah Bayar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
