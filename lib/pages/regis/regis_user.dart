import 'package:flutter/material.dart';

class RegisterMurid extends StatefulWidget {
  const RegisterMurid({super.key});

  @override
  State<RegisterMurid> createState() => _RegisterMuridState();
}

class _RegisterMuridState extends State<RegisterMurid> {
  final TextEditingController namaCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  final TextEditingController pass2Ctrl = TextEditingController();

  bool isPassHidden = true;
  bool isPass2Hidden = true;

  String? pendidikan;

  final List<String> pendidikanList = [
    "SD",
    "SMP",
    "SMA / SMK",
    "Mahasiswa",
    "Lainnya",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0A1A44)),
        title: const Text(
          "Daftar Murid",
          style: TextStyle(
            color: Color(0xFF0A1A44),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title("Data Diri Murid"),
            const SizedBox(height: 25),

            _inputField("Nama Lengkap", namaCtrl),
            const SizedBox(height: 15),

            _inputField("Email", emailCtrl),
            const SizedBox(height: 15),

            // PASSWORD
            _passwordField(
              label: "Password",
              controller: passCtrl,
              isHidden: isPassHidden,
              onToggle: () {
                setState(() => isPassHidden = !isPassHidden);
              },
            ),
            const SizedBox(height: 15),

            // KONFIRMASI PASSWORD
            _passwordField(
              label: "Konfirmasi Password",
              controller: pass2Ctrl,
              isHidden: isPass2Hidden,
              onToggle: () {
                setState(() => isPass2Hidden = !isPass2Hidden);
              },
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField(
              value: pendidikan,
              items: pendidikanList
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              decoration: _inputStyle("Pendidikan Terakhir"),
              onChanged: (v) => setState(() => pendidikan = v),
            ),

            const SizedBox(height: 30),

            _buttonYellow(text: "Daftar", onPressed: () {}),

            const SizedBox(height: 15),

            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "← Kembali ke Login",
                  style: TextStyle(
                    color: Color(0xFF0A1A44),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================== UI COMPONENTS =========================

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

  Widget _inputField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: _inputStyle(label),
    );
  }

  Widget _passwordField({
    required String label,
    required TextEditingController controller,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: isHidden,
      decoration: _inputStyle(label).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            isHidden ? Icons.visibility_off : Icons.visibility,
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
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
