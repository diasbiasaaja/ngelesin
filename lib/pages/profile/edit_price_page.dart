import 'package:flutter/material.dart';
import '/dummy/dummy_user.dart';
import 'edit_price_page.dart';

const Color navy = Color(0xFF0A2A43);
const Color yellowAcc = Color(0xFFFFC947);
const Color softBg = Color(0xFFF7F8FA);

class EditPricePage extends StatefulWidget {
  const EditPricePage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AVATAR
            const Center(
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Color(0xFFE5E7EB),
                child: Icon(Icons.person, size: 36, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),

            // HARGA SATUAN
            _input(label: "Harga 1 Orang / sesi", controller: singlePriceC),

            const SizedBox(height: 20),

            // TOGGLE KELOMPOK
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

            // INPUT KELOMPOK
            if (isGroupActive) ...[
              _input(label: "Harga 1–5 Orang / sesi", controller: price1to5C),
              _input(label: "Harga 6–10 Orang / sesi", controller: price6to10C),
            ],

            const Spacer(),

            // BUTTON
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
                          // ✅ FIX UTAMA
                          currentUser.hargaPerJam = int.tryParse(
                            singlePriceC.text,
                          );

                          // nanti backend:
                          // simpan harga kelompok jika isGroupActive == true

                          Navigator.pop(
                            context,
                          ); // ⬅️ keluar dari EditPricePage
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
          ],
        ),
      ),
    );
  }

  // ================= INPUT FIELD =================
  Widget _input({
    required String label,
    required TextEditingController controller,
  }) {
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
