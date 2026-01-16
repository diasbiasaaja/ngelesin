import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ngelesin/models/teaching_request.dart';
import 'package:ngelesin/pages/detail/detail_siswa.dart';
import 'request_tile.dart';

class RequestList extends StatelessWidget {
  const RequestList({super.key});

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split("-");
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  Future<Map<String, String>> _getMuridInfo(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection("murid")
          .doc(uid)
          .get();

      if (!doc.exists) return {"nama": uid, "alamat": "-"};

      final data = doc.data() as Map<String, dynamic>;
      return {
        "nama": (data["nama"] ?? uid).toString(),
        "alamat": (data["alamat"] ?? "-").toString(),
      };
    } catch (_) {
      return {"nama": uid, "alamat": "-"};
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text("Guru belum login", style: TextStyle(color: Colors.grey)),
      );
    }

    final guruKey = user.uid;

    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final requestRef = db.child("requests_guru/$guruKey");

    return StreamBuilder<DatabaseEvent>(
      stream: requestRef.onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

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

        final entries = raw.entries.toList();

        // ✅ tampilkan request yg status == paid SAJA
        final paidEntries = entries.where((e) {
          final data = e.value;
          if (data is Map) {
            final status = (data["status"] ?? "").toString();
            return status == "paid";
          }
          return false;
        }).toList();

        if (paidEntries.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Belum ada permintaan mengajar",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return Column(
          children: paidEntries.map((entry) {
            final bookingId = entry.key.toString();
            final data = entry.value as Map;

            final muridUid = (data["muridUid"] ?? "").toString();
            final mapel = (data["mapel"] ?? "").toString();
            final tanggalStr = (data["tanggal"] ?? "").toString();
            final jamStr = (data["jam"] ?? "00:00").toString();

            final hargaRaw = data["totalHarga"];
            final harga = (hargaRaw is int)
                ? hargaRaw
                : int.tryParse("$hargaRaw") ?? 0;

            final tgl = _parseDate(tanggalStr);
            final jamMulai = _parseTime(jamStr);
            final jamSelesai = TimeOfDay(
              hour: (jamMulai.hour + 2) % 24,
              minute: jamMulai.minute,
            );

            return FutureBuilder<Map<String, String>>(
              future: _getMuridInfo(muridUid),
              builder: (context, infoSnap) {
                final namaSiswa = infoSnap.data?["nama"] ?? muridUid;
                final alamat = infoSnap.data?["alamat"] ?? "-";

                final request = TeachingRequest(
                  namaSiswa: namaSiswa,
                  mapel: mapel,
                  alamat: alamat,
                  jarak: "-",
                  harga: harga,
                  jumlahSiswa: 1,
                  tanggal: tgl,
                  jamMulai: jamMulai,
                  jamSelesai: jamSelesai,
                  bookingId: bookingId,
                  muridUid: muridUid,
                  fotoUrl: "",
                );

                return RequestTile(
                  title: "$mapel - $namaSiswa",
                  subtitle: "$tanggalStr • ${jamMulai.format(context)}",
                  price: "Rp $harga / sesi",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailSiswaPage(
                          request: request,
                          showAcceptButton: true,
                          guruNama: '',
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
