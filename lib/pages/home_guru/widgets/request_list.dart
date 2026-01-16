import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import 'package:ngelesin/models/teaching_request.dart';
import 'package:ngelesin/pages/detail/detail_siswa.dart';
import 'request_tile.dart';

class RequestList extends StatelessWidget {
  final String namaGuru;

  const RequestList({super.key, required this.namaGuru});

  // ✅ sanitize key untuk RTDB path
  String safeKey(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[.#$\[\]]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final guruKey = safeKey(namaGuru);

    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final requestRef = db.child("requests_guru/$guruKey");

    return StreamBuilder<DatabaseEvent>(
      stream: requestRef.onValue,
      builder: (context, snapshot) {
        // 🔄 loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        // kosong
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Belum ada permintaan mengajar",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        final raw = snapshot.data!.snapshot.value;

        if (raw is! Map) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Belum ada permintaan mengajar",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // convert map -> list
        final entries = raw.entries.toList();

        // sort by createdAt (optional)
        entries.sort((a, b) {
          final aTime = (a.value["createdAt"] ?? 0) as int;
          final bTime = (b.value["createdAt"] ?? 0) as int;
          return bTime.compareTo(aTime);
        });

        return Column(
          children: entries.map((entry) {
            final data = entry.value;

            if (data is! Map) return const SizedBox();

            final status = (data["status"] ?? "").toString();

            // tampilkan request yang paid / pending saja
            // kamu bisa ganti kalo mau
            if (status != "paid" && status != "pending") {
              return const SizedBox();
            }

            final bookingId = (data["bookingId"] ?? entry.key).toString();
            final muridUid = (data["muridUid"] ?? "").toString();
            final muridNama = (data["muridNama"] ?? "Murid").toString();

            final mapel = (data["mapel"] ?? "-").toString();
            final jam = (data["jam"] ?? "00:00").toString();
            final tanggalStr = (data["tanggal"] ?? "").toString();

            final harga = int.tryParse("${data["totalHarga"]}") ?? 0;

            DateTime tanggal;
            try {
              tanggal = DateTime.parse(tanggalStr);
            } catch (_) {
              tanggal = DateTime.now();
            }

            final request = TeachingRequest(
              bookingId: bookingId,
              muridUid: muridUid,
              namaSiswa: muridNama,
              mapel: mapel,
              alamat: (data["alamat"] ?? "-").toString(),
              jarak: (data["jarak"] ?? "-").toString(),
              harga: harga,
              jumlahSiswa: 1,
              tanggal: tanggal,
              jamMulai: _parseTime(jam),
              jamSelesai: _parseTime(jam),
              fotoUrl: "",
            );

            return RequestTile(
              title: "$mapel - $muridNama", // ✅ tampil nama murid
              subtitle: "${tanggalStr} • $jam",
              price: "Rp $harga / sesi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSiswaPage(
                      request: request,
                      showAcceptButton: true,
                      guruNama: namaGuru, // ✅ penting buat guruKey
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
