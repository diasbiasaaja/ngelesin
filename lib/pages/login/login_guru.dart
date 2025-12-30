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

  bool isPasswordHidden = true; // 🔥 NEW

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
    // Dummy credentials
    const dummyEmail = "test@gmail.com";
    const dummyPass = "123456";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),

            // LOGO
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
                  color: Color(0xFF0A1A44),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // EMAIL
                  TextField(
                    controller: emailC,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // PASSWORD (SHOW / HIDE)
                  TextField(
                    controller: passC,
                    obscureText: isPasswordHidden,
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.grey[200],

                      // 👁️ ICON MATA
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordHidden
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordHidden = !isPasswordHidden;
                          });
                        },
                      ),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // BUTTON LOGIN
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

            // DAFTAR
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
