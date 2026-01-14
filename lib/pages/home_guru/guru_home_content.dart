import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/guru_header.dart';
import 'widgets/summary_row.dart';
import 'widgets/availability_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/request_list.dart';

class GuruHomeContent extends StatelessWidget {
  final String namaGuru;

  const GuruHomeContent({
    super.key,
    required this.namaGuru,
  });

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
            kBottomNavigationBarHeight +
            90;

    return SafeArea(
      bottom: false,
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guru')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(child: Text("Data guru tidak ditemukan"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final saldo = data['saldo'] ?? 0;
          final sesiHariIni = data['sesi_hari_ini'] ?? 0;
          final requestCount = data['request_count'] ?? 0;

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              children: [
                // ================= HEADER =================
                GuruHeader(namaGuru: namaGuru),
                const SizedBox(height: 16),

                // ================= SUMMARY =================
                SummaryRow(
                  saldo: saldo,
                  sesiHariIni: sesiHariIni,
                  requestCount: requestCount,
                ),

                const SizedBox(height: 16),

                // ================= AVAILABILITY =================
                const AvailabilityCard(),
                const SizedBox(height: 16),

                // ================= SEARCH =================
                const GuruSearchInput(),
                const SizedBox(height: 16),

                // ================= SECTION =================
                const SectionHeader(
                  title: "Permintaan Mengajar",
                  subtitle: "",
                  roleLabel: "Guru",
                ),

                // ================= REQUEST LIST (FIRESTORE) =================
                const RequestList(),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
