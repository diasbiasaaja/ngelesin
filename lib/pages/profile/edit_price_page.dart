import 'package:flutter/material.dart';
import '/dummy/dummy_user.dart';

const Color navy = Color(0xFF0A2A43);
const Color yellowAcc = Color(0xFFFFC947);
const Color softBg = Color(0xFFF7F8FA);

class EditPricePage extends StatefulWidget {
  // 🔥 MAPEL DARI HALAMAN SEBELUMNYA
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

  late TextEditingController singlePriceC;
  late TextEditingController price1to5C;
  late TextEditingController price6to10C;

  @override
  void initState() {
    super.initState();
    singlePriceC = TextEditingController(
      text: currentUser.hargaPerJam?.toString() ?? '',
    );
    price1to5C = TextEditingController();
    price6to10C = TextEditingController();

    // 🔍 CEK DATA MAPEL MASUK
    debugPrint("MAPEL SD   : ${widget.sdMapel}");
    debugPrint("MAPEL SMP  : ${widget.smpMapel}");
    debugPrint("MAPEL SMA  : ${widget.smaMapel}");
  }

  @override
  void dispose() {
    singlePriceC.dispose();
    price1to5C.dispose();
    price6to10C.dispose();
    super.dispose();
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
      body: SingleChildScrollView(
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

            // ================= INFO MAPEL (OPTIONAL DISPLAY) =================
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
                    setState(() => isGroupActive = val);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

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
                  onPressed: () {
                    // ================= SIMPAN =================
                    currentUser.hargaPerJam = int.tryParse(singlePriceC.text);

                    // TODO: simpan harga kelompok kalau aktif
                    // price1to5C.text
                    // price6to10C.text

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
