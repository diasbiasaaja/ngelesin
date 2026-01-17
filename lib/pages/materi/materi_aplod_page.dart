import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class MateriUploadPage extends StatefulWidget {
  final String bookingId;
  final String muridUid;
  final String guruUid;
  final String mapel;
  final String muridNama;
  final String tanggal;
  final String jam;

  const MateriUploadPage({
    super.key,
    required this.bookingId,
    required this.muridUid,
    required this.guruUid,
    required this.mapel,
    required this.muridNama,
    required this.tanggal,
    required this.jam,
  });

  @override
  State<MateriUploadPage> createState() => _MateriUploadPageState();
}

class _MateriUploadPageState extends State<MateriUploadPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController linkController = TextEditingController();

  bool loading = false;

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isScheme("http") || uri.isScheme("https"));
  }

  Future<void> _saveMateri() async {
    final judul = judulController.text.trim();
    final deskripsi = deskripsiController.text.trim();
    final link = linkController.text.trim();

    if (judul.isEmpty || link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Judul dan Link wajib diisi")),
      );
      return;
    }

    if (!_isValidUrl(link)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Link tidak valid (harus http/https)")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // ✅ 1) simpan ke Firestore
      // materi/{bookingId}/items/{autoId}
      final materiRef = FirebaseFirestore.instance
          .collection("materi")
          .doc(widget.bookingId)
          .collection("items");

      await materiRef.add({
        "bookingId": widget.bookingId,
        "guruUid": widget.guruUid,
        "muridUid": widget.muridUid,
        "mapel": widget.mapel,
        "muridNama": widget.muridNama,
        "judul": judul,
        "deskripsi": deskripsi,
        "link": link,
        "createdAt": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Materi berhasil dikirim ✅")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal simpan materi: $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ================= APPBAR =================
      appBar: AppBar(
        backgroundColor: navy,
        title: const Text("Upload Materi"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ================= BODY =================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${widget.mapel} - ${widget.muridNama}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              "${widget.tanggal} • ${widget.jam}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // ===== JUDUL =====
            const Text(
              "Judul Materi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: judulController,
              decoration: InputDecoration(
                hintText: "Contoh: Persamaan Linear",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ===== DESKRIPSI =====
            const Text(
              "Deskripsi Materi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "Tuliskan penjelasan materi...",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ✅ LINK MATERI
            const Text(
              "Link Materi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: linkController,
              decoration: InputDecoration(
                hintText: "https://drive.google.com/... / youtube / pdf link",
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== BUTTON SIMPAN =====
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: yellowAcc,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: loading ? null : _saveMateri,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        "Kirim Materi",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
