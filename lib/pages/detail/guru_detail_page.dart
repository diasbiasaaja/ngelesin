import 'package:flutter/material.dart';
import '../../models/guru_model.dart';
import '../booking/booking_page.dart';
import '/chat/chat_page.dart';
import '../pembayaran/paymen.dart';
import 'package:ngelesin/theme/chat_theme.dart';

class GuruDetailPage extends StatelessWidget {
  final Guru guru;

  const GuruDetailPage({super.key, required this.guru});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(guru.nama)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: AssetImage(guru.fotoUrl),
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: Column(
                children: [
                  Text(
                    guru.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(guru.mapel),
                  Text("⭐ ${guru.rating} (${guru.totalUlasan} ulasan)"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Tentang Guru",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(guru.bio),

            const SizedBox(height: 20),

            const Text("Harga", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            _HargaBox(
              title: "Harga 1 Orang / Sesi",
              value: "Rp ${guru.hargaPerJam}",
            ),

            if (guru.hargaKelompok != null) ...[
              const SizedBox(height: 8),
              _HargaBox(
                title: "Harga 1–5 Orang / Sesi",
                value: "Rp ${guru.hargaKelompok!.harga1_5}",
              ),
              const SizedBox(height: 8),
              _HargaBox(
                title: "Harga 6–10 Orang / Sesi",
                value: "Rp ${guru.hargaKelompok!.harga6_10}",
              ),
            ],

            const SizedBox(height: 20),

            const Text("Ulasan", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            ...guru.ulasan.map(
              (u) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text("• ${u.nama}: ${u.komentar}"),
              ),
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
                            title: guru.nama,
                            theme: chatThemeDefault,
                          ),
                        ),
                      );
                    },
                    child: const Icon(Icons.chat),
                  ),
                ),

                const SizedBox(width: 12), // 🔥 JARAK ANTAR TOMBOL
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
                          builder: (_) => BookingPage(guru: guru),
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
