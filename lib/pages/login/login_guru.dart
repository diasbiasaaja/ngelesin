import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  bool isPasswordHidden = true;
  bool isLoading = false;

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
        backgroundColor: success ? Colors.green : null,
      ),
    );
  }

  // ================= LOGIN GURU (FIREBASE) =================
  Future<void> loginGuru() async {
    final email = emailC.text.trim();
    final pass = passC.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      _showMsg("Email dan password harus diisi!");
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1️⃣ LOGIN FIREBASE AUTH
      UserCredential userCred =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      // 2️⃣ CEK DATA GURU DI FIRESTORE
      final doc = await FirebaseFirestore.instance
          .collection("guru")
          .doc(userCred.user!.uid)
          .get();

      if (!doc.exists) {
        await FirebaseAuth.instance.signOut();
        throw Exception("Akun ini bukan guru");
      }

      _showMsg("Login berhasil 🎉", success: true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeGuruPage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = "Login gagal";

      if (e.code == 'user-not-found') {
        msg = "Email belum terdaftar";
      } else if (e.code == 'wrong-password') {
        msg = "Password salah";
      }

      _showMsg(msg);
    } catch (e) {
      _showMsg("Login gagal");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 70),

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

            Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color(0xFF0A1A44), width: 3),
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

                  // PASSWORD
                  TextField(
                    controller: passC,
                    obscureText: isPasswordHidden,
                    decoration: InputDecoration(
                      labelText: "Password",
                      filled: true,
                      fillColor: Colors.grey[200],
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
                      onPressed: isLoading ? null : loginGuru,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2C94C),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        isLoading ? "Loading..." : "LOGIN",
                        style: const TextStyle(
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
                        builder: (_) => const RegisterGuru(),
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
