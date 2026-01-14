import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color navy = Color(0xFF0A2A43);
const Color yellowAcc = Color(0xFFFFC947);
const Color softBg = Color(0xFFF7F8FA);

class EditPricePage extends StatefulWidget {
  final Set<String> sdMapel;
  final Set<String> smpMapel;
  final Set<String> smaMapel;

  const EditPricePage({
    super.key,
    required this.sdMapel,
    required this.smpMapel,
    required this.smaMapel,
  });

  @override
  State<EditPricePage> createState() => _EditPricePageState();
}

class _EditPricePageState extends State<EditPricePage> {
  bool isGroupActive = false;
  bool isLoading = true;

  late TextEditingController singlePriceC;
  late TextEditingController price1to5C;
  late TextEditingController price6to10C;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    singlePriceC = TextEditingController();
    price1to5C = TextEditingController();
    price6to10C = TextEditingController();

    _loadHargaGuru();
  }

  Future<void> _loadHargaGuru() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc = await _firestore.collection("guru").doc(uid).get();
      final data = doc.data();

      if (data == null) {
        setState(() => isLoading = false);
        return;
      }

      // ambil string nya dulu biar aman
      final hargaSingle = (data["harga_per_jam"] ?? "").toString();
      final harga1to5 = (data["harga_1_5"] ?? "").toString();
      final harga6to10 = (data["harga_6_10"] ?? "").toString();

      setState(() {
        singlePriceC.text = hargaSingle;
        price1to5C.text = harga1to5;
        price6to10C.text = harga6to10;

        // ✅ switch otomatis ON kalau ada salah satu harga kelompok berisi
        isGroupActive =
            (harga1to5.isNotEmpty && harga1to5 != "0") ||
            (harga6to10.isNotEmpty && harga6to10 != "0");

        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    singlePriceC.dispose();
    price1to5C.dispose();
    price6to10C.dispose();
    super.dispose();
  }

  Future<void> _saveHarga() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection("guru").doc(uid).update({
      "harga_per_jam": int.tryParse(singlePriceC.text.trim()) ?? 0,

      // ✅ kalau switch OFF → kosongkan harga kelompok
      "harga_1_5": isGroupActive
          ? (int.tryParse(price1to5C.text.trim()) ?? 0)
          : null,
      "harga_6_10": isGroupActive
          ? (int.tryParse(price6to10C.text.trim()) ?? 0)
          : null,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Atur Harga"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
      ),

      // ================= BODY =================
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 32,
                      backgroundColor: Color(0xFFE5E7EB),
                      child: Icon(Icons.person, size: 36, color: Colors.grey),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ================= INFO MAPEL =================
                  if (widget.sdMapel.isNotEmpty) ...[
                    Text("Mapel SD: ${widget.sdMapel.join(', ')}"),
                    const SizedBox(height: 6),
                  ],
                  if (widget.smpMapel.isNotEmpty) ...[
                    Text("Mapel SMP: ${widget.smpMapel.join(', ')}"),
                    const SizedBox(height: 6),
                  ],
                  if (widget.smaMapel.isNotEmpty) ...[
                    Text("Mapel SMA: ${widget.smaMapel.join(', ')}"),
                    const SizedBox(height: 12),
                  ],

                  _input("Harga 1 Orang / sesi", singlePriceC),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Harga Lebih Dari 1 Orang",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: navy,
                          ),
                        ),
                      ),
                      Switch(
                        value: isGroupActive,
                        activeColor: yellowAcc,
                        onChanged: (val) {
                          setState(() {
                            isGroupActive = val;

                            // ✅ kalau dimatiin switch, kosongin field biar ga ke-save lagi
                            if (!isGroupActive) {
                              price1to5C.clear();
                              price6to10C.clear();
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ✅ INI YANG KAMU MAU: otomatis tampil kalau isGroupActive true
                  if (isGroupActive) ...[
                    _input("Harga 1–5 Orang / sesi", price1to5C),
                    _input("Harga 6–10 Orang / sesi", price6to10C),
                  ],
                ],
              ),
            ),

      // ================= BUTTON FIXED =================
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, -3),
              ),
            ],
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
                  onPressed: () async {
                    await _saveHarga();

                    Navigator.pop(context);
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ubah",
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
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _input(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
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
