import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'widgets/siswa_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/tingkatan_card.dart';
import 'widgets/jadwal.dart';

import '../guru_list/guru_list_page.dart';

class HomeSiswaContent extends StatefulWidget {
  const HomeSiswaContent({super.key});

  @override
  State<HomeSiswaContent> createState() => _HomeSiswaContentState();
}

class _HomeSiswaContentState extends State<HomeSiswaContent> {
  bool showRiwayat = false;

  String _dateKey(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }

  String _todayKey() => _dateKey(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 80;

    final GlobalKey jadwalKey = GlobalKey();

    final uid = FirebaseAuth.instance.currentUser?.uid;

    // ✅ query booking murid
    final bookingQuery = (uid == null)
        ? null
        : FirebaseFirestore.instance
              .collection("booking")
              .where("murid_uid", isEqualTo: uid)
              .orderBy("tanggal", descending: true);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            // ================= HEADER =================
            const SiswaHeader(),

            // garis kuning
            Container(height: 4, color: Colors.amber),

            const SizedBox(height: 20),

            // ================= SEARCH =================
            SiswaSearchBar(
              controller: TextEditingController(),
              onChanged: (_) {},
            ),

            const SizedBox(height: 20),

            // ================= MAPEL =================
            TingkatanCard(
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
              onSubjectTap: (mapel) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuruListPage(jenjang: "SD", mapel: mapel),
                  ),
                );
              },
              selectedSubjects: const {},
            ),

            TingkatanCard(
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
              onSubjectTap: (mapel) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuruListPage(jenjang: "SMP", mapel: mapel),
                  ),
                );
              },
              selectedSubjects: const {},
            ),

            TingkatanCard(
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
              onSubjectTap: (mapel) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuruListPage(jenjang: "SMA", mapel: mapel),
                  ),
                );
              },
              selectedSubjects: const {},
            ),

            const SizedBox(height: 16),

            // ================= JADWAL + RIWAYAT (FIRESTORE) =================
            if (bookingQuery == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Silakan login untuk melihat jadwal"),
              )
            else
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: bookingQuery.snapshots(),
                builder: (context, snapshot) {
                  // ✅ kalau masih loading / belum dapet data -> jangan muter terus
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        // Jadwal hari ini
                        JadwalHariIni(onTap: () {}),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Jadwal hari ini kosong"),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Riwayat
                        GestureDetector(
                          onTap: () =>
                              setState(() => showRiwayat = !showRiwayat),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Riwayat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: showRiwayat ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.keyboard_arrow_down),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (showRiwayat)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Belum ada riwayat"),
                            ),
                          ),

                        const SizedBox(height: 24),
                      ],
                    );
                  }

                  // ✅ kalau ada error (misal orderBy / index) -> tampilkan kosong juga
                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        JadwalHariIni(onTap: () {}),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Jadwal hari ini kosong"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () =>
                              setState(() => showRiwayat = !showRiwayat),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  "Riwayat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: showRiwayat ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: const Icon(Icons.keyboard_arrow_down),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (showRiwayat)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Belum ada riwayat"),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }

                  // ✅ data aman
                  final docs = snapshot.data?.docs ?? [];

                  final today = _todayKey();

                  final todayDocs = docs.where((d) {
                    final t = d.data()["tanggal"];
                    if (t == null) return false;

                    final dt = (t as Timestamp).toDate();
                    return _dateKey(dt) == today;
                  }).toList();

                  final historyDocs = docs
                      .where((d) => !todayDocs.contains(d))
                      .toList();

                  return Column(
                    children: [
                      // ================= JADWAL HARI INI =================
                      JadwalHariIni(
                        onTap: () {
                          if (todayDocs.isEmpty) return;
                          Scrollable.ensureVisible(
                            jadwalKey.currentContext!,
                            duration: const Duration(milliseconds: 400),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      if (todayDocs.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("Jadwal hari ini kosong"),
                          ),
                        )
                      else
                        Column(
                          key: jadwalKey,
                          children: todayDocs.map((doc) {
                            final data = doc.data();
                            final namaGuru = (data["guru_nama"] ?? "-")
                                .toString();
                            final mapel = (data["mapel"] ?? "-").toString();
                            final jam = (data["jam"] ?? "-").toString();

                            return JadwalGuruCard(
                              namaGuru: namaGuru,
                              mapel: mapel,
                              jam: jam,
                              onDetail: () {
                                debugPrint("Booking detail id: ${doc.id}");
                              },
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 20),

                      // ================= RIWAYAT =================
                      GestureDetector(
                        onTap: () => setState(() => showRiwayat = !showRiwayat),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              const Text(
                                "Riwayat",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              AnimatedRotation(
                                turns: showRiwayat ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (showRiwayat)
                        Column(
                          children: historyDocs.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20,
                                    ),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Belum ada riwayat"),
                                    ),
                                  ),
                                ]
                              : historyDocs.take(10).map((doc) {
                                  final data = doc.data();
                                  final namaGuru = (data["guru_nama"] ?? "-")
                                      .toString();
                                  final mapel = (data["mapel"] ?? "-")
                                      .toString();
                                  final jam = (data["jam"] ?? "-").toString();

                                  return JadwalGuruCard(
                                    namaGuru: namaGuru,
                                    mapel: mapel,
                                    jam: jam,
                                    onDetail: () {
                                      debugPrint(
                                        "Riwayat detail id: ${doc.id}",
                                      );
                                    },
                                  );
                                }).toList(),
                        ),

                      const SizedBox(height: 24),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
