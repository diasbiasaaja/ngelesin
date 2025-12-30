import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterGuru extends StatefulWidget {
  const RegisterGuru({super.key});

  @override
  State<RegisterGuru> createState() => _RegisterGuruState();
}

class _RegisterGuruState extends State<RegisterGuru> {
  final PageController _pageController = PageController();

  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController hpCtrl = TextEditingController();
  final TextEditingController alamatCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController confirmPasswordCtrl = TextEditingController();

  String? pendidikan;
  File? ijazah;
  File? sertifikat;

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  final picker = ImagePicker();

  Future pilihFoto(bool isIjazah) async {
    final foto = await picker.pickImage(source: ImageSource.gallery);
    if (foto != null) {
      setState(() {
        if (isIjazah) {
          ijazah = File(foto.path);
        } else {
          sertifikat = File(foto.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0A1A44)),
        title: const Text(
          "Daftar Guru",
          style: TextStyle(
            color: Color(0xFF0A1A44),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ========================= SLIDE 1 ==========================
          SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title("Data Diri Guru"),
                const SizedBox(height: 25),

                _inputField("Nama Lengkap", namaCtrl),
                const SizedBox(height: 15),

                _inputField("Email", emailCtrl),
                const SizedBox(height: 15),

                _inputField("Nomor HP", hpCtrl),
                const SizedBox(height: 15),

                DropdownButtonFormField(
                  value: pendidikan,
                  items: [
                    "SMA/SMK",
                    "Diploma",
                    "Sarjana (S1)",
                    "Magister (S2)",
                    "Doktor (S3)",
                  ]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  decoration: _inputStyle("Pendidikan Terakhir"),
                  onChanged: (v) => setState(() => pendidikan = v),
                ),

                const SizedBox(height: 15),

                _inputField("Alamat Lengkap", alamatCtrl),
                const SizedBox(height: 15),

                // PASSWORD
                _passwordField(
                  label: "Password",
                  controller: passwordCtrl,
                  isHidden: hidePassword,
                  onToggle: () {
                    setState(() => hidePassword = !hidePassword);
                  },
                ),

                const SizedBox(height: 15),

                // KONFIRMASI PASSWORD
                _passwordField(
                  label: "Konfirmasi Password",
                  controller: confirmPasswordCtrl,
                  isHidden: hideConfirmPassword,
                  onToggle: () {
                    setState(() =>
                        hideConfirmPassword = !hideConfirmPassword);
                  },
                ),

                const SizedBox(height: 30),

                _buttonNavy(
                  text: "Lanjut →",
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ],
            ),
          ),

          // ========================= SLIDE 2 ==========================
          SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _title("Upload Dokumen"),
                const SizedBox(height: 25),

                _uploadBoxWidget(
                  label: "Upload Foto Ijazah",
                  file: ijazah,
                  onTap: () => pilihFoto(true),
                ),

                const SizedBox(height: 20),

                _uploadBoxWidget(
                  label: "Upload Foto Sertifikat",
                  file: sertifikat,
                  onTap: () => pilihFoto(false),
                ),

                const SizedBox(height: 30),

                _buttonYellow(
                  text: "Selesai Daftar",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),

                const SizedBox(height: 12),

                Center(
                  child: TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text(
                      "← Kembali",
                      style: TextStyle(color: Color(0xFF0A1A44)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================== UI COMPONENT =========================

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: Color(0xFF0A1A44),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: _inputStyle(label),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool isHidden,
    required Function() onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      decoration: _inputStyle(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _uploadBoxWidget({
    required String label,
    required File? file,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade400),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: file == null
            ? Center(
                child: Text(
                  label,
                  style:
                      const TextStyle(color: Colors.black54, fontSize: 15),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(file, fit: BoxFit.cover),
              ),
      ),
    );
  }

  Widget _buttonNavy({required String text, required Function() onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0A1A44),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buttonYellow({required String text, required Function() onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF2C94C),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
