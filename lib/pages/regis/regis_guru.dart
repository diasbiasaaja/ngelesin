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

  // WEB-SAFE
  XFile? ijazah;
  XFile? sertifikat;

  bool isLoading = false;

  final ImagePicker picker = ImagePicker();

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
    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final bytes = await file.readAsBytes();

    final request = http.MultipartRequest("POST", uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
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
      UserCredential userCred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailCtrl.text.trim(),
        password: passwordCtrl.text.trim(),
      );

      // 2️⃣ UPLOAD FOTO
      String? ijazahUrl = await uploadToCloudinary(ijazah!);
      String? sertifikatUrl = await uploadToCloudinary(sertifikat!);

      if (ijazahUrl == null || sertifikatUrl == null) {
        throw Exception("Upload gagal");
      }

      // 3️⃣ FIRESTORE (TANPA VERIFIKASI)
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
      Navigator.pop(context); // balik ke login
    } catch (e) {
      _msg("Gagal daftar guru");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _msg(String t) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(t)));
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Guru")),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // PAGE 1
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Data Diri Guru",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                TextField(
                    controller: namaCtrl,
                    decoration:
                        const InputDecoration(labelText: "Nama Lengkap")),
                TextField(
                    controller: emailCtrl,
                    decoration:
                        const InputDecoration(labelText: "Email")),
                TextField(
                    controller: hpCtrl,
                    decoration:
                        const InputDecoration(labelText: "Nomor HP")),
                DropdownButtonFormField<String>(
                  value: pendidikan,
                  decoration: const InputDecoration(
                      labelText: "Pendidikan Terakhir"),
                  items: const [
                    DropdownMenuItem(
                        value: "SMA/SMK", child: Text("SMA/SMK")),
                    DropdownMenuItem(
                        value: "Diploma", child: Text("Diploma")),
                    DropdownMenuItem(
                        value: "Sarjana (S1)",
                        child: Text("Sarjana (S1)")),
                    DropdownMenuItem(
                        value: "Magister (S2)",
                        child: Text("Magister (S2)")),
                    DropdownMenuItem(
                        value: "Doktor (S3)",
                        child: Text("Doktor (S3)")),
                  ],
                  onChanged: (v) => setState(() => pendidikan = v),
                ),
                TextField(
                    controller: alamatCtrl,
                    decoration:
                        const InputDecoration(labelText: "Alamat Lengkap")),
                TextField(
                    controller: passwordCtrl,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "Password")),
                TextField(
                    controller: confirmPasswordCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                        labelText: "Konfirmasi Password")),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Text("Lanjut →"),
                  ),
                ),
              ],
            ),
          ),

          // PAGE 2
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(true),
                  child: Text(
                      ijazah == null ? "Upload Ijazah" : "Ijazah Dipilih"),
                ),
                ElevatedButton(
                  onPressed: () => pickImage(false),
                  child: Text(sertifikat == null
                      ? "Upload Sertifikat"
                      : "Sertifikat Dipilih"),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : daftarGuru,
                    child:
                        Text(isLoading ? "Loading..." : "Selesai Daftar"),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Text("← Kembali"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
