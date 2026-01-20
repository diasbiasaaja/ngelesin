import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'edit_mapel_ampu.dart'; // halaman khusus guru

const Color navy = Color(0xFF0A2A43);
const Color yellowAcc = Color(0xFFFFC947);
const Color softBg = Color(0xFFF7F8FA);

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController namaC;
  late TextEditingController emailC;
  late TextEditingController telpC;
  late TextEditingController passwordC;
  late TextEditingController bioC;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  bool isUploadingFoto = false;

  String role = "guru"; // default

  // ===== FOTO PROFIL =====
  String fotoUrl = ""; // dari firestore
  File? fotoFile; // mobile
  Uint8List? fotoBytes; // web
  String? fotoName;

  // ===== CLOUDINARY CONFIG =====
  final String cloudName = "dhamjmtwu";
  final String uploadPreset = "guru_unsigned";
  final String folderCloudinary = "guru_docs";

  @override
  void initState() {
    super.initState();

    namaC = TextEditingController();
    emailC = TextEditingController();
    telpC = TextEditingController();
    passwordC = TextEditingController();
    bioC = TextEditingController();

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // ✅ cek guru dulu
      final guruDoc = await _firestore.collection("guru").doc(uid).get();
      if (guruDoc.exists) {
        final data = guruDoc.data()!;
        setState(() {
          role = "guru";
          namaC.text = (data["nama"] ?? "").toString();
          emailC.text = (data["email"] ?? "").toString();
          telpC.text = (data["hp"] ?? "").toString();
          bioC.text = (data["bio"] ?? "").toString();
          fotoUrl = (data["foto_url"] ?? "").toString();
          isLoading = false;
        });
        return;
      }

      // ✅ cek murid
      final muridDoc = await _firestore.collection("murid").doc(uid).get();
      if (muridDoc.exists) {
        final data = muridDoc.data()!;
        setState(() {
          role = "murid";
          namaC.text = (data["nama"] ?? "").toString();
          emailC.text = (data["email"] ?? "").toString();
          telpC.text = (data["hp"] ?? "").toString();
          fotoUrl = (data["foto_url"] ?? "").toString();
          isLoading = false;
        });
        return;
      }

      setState(() => isLoading = false);
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _save() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final col = role == "guru" ? "guru" : "murid";

    await _firestore.collection(col).doc(uid).update({
      "nama": namaC.text.trim(),
      "email": emailC.text.trim(),
      "hp": telpC.text.trim(),
      if (role == "guru") "bio": bioC.text.trim(),
      // ✅ simpan foto
      "foto_url": fotoUrl,
    });

    // update email auth kalau berubah
    final currentEmail = _auth.currentUser?.email;
    if (emailC.text.trim().isNotEmpty && emailC.text.trim() != currentEmail) {
      await _auth.currentUser?.updateEmail(emailC.text.trim());
    }

    // update password auth kalau user isi password
    if (passwordC.text.trim().isNotEmpty) {
      await _auth.currentUser?.updatePassword(passwordC.text.trim());
    }
  }

  // ================= FOTO PROFILE =================

  Future<void> _pickFoto() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );

    if (xFile == null) return;

    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      setState(() {
        fotoBytes = bytes;
        fotoName = xFile.name;
        fotoFile = null;
      });
    } else {
      setState(() {
        fotoFile = File(xFile.path);
        fotoBytes = null;
        fotoName = xFile.name;
      });
    }

    // ✅ auto upload setelah pilih
    await _uploadFotoToCloudinary();
  }

  Future<String?> _uploadCloudinary({
    File? file,
    Uint8List? bytes,
    String? filename,
  }) async {
    try {
      final uri = Uri.parse(
        "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
      );

      final request = http.MultipartRequest("POST", uri);
      request.fields["upload_preset"] = uploadPreset;
      request.fields["folder"] = folderCloudinary;

      if (kIsWeb) {
        if (bytes == null) return null;
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            bytes,
            filename: filename ?? "profile.jpg",
          ),
        );
      } else {
        if (file == null) return null;
        request.files.add(await http.MultipartFile.fromPath("file", file.path));
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

  Future<void> _uploadFotoToCloudinary() async {
    try {
      setState(() => isUploadingFoto = true);

      final url = await _uploadCloudinary(
        file: fotoFile,
        bytes: fotoBytes,
        filename: fotoName,
      );

      if (url == null || url.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Upload foto gagal ❌")));
        }
        return;
      }

      // ✅ update foto url
      setState(() {
        fotoUrl = url;
      });

      // ✅ simpan ke firestore langsung biar realtime
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        final col = role == "guru" ? "guru" : "murid";
        await _firestore.collection(col).doc(uid).update({"foto_url": url});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil diubah ✅")),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Upload foto gagal ❌")));
      }
    } finally {
      if (mounted) setState(() => isUploadingFoto = false);
    }
  }

  @override
  void dispose() {
    namaC.dispose();
    emailC.dispose();
    telpC.dispose();
    passwordC.dispose();
    bioC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGuru = role == "guru";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Data Pribadi"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ================= FOTO PROFIL =================
                  Center(
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: isUploadingFoto ? null : _pickFoto,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 42,
                                backgroundColor: const Color(0xFFE5E7EB),
                                backgroundImage: (fotoUrl.isNotEmpty)
                                    ? NetworkImage(fotoUrl)
                                    : null,
                                child: (fotoUrl.isEmpty)
                                    ? const Icon(
                                        Icons.person,
                                        size: 42,
                                        color: Colors.grey,
                                      )
                                    : null,
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: yellowAcc,
                                    shape: BoxShape.circle,
                                  ),
                                  child: isUploadingFoto
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: navy,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: navy,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Ubah Foto Profil",
                          style: TextStyle(color: navy),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ================= FORM =================
                  _input("Nama Lengkap", namaC),
                  _input("Email", emailC),
                  _input("No. Telepon", telpC),
                  _input(
                    "Password (isi jika ingin ganti)",
                    passwordC,
                    isPassword: true,
                  ),

                  if (isGuru) ...[
                    const SizedBox(height: 8),
                    _bioInput("Bio Guru", bioC),
                  ],

                  const SizedBox(height: 32),

                  // ================= BUTTON =================
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellowAcc,
                                foregroundColor: navy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () async {
                                await _save();

                                if (isGuru) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const EditProfileGuruPage(),
                                    ),
                                  );
                                } else {
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                isGuru ? "Lanjut" : "Simpan",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: navy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: const BorderSide(color: navy),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Kembali"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: softBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _bioInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          hintText:
              "Ceritakan pengalaman, metode mengajar, dan keunggulan Anda",
          filled: true,
          fillColor: softBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: navy, width: 1.5),
          ),
        ),
      ),
    );
  }
}
