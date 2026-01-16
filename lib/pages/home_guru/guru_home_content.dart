import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'widgets/guru_header.dart';
import 'widgets/summary_row.dart';
import 'widgets/availability_card.dart';
import 'widgets/search_bar.dart';
import 'widgets/section_header.dart';
import 'widgets/request_list.dart';

class GuruHomeContent extends StatelessWidget {
  final String namaGuru;

  const GuruHomeContent({super.key, required this.namaGuru});

  bool _isToday(String dateStr) {
    try {
      final now = DateTime.now();
      final todayStr =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      return dateStr == todayStr;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 90;

    final user = FirebaseAuth.instance.currentUser;

    // ✅ kalau auth belum ready, jangan loading
    if (user == null) {
      return SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Column(
            children: [
              GuruHeader(namaGuru: namaGuru),
              const SizedBox(height: 16),
              const SummaryRow(saldo: 0, sesiHariIni: 0, requestCount: 0),
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
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Akun belum login",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }

    // ✅ FIX RTDB URL flutter web
    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    // ✅ GURU KEY FINAL = UID (BIAR GA BERANTAK RTDB)
    final guruKey = user.uid;

    return SafeArea(
      bottom: false,
      child: StreamBuilder<DatabaseEvent>(
        stream: db.onValue,
        builder: (context, snapshot) {
          int saldo = 0;
          int requestCount = 0;
          int sesiHariIni = 0;

          if (snapshot.hasData) {
            // saldo
            final saldoSnap = snapshot.data!.snapshot.child(
              "saldo_guru/$guruKey/saldo",
            );
            final saldoVal = saldoSnap.value;
            saldo = (saldoVal is int)
                ? saldoVal
                : int.tryParse("$saldoVal") ?? 0;

            // request
            final reqSnap = snapshot.data!.snapshot.child(
              "requests_guru/$guruKey",
            );
            final reqVal = reqSnap.value;

            if (reqVal is Map) {
              requestCount = reqVal.length;

              for (final entry in reqVal.entries) {
                final data = entry.value;
                if (data is Map) {
                  final status = (data["status"] ?? "").toString();
                  final tanggal = (data["tanggal"] ?? "").toString();
                  if (status == "paid" && _isToday(tanggal)) {
                    sesiHariIni++;
                  }
                }
              }
            }
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: Column(
              children: [
                GuruHeader(namaGuru: namaGuru),
                const SizedBox(height: 16),

                SummaryRow(
                  saldo: saldo,
                  sesiHariIni: sesiHariIni,
                  requestCount: requestCount,
                ),

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

                // ✅ FIX: RequestList TANPA PARAMETER
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
