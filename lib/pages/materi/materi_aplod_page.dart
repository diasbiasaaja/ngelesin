import 'package:flutter/material.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class MateriUploadPage extends StatefulWidget {
  const MateriUploadPage({super.key});

  @override
  State<MateriUploadPage> createState() => _MateriUploadPageState();
}

class _MateriUploadPageState extends State<MateriUploadPage> {
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();

  String? fileName;

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

            // ===== UPLOAD FILE =====
            const Text(
              "File Materi",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () {
                // 🔹 dummy upload (nanti ganti file_picker)
                setState(() {
                  fileName = "materi_matematika.pdf";
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: navy.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file, color: navy),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fileName ?? "Pilih file (PDF / PPT)",
                        style: TextStyle(
                          color: fileName == null ? Colors.grey : Colors.black,
                        ),
                      ),
                    ),
                  ],
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
                onPressed: () {
                  // nanti kirim ke backend
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Materi berhasil disimpan (dummy)"),
                    ),
                  );
                },
                child: const Text(
                  "Simpan Materi",
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
