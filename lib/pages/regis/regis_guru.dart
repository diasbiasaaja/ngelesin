import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  XFile? ijazah;
  XFile? sertifikat;

  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

  /// show/hide password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// ================= CLOUDINARY =================
  final String cloudName = "dhamjmtwu";
  final String uploadPreset = "guru_unsigned"; // UNSIGNED

  /// ================= PICK IMAGE =================
  Future<void> pickImage(bool isIjazah) async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() {
        if (isIjazah) {
          ijazah = img;
        } else {
          sertifikat = img;
        }
      });
    }
  }

  /// ================= UPLOAD CLOUDINARY =================
  Future<String?> uploadToCloudinary(XFile file) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );

    final bytes = await file.readAsBytes();

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: file.name),
      );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'];
    }
    return null;
  }

  /// ================= REGISTER GURU =================
  Future<void> daftarGuru() async {
    if (namaCtrl.text.isEmpty ||
        emailCtrl.text.isEmpty ||
        hpCtrl.text.isEmpty ||
        alamatCtrl.text.isEmpty ||
        passwordCtrl.text.isEmpty ||
        confirmPasswordCtrl.text.isEmpty ||
        pendidikan == null ||
        ijazah == null ||
        sertifikat == null) {
      _msg("Lengkapi semua data & upload dokumen");
      return;
    }

    if (passwordCtrl.text != confirmPasswordCtrl.text) {
      _msg("Password tidak sama");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ AUTH
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtrl.text.trim(),
            password: passwordCtrl.text.trim(),
          );

      // 2️⃣ UPLOAD FOTO
      String? ijazahUrl = await uploadToCloudinary(ijazah!);
      String? sertifikatUrl = await uploadToCloudinary(sertifikat!);

      if (ijazahUrl == null || sertifikatUrl == null) {
        throw Exception("Upload gagal");
      }

      // 3️⃣ FIRESTORE
      await FirebaseFirestore.instance
          .collection("guru")
          .doc(userCred.user!.uid)
          .set({
            "uid": userCred.user!.uid,
            "nama": namaCtrl.text.trim(),
            "email": emailCtrl.text.trim(),
            "hp": hpCtrl.text.trim(),
            "alamat": alamatCtrl.text.trim(),
            "pendidikan": pendidikan,
            "ijazah_url": ijazahUrl,
            "sertifikat_url": sertifikatUrl,
            "role": "guru",
            "createdAt": Timestamp.now(),
          });

      _msg("Pendaftaran berhasil, silakan login");
      Navigator.pop(context);
    } catch (e) {
      _msg("Gagal daftar guru");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  // ================== STYLE HELPERS ==================
  static const Color navy = Color(0xFF0B1A3A);
  static const Color softGrey = Color(0xFFF1F1F1);
  static const Color yellowBtn = Color(0xFFF2C94C);

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: softGrey,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _space() => const SizedBox(height: 14);

  /// ================= UPLOAD UI (PREVIEW IMAGE) =================
  Widget _uploadBox({
    required String title,
    required XFile? file,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: softGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Stack(
          children: [
            // preview image
            if (file != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  file.path,
                  width: double.infinity,
                  height: 140,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // fallback kalau Image.network gak support di device tertentu
                    return Container(
                      height: 140,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              )
            else
              Container(
                height: 140,
                alignment: Alignment.center,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // overlay text
            if (file != null)
              Container(
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black.withOpacity(0.25),
                ),
              ),

            if (file != null)
              Positioned(
                left: 14,
                bottom: 14,
                child: Text(
                  "$title ✓",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),

            // button remove/change
            Positioned(
              right: 10,
              top: 10,
              child: Row(
                children: [
                  if (file != null)
                    InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete,
                          size: 18,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 18, color: navy),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: navy,
        centerTitle: true,
        title: const Text(
          "Daftar Guru",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // ================= PAGE 1 =================
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Data Diri Guru",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: namaCtrl,
                  decoration: _inputDecoration("Nama Lengkap"),
                ),
                _space(),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email"),
                ),
                _space(),
                TextField(
                  controller: hpCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("Nomor HP"),
                ),
                _space(),

                DropdownButtonFormField<String>(
                  value: pendidikan,
                  decoration: _inputDecoration("Pendidikan Terakhir").copyWith(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  items: const [
                    DropdownMenuItem(value: "SMA/SMK", child: Text("SMA/SMK")),
                    DropdownMenuItem(value: "Diploma", child: Text("Diploma")),
                    DropdownMenuItem(
                      value: "Sarjana (S1)",
                      child: Text("Sarjana (S1)"),
                    ),
                    DropdownMenuItem(
                      value: "Magister (S2)",
                      child: Text("Magister (S2)"),
                    ),
                    DropdownMenuItem(
                      value: "Doktor (S3)",
                      child: Text("Doktor (S3)"),
                    ),
                  ],
                  onChanged: (v) => setState(() => pendidikan = v),
                ),

                _space(),
                TextField(
                  controller: alamatCtrl,
                  decoration: _inputDecoration("Alamat Lengkap"),
                ),
                _space(),

                // PASSWORD WITH EYE
                TextField(
                  controller: passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration("Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                _space(),

                // CONFIRM PASSWORD WITH EYE
                TextField(
                  controller: confirmPasswordCtrl,
                  obscureText: _obscureConfirmPassword,
                  decoration: _inputDecoration("Konfirmasi Password").copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () {
                        setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 26),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: navy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text(
                      "Lanjut →",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ================= PAGE 2 =================
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upload Dokumen",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: navy,
                  ),
                ),
                const SizedBox(height: 24),

                _uploadBox(
                  title: "Upload Foto Ijazah",
                  file: ijazah,
                  onTap: () => pickImage(true),
                  onRemove: () {
                    setState(() => ijazah = null);
                  },
                ),

                const SizedBox(height: 18),

                _uploadBox(
                  title: "Upload Foto Sertifikat",
                  file: sertifikat,
                  onTap: () => pickImage(false),
                  onRemove: () {
                    setState(() => sertifikat = null);
                  },
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowBtn,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                    ),
                    onPressed: isLoading ? null : daftarGuru,
                    child: Text(
                      isLoading ? "Loading..." : "Selesai Daftar",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text(
                      "← Kembali",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: navy,
                      ),
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
}
