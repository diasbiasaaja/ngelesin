// lib/login_guru.dart
import 'package:flutter/material.dart';
import 'package:ngelesin/pages/regis/regis_guru.dart';

import '../home_guru/home_guru_page.dart';

class LoginGuruPage extends StatefulWidget {
  const LoginGuruPage({super.key});

  @override
  State<LoginGuruPage> createState() => _LoginGuruPageState();
}

class _LoginGuruPageState extends State<LoginGuruPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  void _showMsg(String text, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: success ? Colors.green.shade600 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy credentials (ubah sesuai kebutuhan)
    const dummyEmail = "test@gmail.com";
    const dummyPass = "123456";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),

            // LOGO DI LUAR KOTAK
            Image.asset("assets/images/logo.png", width: 110),

            const SizedBox(height: 10),

            const Text(
              "LOGIN GURU",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1A44),
              ),
            ),

            const SizedBox(height: 35),

            // ================= KOTAK LOGIN =================
            Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF0A1A44), // navy border
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // EMAIL
                  TextField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD
                  TextField(
                    controller: passC,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // TOMBOL LOGIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final email = emailC.text.trim();
                        final pass = passC.text.trim();

                        if (email.isEmpty || pass.isEmpty) {
                          _showMsg("Email dan password harus diisi!");
                          return;
                        }

                        if (email == dummyEmail && pass == dummyPass) {
                          _showMsg("Login berhasil 🎉", success: true);

                          // navigasi ke halaman home guru (replace so user can't go back)
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const HomeGuruPage(),
                            ),
                          );
                        } else {
                          _showMsg("Email atau password salah!");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2C94C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        "LOGIN",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // BELUM PUNYA AKUN?
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun?"),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterGuru(),
                      ),
                    );
                  },
                  child: const Text(
                    "Daftar",
                    style: TextStyle(
                      color: Color(0xFF0A1A44),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
