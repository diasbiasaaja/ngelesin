import 'package:flutter/material.dart';
import '../../../../models/guru_model.dart';

class QRPaymentPage extends StatelessWidget {
  final Guru guru;
  final DateTime date;
  final TimeOfDay time;
  final int totalHarga;

  const QRPaymentPage({
    super.key,
    required this.guru,
    required this.date,
    required this.time,
    required this.totalHarga,
  });

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
            Text(
              "Total Harga",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Rp $totalHarga",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // DUMMY QR
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
                onPressed: () {
                  // nanti: cek status pembayaran dari backend
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
