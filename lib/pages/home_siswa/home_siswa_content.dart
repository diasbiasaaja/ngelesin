import 'package:flutter/material.dart';
import 'widgets/siswa_header.dart';
import 'widgets/search_bar.dart';
import 'widgets/tingkatan_card.dart';
import 'widgets/jadwal.dart';
import 'package:ngelesin/pages/guru_list/guru_list_page.dart';

class HomeSiswaContent extends StatefulWidget {
  const HomeSiswaContent({super.key});

  @override
  State<HomeSiswaContent> createState() => _HomeSiswaContentState();
}

class _HomeSiswaContentState extends State<HomeSiswaContent> {
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 80;
    final TextEditingController searchController = TextEditingController();
    final ScrollController _scrollController = ScrollController();
    final GlobalKey _jadwalKey = GlobalKey();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            const siswaHeader(),

            // garis kuning
            Container(height: 4, color: Colors.amber),

            const SizedBox(height: 20),

            const SizedBox(height: 12),

            // 🔍 SEARCH BAR AKTIF
            SiswaSearchBar(
              controller: searchController,
              onChanged: (value) {
                // nanti buat filter guru/mapel
              },
            ),

            const SizedBox(height: 20),

            // MAPEL CARD
            TingkatanCard(
              title: "SD",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.flag_circle_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_soccer_rounded, "name": "PJOK"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
              ],
              onSubjectTap: (subject) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GuruListPage(jenjang: "SD", mapel: subject),
                  ),
                );
              },
            ),

            TingkatanCard(
              title: "SMP",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.science_rounded, "name": "IPA"},
                {"icon": Icons.public_rounded, "name": "IPS"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "PAI / Agama"},
                {"icon": Icons.sports_basketball_rounded, "name": "PJOK"},
                {"icon": Icons.brush_rounded, "name": "Seni Budaya"},
                {"icon": Icons.handyman_rounded, "name": "Prakarya"},
              ],
              onSubjectTap: (subject) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GuruListPage(jenjang: "SMP", mapel: subject),
                  ),
                );
              },
            ),

            TingkatanCard(
              title: "SMA",
              subjects: [
                {"icon": Icons.calculate_rounded, "name": "Matematika"},
                {"icon": Icons.menu_book_rounded, "name": "Bahasa Indo"},
                {"icon": Icons.language_rounded, "name": "Bahasa Inggris"},
                {"icon": Icons.history_edu_rounded, "name": "Sejarah"},
                {"icon": Icons.flag_rounded, "name": "PPKn"},
                {"icon": Icons.mosque_rounded, "name": "Agama"},
                // IPA
                {"icon": Icons.science_rounded, "name": "Fisika"},
                {"icon": Icons.bubble_chart_rounded, "name": "Kimia"},
                {"icon": Icons.biotech_rounded, "name": "Biologi"},
                // IPS
                {"icon": Icons.public_rounded, "name": "Geografi"},
                {"icon": Icons.groups_rounded, "name": "Sosiologi"},
                {"icon": Icons.attach_money_rounded, "name": "Ekonomi"},
                // Tambahan
                {"icon": Icons.computer_rounded, "name": "Informatika"},
                {"icon": Icons.palette_rounded, "name": "Seni Budaya"},
                {"icon": Icons.sports_martial_arts_rounded, "name": "PJOK"},
              ],
              onSubjectTap: (subject) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GuruListPage(jenjang: "SMA", mapel: subject),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            //jadwal hari ini
            JadwalHariIni(
              onTap: () {
                Scrollable.ensureVisible(
                  _jadwalKey.currentContext!,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
            ),

            JadwalGuruCard(
              namaGuru: "Pak Budi",
              mapel: "Matematika",
              jam: "12.00 - 15.00",
            ),

            JadwalGuruCard(
              namaGuru: "Bu Rina",
              mapel: "IPA",
              jam: "16.00 - 18.00",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
