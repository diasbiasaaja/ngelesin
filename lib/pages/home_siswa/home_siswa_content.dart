import 'package:flutter/material.dart';

import 'widgets/siswa_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/tingkatan_card.dart';
import 'widgets/jadwal.dart';

import '../guru_list/guru_list_page.dart';
import '../detail/detail_guru_jadwal_page.dart';

import '/models/guru_model.dart';
import '/models/booking.dart';

class HomeSiswaContent extends StatelessWidget {
  const HomeSiswaContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 80;

    final GlobalKey jadwalKey = GlobalKey();

    // ================= DUMMY DATA JADWAL HARI INI =================
    final List<Booking> todayBookings = [
      Booking(
        guru: Guru(
          nama: "Pak Budi",
          mapel: "Matematika",
          bio: "Guru berpengalaman 10 tahun, fokus pemahaman konsep.",
          fotoUrl: "assets/images/guru1.png",
          rating: 4.9,
          totalUlasan: 23,
          ulasan: [],
          hargaPerJam: 100000,
          hargaKelompok: null,
          jarakKm: 2.3,
        ),
        tanggal: DateTime.now(),
        jam: const TimeOfDay(hour: 12, minute: 0),
        jumlahSiswa: 1,
        alamat: "Jl. Merdeka No. 10",
        sudahBayar: true,
      ),
    ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            // ================= HEADER =================
            const siswaHeader(),

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
            ),

            const SizedBox(height: 16),

            // ================= JADWAL HARI INI =================
            JadwalHariIni(
              onTap: () {
                Scrollable.ensureVisible(
                  jadwalKey.currentContext!,
                  duration: const Duration(milliseconds: 400),
                );
              },
            ),

            const SizedBox(height: 12),

            Column(
              key: jadwalKey,
              children: todayBookings.map((booking) {
                return JadwalGuruCard(
                  namaGuru: booking.guru.nama,
                  mapel: booking.guru.mapel,
                  jam: booking.jam.format(context),
                  onDetail: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingDetailPage(booking: booking),
                      ),
                    );
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
