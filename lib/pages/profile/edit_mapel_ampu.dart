import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_price_page.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class EditProfileGuruPage extends StatefulWidget {
  const EditProfileGuruPage({super.key});

  @override
  State<EditProfileGuruPage> createState() => _EditProfileGuruPageState();
}

class _EditProfileGuruPageState extends State<EditProfileGuruPage> {
  // ================= STATE PER JENJANG =================
  final Set<String> selectedSD = {};
  final Set<String> selectedSMP = {};
  final Set<String> selectedSMA = {};

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  bool isLoading = true;

  // ================= DATA =================
  final sdSubjects = const [
    {"icon": Icons.calculate_rounded, "name": "Matematika"},
    {"icon": Icons.menu_book_rounded, "name": "Bahasa Indonesia"},
    {"icon": Icons.science_rounded, "name": "IPA"},
    {"icon": Icons.public_rounded, "name": "IPS"},
    {"icon": Icons.flag_rounded, "name": "PPKn"},
    {"icon": Icons.mosque_rounded, "name": "PAI"},
    {"icon": Icons.sports_soccer_rounded, "name": "PJOK"},
    {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
    {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
  ];

  final smpSubjects = const [
    {"icon": Icons.calculate_rounded, "name": "Matematika"},
    {"icon": Icons.menu_book_rounded, "name": "Bahasa Indonesia"},
    {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
    {"icon": Icons.science_rounded, "name": "IPA"},
    {"icon": Icons.public_rounded, "name": "IPS"},
    {"icon": Icons.flag_rounded, "name": "PPKn"},
    {"icon": Icons.mosque_rounded, "name": "PAI"},
    {"icon": Icons.sports_basketball_rounded, "name": "PJOK"},
    {"icon": Icons.computer_rounded, "name": "Informatika"},
    {"icon": Icons.brush_rounded, "name": "Seni Budaya"},
  ];

  final smaSubjects = const [
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
  ];

  @override
  void initState() {
    super.initState();
    _loadMapelFromFirestore();
  }

  // ================= LOAD MAPEL FROM FIRESTORE =================
  Future<void> _loadMapelFromFirestore() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final doc = await _firestore.collection("guru").doc(uid).get();
      final data = doc.data();

      if (data != null) {
        final List sd = (data["mapel_sd"] ?? []);
        final List smp = (data["mapel_smp"] ?? []);
        final List sma = (data["mapel_sma"] ?? []);

        setState(() {
          selectedSD.addAll(sd.map((e) => e.toString()));
          selectedSMP.addAll(smp.map((e) => e.toString()));
          selectedSMA.addAll(sma.map((e) => e.toString()));
        });
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= SAVE MAPEL TO FIRESTORE =================
  Future<void> _saveMapelToFirestore() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _firestore.collection("guru").doc(uid).update({
      "mapel_sd": selectedSD.toList(),
      "mapel_smp": selectedSMP.toList(),
      "mapel_sma": selectedSMA.toList(),
    });
  }

  // ================= LOGIC =================
  void toggle(Set<String> selected, String mapel) {
    setState(() {
      selected.contains(mapel) ? selected.remove(mapel) : selected.add(mapel);
    });
  }

  void selectAll(Set<String> selected, List<Map<String, dynamic>> subjects) {
    setState(() {
      for (final item in subjects) {
        selected.add(item["name"]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final circleSize = width < 360
        ? 56.0
        : width > 600
        ? 72.0
        : 64.0;
    final iconSize = width < 360
        ? 24.0
        : width > 600
        ? 32.0
        : 28.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Mapel Ampu"),
        foregroundColor: navy,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _section(
                    title: "SD",
                    subjects: sdSubjects,
                    selected: selectedSD,
                    circleSize: circleSize,
                    iconSize: iconSize,
                  ),
                  _section(
                    title: "SMP",
                    subjects: smpSubjects,
                    selected: selectedSMP,
                    circleSize: circleSize,
                    iconSize: iconSize,
                  ),
                  _section(
                    title: "SMA",
                    subjects: smaSubjects,
                    selected: selectedSMA,
                    circleSize: circleSize,
                    iconSize: iconSize,
                  ),
                ],
              ),
            ),

      // ================= TOMBOL LANJUT =================
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
            onPressed:
                (selectedSD.isEmpty &&
                    selectedSMP.isEmpty &&
                    selectedSMA.isEmpty)
                ? null
                : () async {
                    await _saveMapelToFirestore();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditPricePage(
                          sdMapel: selectedSD,
                          smpMapel: selectedSMP,
                          smaMapel: selectedSMA,
                        ),
                      ),
                    );
                  },
            child: const Text(
              "Lanjut",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  // ================= SECTION =================
  Widget _section({
    required String title,
    required List<Map<String, dynamic>> subjects,
    required Set<String> selected,
    required double circleSize,
    required double iconSize,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.06)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              TextButton(
                onPressed: () => selectAll(selected, subjects),
                child: const Text(
                  "Pilih Semua",
                  style: TextStyle(color: yellowAcc),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ICON GRID
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: subjects.map((item) {
              final isSelected = selected.contains(item["name"]);

              return GestureDetector(
                onTap: () => toggle(selected, item["name"]),
                child: Column(
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? yellowAcc : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? yellowAcc
                              : navy.withOpacity(0.25),
                        ),
                      ),
                      child: Icon(
                        item["icon"],
                        size: iconSize,
                        color: isSelected ? Colors.white : navy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: circleSize + 8,
                      child: Text(
                        item["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? yellowAcc : navy,
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
