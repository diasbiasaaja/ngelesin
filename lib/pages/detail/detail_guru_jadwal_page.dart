import 'package:flutter/material.dart';
import '/models/booking.dart';
import '/chat/chat_page.dart';
import '../../theme/chat_theme.dart';

class BookingDetailPage extends StatefulWidget {
  final Booking booking;

  const BookingDetailPage({super.key, required this.booking});

  @override
  State<BookingDetailPage> createState() => _BookingDetailPageState();
}

class _BookingDetailPageState extends State<BookingDetailPage> {
  int rating = 0;
  final reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final guru = widget.booking.guru;
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(guru.nama), centerTitle: true),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20, // 🔥 FIX
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= HEADER =================
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundImage: AssetImage(guru.fotoUrl),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    guru.nama,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(guru.mapel),
                  const SizedBox(height: 4),
                  Text("⭐ ${guru.rating} (${guru.totalUlasan} ulasan)"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ================= JADWAL =================
            _sectionTitle("Detail Jadwal"),
            _infoRow(
              "Tanggal",
              "${booking.tanggal.day}/${booking.tanggal.month}/${booking.tanggal.year}",
            ),
            _infoRow("Jam", booking.jam.format(context)),
            _infoRow("Jumlah Siswa", "${booking.jumlahSiswa} orang"),
            _infoRow("Alamat", booking.alamat),

            const SizedBox(height: 16),

            _infoRow(
              "Status Pembayaran",
              booking.sudahBayar ? "Lunas" : "Belum Dibayar",
              valueColor: booking.sudahBayar ? Colors.green : Colors.red,
            ),

            const SizedBox(height: 24),

            // ================= CHAT =================
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.chat),
                    label: const Text("Chat Guru"),
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
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // ================= ULASAN =================
            if (booking.sudahBayar) ...[
              _sectionTitle("Beri Ulasan"),

              // ⭐ RATING
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    onPressed: () {
                      setState(() {
                        rating = starIndex;
                      });
                    },
                    icon: Icon(
                      Icons.star,
                      color: rating >= starIndex
                          ? Colors.amber
                          : Colors.grey.shade400,
                    ),
                  );
                }),
              ),

              // 📝 REVIEW
              TextField(
                controller: reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Tulis ulasan singkat...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: rating == 0
                      ? null
                      : () {
                          // nanti ke backend
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Ulasan berhasil dikirim"),
                            ),
                          );
                        },
                  child: const Text("Kirim Ulasan"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ================= HELPER =================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
