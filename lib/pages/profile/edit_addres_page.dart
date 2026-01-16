import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color navy = Color(0xFF0A2A43);
const Color yellowAcc = Color(0xFFFFC947);
const Color softBg = Color(0xFFF7F8FA);

class EditAddressPage extends StatefulWidget {
  const EditAddressPage({super.key});

  @override
  State<EditAddressPage> createState() => _EditAddressPageState();
}

class _EditAddressPageState extends State<EditAddressPage> {
  late TextEditingController jalanC;
  late TextEditingController desaC;
  late TextEditingController kecC;
  late TextEditingController rtC;
  late TextEditingController rumahC;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = true;
  String role = "guru"; // default

  @override
  void initState() {
    super.initState();

    jalanC = TextEditingController();
    desaC = TextEditingController();
    kecC = TextEditingController();
    rtC = TextEditingController();
    rumahC = TextEditingController();

    _loadAlamat();
  }

  // ================= DETECT ROLE + LOAD ADDRESS =================
  Future<void> _loadAlamat() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      // ✅ cek guru dulu
      final guruDoc = await _firestore.collection("guru").doc(uid).get();
      if (guruDoc.exists) {
        final data = guruDoc.data() ?? {};
        setState(() {
          role = "guru";
          jalanC.text = (data["jalan"] ?? "").toString();
          desaC.text = (data["desa"] ?? "").toString();
          kecC.text = (data["kecamatan"] ?? "").toString();
          rtC.text = (data["rt_rw"] ?? "").toString();
          rumahC.text = (data["no_rumah"] ?? "").toString();
          isLoading = false;
        });
        return;
      }

      // ✅ cek murid (pakai "murid", bukan "siswa" biar konsisten)
      final muridDoc = await _firestore.collection("murid").doc(uid).get();
      if (muridDoc.exists) {
        final data = muridDoc.data() ?? {};
        setState(() {
          role = "murid";
          jalanC.text = (data["jalan"] ?? "").toString();
          desaC.text = (data["desa"] ?? "").toString();
          kecC.text = (data["kecamatan"] ?? "").toString();
          rtC.text = (data["rt_rw"] ?? "").toString();
          rumahC.text = (data["no_rumah"] ?? "").toString();
          isLoading = false;
        });
        return;
      }

      // ✅ kalau murid doc belum ada sama sekali
      setState(() {
        role = "murid";
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // ================= SAVE ADDRESS =================
  Future<void> _saveAlamat() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final col = role == "guru" ? "guru" : "murid";

    final alamatFull =
        "${jalanC.text.trim()}, ${desaC.text.trim()}, ${kecC.text.trim()}, RT/RW ${rtC.text.trim()}, No ${rumahC.text.trim()}";

    // ✅ FIX UNIVERSAL:
    // - Guru: doc sudah ada -> update field
    // - Murid: doc bisa belum ada -> dibuat otomatis
    await _firestore.collection(col).doc(uid).set({
      "alamat": alamatFull,
      "jalan": jalanC.text.trim(),
      "desa": desaC.text.trim(),
      "kecamatan": kecC.text.trim(),
      "rt_rw": rtC.text.trim(),
      "no_rumah": rumahC.text.trim(),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  void dispose() {
    jalanC.dispose();
    desaC.dispose();
    kecC.dispose();
    rtC.dispose();
    rumahC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Alamat"),
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
                  _input("Nama Jalan", jalanC),
                  _input("Desa / Kelurahan", desaC),
                  _input("Kecamatan", kecC),
                  _input("RT / RW", rtC),
                  _input("No. Rumah", rumahC),

                  const SizedBox(height: 32),

                  Row(
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
                          onPressed: () async {
                            await _saveAlamat();
                            if (!mounted) return;
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Update",
                            style: TextStyle(fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
    );
  }

  // ================= INPUT =================
  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
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
}
