import 'package:flutter/material.dart';
import '/dummy/dummy_user.dart';

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

  @override
  void initState() {
    super.initState();
    // dummy sementara, nanti bisa diambil dari model
    jalanC = TextEditingController(text: "Leles");
    desaC = TextEditingController(text: "Burangrang");
    kecC = TextEditingController(text: "Baleendah");
    rtC = TextEditingController(text: "008/009");
    rumahC = TextEditingController(text: "12");
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
      body: SingleChildScrollView(
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
                    onPressed: () {
                      currentUser.alamat =
                          "${jalanC.text}, ${desaC.text}, ${kecC.text}, "
                          "RT/RW ${rtC.text}, No ${rumahC.text}";
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
