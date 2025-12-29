import 'package:flutter/material.dart';

import '../../models/teaching_request.dart';
import '../detail/detail_siswa.dart';

import 'widgets/guru_header.dart';
import 'widgets/summary_row.dart';
import 'widgets/availability_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/request_tile.dart';

class GuruHomeContent extends StatelessWidget {
  const GuruHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 90;

    // ================= DUMMY REQUEST =================
    final rudiRequest = TeachingRequest(
      namaSiswa: "Ananda Rudi",
      mapel: "Matematika",
      alamat: "Jakarta Barat",
      jarak: "2 km",
      harga: 85000,
      jumlahSiswa: 1,
      tanggal: DateTime.now(),

      // 🔥 TAMBAHAN PENTING
      jamMulai: const TimeOfDay(hour: 12, minute: 0),
      jamSelesai: const TimeOfDay(hour: 15, minute: 0),

      fotoUrl: "",
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            const GuruHeader(),
            const SizedBox(height: 16),
            const SummaryRow(),
            const SizedBox(height: 16),
            const AvailabilityCard(),
            const SizedBox(height: 16),
            const GuruSearchInput(),
            const SizedBox(height: 16),

            const SectionHeader(
              title: "Permintaan Mengajar",
              subtitle: "",
              roleLabel: "Guru",
            ),

            // ================= REQUEST TILE =================
            RequestTile(
              title: "Les Matematika - Ananda Rudi",
              subtitle: "Jakarta Barat • 2 km",
              price: "Rp 85.000 / sesi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSiswaPage(
                      request: rudiRequest,
                      showAcceptButton: true,
                    ),
                  ),
                );
              },
            ),

            RequestTile(
              title: "Les IPA - Siti",
              subtitle: "Depok • 4.1 km",
              price: "Rp 75.000 / sesi",
              onTap: () {},
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
