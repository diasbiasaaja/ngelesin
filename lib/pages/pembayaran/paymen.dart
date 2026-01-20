import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../pages/home_siswa/home_siswa_page.dart';
import '../../../../models/guru_model.dart';

class QRPaymentPage extends StatefulWidget {
  final Guru guru;
  final DateTime date;
  final TimeOfDay time;
  final int totalHarga;

  final String bookingId;
  final String muridUid;
  final String guruUid;

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

  @override
  State<QRPaymentPage> createState() => _QRPaymentPageState();
}

class _QRPaymentPageState extends State<QRPaymentPage> {
  // ===== bukti transfer (support web + mobile) =====
  File? buktiFile; // mobile
  Uint8List? buktiBytes; // web
  String? buktiName; // nama file

  bool isUploading = false;

  // ===== rekening admin ===== (ganti sesuai kebutuhan)
  final String bank = "BCA";
  final String noRek = "1234567890";
  final String atasNama = "Admin Ngelesin";

  // ===== cloudinary kamu =====
  final String cloudName = "dhamjmtwu";
  final String uploadPreset = "guru_unsigned";
  final String folderCloudinary = "guru_docs";

  Future<Map<String, dynamic>> _getMuridInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("murid")
          .doc(uid)
          .get();
      if (!doc.exists) return {"nama": uid, "alamat": "-"};

      final data = doc.data() ?? {};
      return {
        "nama": (data["nama"] ?? uid).toString(),
        "alamat": (data["alamat"] ?? "-").toString(),
      };
    } catch (_) {
      return {"nama": uid, "alamat": "-"};
    }
  }

  // ✅ pick bukti transfer (gallery) support web+mobile
  Future<void> _pickBukti() async {
    final picker = ImagePicker();

    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (xFile == null) return;

    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        buktiBytes = bytes;
        buktiName = xFile.name;
        buktiFile = null;
      });
    } else {
      setState(() {
        buktiFile = File(xFile.path);
        buktiBytes = null;
        buktiName = xFile.name;
      });
    }
  }

  // ✅ upload to cloudinary support web+mobile
  Future<String?> _uploadToCloudinary() async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri);
      request.fields["upload_preset"] = uploadPreset;
      request.fields["folder"] = folderCloudinary;

      // WEB upload bytes
      if (kIsWeb) {
        if (buktiBytes == null) return null;

        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            buktiBytes!,
            filename: buktiName ?? "bukti.jpg",
          ),
        );
      }
      // MOBILE upload path
      else {
        if (buktiFile == null) return null;

        request.files.add(
          await http.MultipartFile.fromPath("file", buktiFile!.path),
        );
      }

      final response = await request.send();

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);

      return data["secure_url"];
    } catch (_) {
      return null;
    }
  }

  // ✅ update paid + save bukti url
  Future<void> _markAsPaid(BuildContext context) async {
    try {
      setState(() => isUploading = true);

      // 1) upload bukti dulu
      final buktiUrl = await _uploadToCloudinary();
      if (buktiUrl == null || buktiUrl.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal upload bukti transfer ❌")),
        );
        return;
      }

      // 2) ambil info murid
      final muridInfo = await _getMuridInfo(widget.muridUid);
      final muridNama = muridInfo["nama"].toString();
      final alamat = muridInfo["alamat"].toString();

      // 3) db rtdb
      final db = FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
      ).ref();

      // 4) update booking murid
      final bookingRef = db.child(
        "bookings/${widget.muridUid}/${widget.bookingId}",
      );

      await bookingRef.update({
        "status": "paid",
        "muridNama": muridNama,
        "alamat": alamat,
        "buktiTransferUrl": buktiUrl,
        "bankAdmin": bank,
        "noRekAdmin": noRek,
        "atasNamaAdmin": atasNama,
      });

      // 5) kirim request ke guru
      final requestRef = db.child(
        "requests_guru/${widget.guruUid}/${widget.bookingId}",
      );

      final snap = await bookingRef.get();
      if (snap.exists) {
        await requestRef.set(snap.value);
      } else {
        await requestRef.set({
          "bookingId": widget.bookingId,
          "muridUid": widget.muridUid,
          "muridNama": muridNama,
          "alamat": alamat,
          "guruUid": widget.guruUid,
          "guruNama": widget.guru.nama,
          "mapel": widget.guru.mapel,
          "tanggal":
              "${widget.date.year}-${widget.date.month.toString().padLeft(2, '0')}-${widget.date.day.toString().padLeft(2, '0')}",
          "jam":
              "${widget.time.hour.toString().padLeft(2, '0')}:${widget.time.minute.toString().padLeft(2, '0')}",
          "totalHarga": widget.totalHarga,
          "status": "paid",
          "buktiTransferUrl": buktiUrl,
          "bankAdmin": bank,
          "noRekAdmin": noRek,
          "atasNamaAdmin": atasNama,
          "createdAt": ServerValue.timestamp,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Pembayaran berhasil ✅")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal simpan: $e")));
      }
    } finally {
      if (mounted) setState(() => isUploading = false);
    }
  }

  bool get sudahUploadBukti {
    if (kIsWeb) return buktiBytes != null;
    return buktiFile != null;
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
              "Pembayaran ke ${widget.guru.nama}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Jadwal: ${widget.date.day}/${widget.date.month}/${widget.date.year} • ${widget.time.format(context)}",
            ),
            const SizedBox(height: 16),
            const Text(
              "Total Harga",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              "Rp ${widget.totalHarga}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // ✅ rekening admin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Transfer ke Rekening Admin",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text("Bank: $bank"),
                  Text("No Rekening: $noRek"),
                  Text("Atas Nama: $atasNama"),
                  const SizedBox(height: 10),
                  const Text(
                    "⚠️ Pastikan nominal sesuai total harga.",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ✅ upload bukti
            const Text(
              "Upload Bukti Transfer",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: _pickBukti,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: !sudahUploadBukti
                    ? const Center(
                        child: Text(
                          "Klik untuk pilih foto bukti transfer",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: kIsWeb
                            ? Image.memory(buktiBytes!, fit: BoxFit.cover)
                            : Image.file(buktiFile!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const Spacer(),

            // ✅ button bayar
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        if (!sudahUploadBukti) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Upload bukti transfer dulu ya!"),
                            ),
                          );
                          return;
                        }

                        await _markAsPaid(context);

                        if (!context.mounted) return;

                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HomeSiswaPage(),
                          ),
                          (route) => false,
                        );
                      },
                child: isUploading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Saya Sudah Bayar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
