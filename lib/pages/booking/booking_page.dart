import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/guru_model.dart';
import '../../../../theme/colors.dart';
import '../pembayaran/paymen.dart';

class BookingPage extends StatefulWidget {
  final Guru guru;

  const BookingPage({super.key, required this.guru});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final _auth = FirebaseAuth.instance;

  // ✅ WAJIB untuk Flutter Web
  final _db = FirebaseDatabase.instanceFor(
    app: FirebaseAuth.instance.app,
    databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
  ).ref();

  String selectedHargaType = "single"; // single | group1_5 | group6_10

  String safeKey(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[.#$\[\]]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) setState(() => selectedTime = time);
  }

  String _formatDate(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  String _formatTime(TimeOfDay t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  int _getSelectedHarga(Guru guru) {
    if (selectedHargaType == "group1_5") {
      return guru.hargaKelompok?.harga1_5 ?? guru.hargaPerJam;
    }
    if (selectedHargaType == "group6_10") {
      return guru.hargaKelompok?.harga6_10 ?? guru.hargaPerJam;
    }
    return guru.hargaPerJam;
  }

  Future<Map<String, dynamic>> _getMuridData(String uid) async {
    // ✅ ambil dari Firestore collection murid (sesuai screenshot kamu)
    final doc = await FirebaseFirestore.instance
        .collection("murid")
        .doc(uid)
        .get();
    if (!doc.exists) return {"nama": uid};

    final data = doc.data() ?? {};
    return {
      "nama": (data["nama"] ?? uid).toString(),
      "email": (data["email"] ?? "").toString(),
      "pendidikan": (data["pendidikan"] ?? "").toString(),
    };
  }

  Future<String?> _createBookingRTDB({
    required int totalHarga,
    required String hargaType,
    required String muridUid,
    required String guruUid,
    required String muridNama,
  }) async {
    try {
      final guru = widget.guru;

      final bookingRef = _db.child("bookings").child(muridUid).push();
      final bookingId = bookingRef.key;
      if (bookingId == null) return null;

      await bookingRef.set({
        "bookingId": bookingId,
        "muridUid": muridUid,
        "muridNama": muridNama, // ✅ biar request tampil nama
        "guruUid": guruUid,
        "guruNama": guru.nama,
        "mapel": guru.mapel,
        "tanggal": _formatDate(selectedDate!),
        "jam": _formatTime(selectedTime!),
        "hargaType": hargaType,
        "totalHarga": totalHarga,
        "status": "pending", // pending -> paid -> accepted -> selesai
        "createdAt": ServerValue.timestamp,
      });

      return bookingId;
    } catch (e, s) {
      debugPrint("RTDB SET ERROR: $e");
      debugPrint("STACKTRACE: $s");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final guru = widget.guru;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Booking Guru",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= GURU CARD =================
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: AssetImage(guru.fotoUrl),
                      onBackgroundImageError: (_, __) {},
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guru.nama,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(guru.mapel),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 16,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text("${guru.rating} • ${guru.jarakKm} km"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= HARGA =================
              const Text(
                "Harga",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              _priceRow("1 Siswa / jam", "Rp ${guru.hargaPerJam}"),

              if (guru.hargaKelompok != null) ...[
                _priceRow(
                  "Kelompok 1–5 siswa / jam",
                  "Rp ${guru.hargaKelompok!.harga1_5}",
                ),
                _priceRow(
                  "Kelompok 6–10 siswa / jam",
                  "Rp ${guru.hargaKelompok!.harga6_10}",
                ),
              ],

              const SizedBox(height: 14),

              // ✅ PILIH PAKET
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pilih Paket",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      value: "single",
                      groupValue: selectedHargaType,
                      onChanged: (v) => setState(() => selectedHargaType = v!),
                      title: const Text("1 Siswa"),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (guru.hargaKelompok != null) ...[
                      RadioListTile<String>(
                        value: "group1_5",
                        groupValue: selectedHargaType,
                        onChanged: (v) =>
                            setState(() => selectedHargaType = v!),
                        title: const Text("Kelompok 1–5"),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: "group6_10",
                        groupValue: selectedHargaType,
                        onChanged: (v) =>
                            setState(() => selectedHargaType = v!),
                        title: const Text("Kelompok 6–10"),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= JADWAL =================
              const Text(
                "Atur Jadwal",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _PickerItem(
                    title: "Tanggal",
                    icon: Icons.calendar_month,
                    value: selectedDate == null
                        ? "Pilih"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    onTap: pickDate,
                  ),
                  _PickerItem(
                    title: "Jam",
                    icon: Icons.access_time,
                    value: selectedTime == null
                        ? "Pilih"
                        : selectedTime!.format(context),
                    onTap: pickTime,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ================= BUTTON =================
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Pilih tanggal dan jam terlebih dahulu",
                          ),
                        ),
                      );
                      return;
                    }

                    final muridUid = _auth.currentUser?.uid;
                    if (muridUid == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User belum login")),
                      );
                      return;
                    }

                    // ✅ guruUid dibuat dari nama guru
                    final guruUid = safeKey(guru.nama);

                    final muridData = await _getMuridData(muridUid);
                    final muridNama = muridData["nama"].toString();

                    final totalHarga = _getSelectedHarga(guru);

                    final bookingId = await _createBookingRTDB(
                      totalHarga: totalHarga,
                      hargaType: selectedHargaType,
                      muridUid: muridUid,
                      guruUid: guruUid,
                      muridNama: muridNama,
                    );

                    if (bookingId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Booking gagal disimpan, coba lagi ya...",
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QRPaymentPage(
                          guru: guru,
                          date: selectedDate!,
                          time: selectedTime!,
                          totalHarga: totalHarga,
                          bookingId: bookingId,
                          muridUid: muridUid,
                          guruUid: guruUid,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: navy,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "BOOKING",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _PickerItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback onTap;

  const _PickerItem({
    required this.title,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.06)),
          ],
        ),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 6),
            Icon(icon, size: 28),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
