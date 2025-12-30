import 'package:flutter/material.dart';
import 'edit_price_page.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class EditProfileGuruPage extends StatefulWidget {
  const EditProfileGuruPage({super.key});

  @override
  State<EditProfileGuruPage> createState() => _EditProfileGuruPageState();
}

class _EditProfileGuruPageState extends State<EditProfileGuruPage> {
  /// 🔥 MAPEL TERPILIH (BISA BANYAK)
  final Set<String> selectedMapel = {};

  void toggleMapel(String mapel) {
    setState(() {
      if (selectedMapel.contains(mapel)) {
        selectedMapel.remove(mapel);
      } else {
        selectedMapel.add(mapel);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Mapel yang Diampu"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: navy,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilih Mata Pelajaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: navy,
              ),
            ),

            const SizedBox(height: 16),

            // ================= SD =================
            _tingkatanCard(
              title: "SD",
              subjects: const [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indonesia"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_soccer_rounded, "name": "PJOK"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
              ],
            ),

            // ================= SMP =================
            _tingkatanCard(
              title: "SMP",
              subjects: const [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indonesia"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_basketball_rounded, "name": "PJOK"},
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.brush_rounded, "name": "Seni Budaya"},
              ],
            ),

            // ================= SMA =================
            _tingkatanCard(
              title: "SMA",
              subjects: const [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indonesia"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.history_edu_rounded, "name": "Sejarah"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "Agama"},
                {"icon": Icons.science_rounded, "name": "Fisika"},
                {"icon": Icons.bubble_chart_rounded, "name": "Kimia"},
                {"icon": Icons.biotech_rounded, "name": "Biologi"},
                {"icon": Icons.public_rounded, "name": "Geografi"},
                {"icon": Icons.groups_rounded, "name": "Sosiologi"},
                {"icon": Icons.attach_money_rounded, "name": "Ekonomi"},
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.sports_martial_arts_rounded, "name": "PJOK"},
              ],
            ),
          ],
        ),
      ),

      // ================= SIMPAN =================
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: yellowAcc,
              foregroundColor: navy,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: selectedMapel.isEmpty
                ? null
                : () {
                    debugPrint("Mapel dipilih: $selectedMapel");

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditPricePage()),
                    );
                  },
            child: const Text(
              "Lanjut Atur Harga",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ================= TINGKATAN CARD =================
  Widget _tingkatanCard({
    required String title,
    required List<Map<String, dynamic>> subjects,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 18),

          Wrap(
            spacing: 22,
            runSpacing: 20,
            children: subjects.map((item) {
              final isSelected = selectedMapel.contains(item["name"]);

              return GestureDetector(
                onTap: () => toggleMapel(item["name"]),
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? yellowAcc : Colors.white,
                        border: Border.all(
                          color: isSelected ? yellowAcc : navy.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        item["icon"],
                        size: 30,
                        color: isSelected ? Colors.white : navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 90,
                      child: Text(
                        item["name"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
