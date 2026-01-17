import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

    // ✅ RTDB ref
    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    // ✅ ambil bookings murid dari RTDB
    final bookingRef = (uid == null) ? null : db.child("bookings/$uid");

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

            // ================= JADWAL + RIWAYAT (RTDB) =================
            if (bookingRef == null)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text("Silakan login untuk melihat jadwal"),
              )
            else
              StreamBuilder<DatabaseEvent>(
                stream: bookingRef.onValue,
                builder: (context, snapshot) {
                  // loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _jadwalKosongUI(
                      jadwalKey: jadwalKey,
                      showRiwayat: showRiwayat,
                      toggleRiwayat: () =>
                          setState(() => showRiwayat = !showRiwayat),
                    );
                  }

                  // kosong
                  if (!snapshot.hasData ||
                      snapshot.data!.snapshot.value == null) {
                    return _jadwalKosongUI(
                      jadwalKey: jadwalKey,
                      showRiwayat: showRiwayat,
                      toggleRiwayat: () =>
                          setState(() => showRiwayat = !showRiwayat),
                    );
                  }

                  final raw = snapshot.data!.snapshot.value;
                  if (raw is! Map) {
                    return _jadwalKosongUI(
                      jadwalKey: jadwalKey,
                      showRiwayat: showRiwayat,
                      toggleRiwayat: () =>
                          setState(() => showRiwayat = !showRiwayat),
                    );
                  }

                  final today = _todayKey();

                  // ✅ convert Map ke List booking
                  final allBookings = raw.entries.map((e) {
                    final data = (e.value as Map);

                    final status = (data["status"] ?? "").toString();
                    final guruNama = (data["guruNama"] ?? "-").toString();
                    final mapel = (data["mapel"] ?? "-").toString();
                    final jam = (data["jam"] ?? "-").toString();
                    final tanggalStr = (data["tanggal"] ?? "").toString();

                    return {
                      "id": e.key.toString(),
                      "status": status,
                      "guruNama": guruNama,
                      "mapel": mapel,
                      "jam": jam,
                      "tanggal": tanggalStr,
                      "data": data,
                    };
                  }).toList();

                  // ✅ tampilkan hanya accepted
                  final accepted = allBookings
                      .where((b) => b["status"] == "accepted")
                      .toList();

                  // ✅ filter jadwal hari ini
                  final todayDocs = accepted.where((b) {
                    final tgl = (b["tanggal"] ?? "").toString();
                    return tgl == today;
                  }).toList();

                  // ✅ riwayat (selain hari ini)
                  final historyDocs = accepted
                      .where((b) => !todayDocs.contains(b))
                      .toList();

                  return Column(
                    children: [
                      // ================= JADWAL HARI INI =================
                      JadwalHariIni(
                        onTap: () {
                          if (todayDocs.isEmpty) return;
                          if (jadwalKey.currentContext == null) return;
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
                          children: todayDocs.map((b) {
                            return JadwalGuruCard(
                              namaGuru: b["guruNama"].toString(),
                              mapel: b["mapel"].toString(),
                              jam: b["jam"].toString(),
                              onDetail: () {
                                debugPrint("DETAIL BOOKING ID: ${b["id"]}");
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
                              : historyDocs.take(10).map((b) {
                                  return JadwalGuruCard(
                                    namaGuru: b["guruNama"].toString(),
                                    mapel: b["mapel"].toString(),
                                    jam: b["jam"].toString(),
                                    onDetail: () {
                                      debugPrint(
                                        "RIWAYAT BOOKING ID: ${b["id"]}",
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

  /// UI jadwal kosong (UX sama kayak punyamu)
  Widget _jadwalKosongUI({
    required GlobalKey jadwalKey,
    required bool showRiwayat,
    required VoidCallback toggleRiwayat,
  }) {
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
          onTap: toggleRiwayat,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Text(
                  "Riwayat",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
}
