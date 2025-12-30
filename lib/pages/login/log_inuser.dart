import 'package:flutter/material.dart';
import '../regis/regis_user.dart';
import '../home_siswa/home_siswa_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  bool isPasswordHidden = true;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 80),

            Image.asset("assets/images/logo.png", width: 110),

            const SizedBox(height: 15),

            const Text(
              "COLLAGE PRIVATE",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A1A44),
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 40),

            Container(
              width: 330,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Color(0xFF0A1A44), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
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

                  const SizedBox(height: 30),

                  // BUTTON LOGIN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        String email = emailC.text.trim();
                        String pass = passC.text.trim();

                        const dummyEmail = "test@gmail.com";
                        const dummyPass = "123456";

                        if (email == dummyEmail && pass == dummyPass) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Login Berhasil 🎉"),
                            ),
                          );

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (c) => const HomeSiswaPage(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text("Email atau password salah!"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF2C94C),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
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
                        builder: (context) => const RegisterMurid(),
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
