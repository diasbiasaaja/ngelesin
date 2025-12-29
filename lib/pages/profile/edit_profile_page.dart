import 'package:flutter/material.dart';
import '/dummy/dummy_user.dart';
import '/models/usermodel.dart';
import 'edit_price_page.dart';

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

  @override
  void initState() {
    super.initState();
    namaC = TextEditingController(text: currentUser.nama);
    emailC = TextEditingController(text: "dias@sariawangmail.com");
    telpC = TextEditingController(text: "0889******59");
    passwordC = TextEditingController(text: "********");
    bioC = TextEditingController(text: currentUser.bio ?? "");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Data Pribadi"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ================= FOTO PROFIL =================
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      // NANTI: Image Picker
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: const Color(0xFFE5E7EB),
                          child: const Icon(
                            Icons.person,
                            size: 42,
                            color: Colors.grey,
                          ),
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
                            child: const Icon(
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
                  const Text("Ubah Foto Profil", style: TextStyle(color: navy)),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ================= FORM =================
            _input("Nama Lengkap", namaC),
            _input("Email", emailC),
            _input("No. Telepon", telpC),
            _input("Password", passwordC, isPassword: true),

            // ================= BIO (KHUSUS GURU) =================
            if (currentUser.role == UserRole.guru) ...[
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
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          currentUser.nama = namaC.text;

                          if (currentUser.role == UserRole.guru) {
                            currentUser.bio = bioC.text;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditPricePage(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          currentUser.role == UserRole.guru
                              ? "Lanjut"
                              : "Update",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: navy,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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

  // ================= INPUT BIASA =================
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

  // ================= INPUT BIO =================
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
