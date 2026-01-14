import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ngelesin/models/teaching_request.dart';
import 'package:ngelesin/pages/detail/detail_siswa.dart';
import 'request_tile.dart';


class RequestList extends StatelessWidget {
  const RequestList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teaching_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('tanggal', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        // 🔄 loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          );
        }

        // ❌ kosong
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Belum ada permintaan mengajar",
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // ✅ ADA DATA
        final docs = snapshot.data!.docs;

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final request = TeachingRequest(
              namaSiswa: data['nama_siswa'],
              mapel: data['mapel'],
              alamat: data['alamat'],
              jarak: data['jarak'],
              harga: data['harga'],
              jumlahSiswa: 1,
              tanggal: (data['tanggal'] as Timestamp).toDate(),
              jamMulai: _parseTime(data['jam_mulai']),
              jamSelesai: _parseTime(data['jam_selesai']),
              fotoUrl: "",
            );

            return RequestTile(
              title: "${data['mapel']} - ${data['nama_siswa']}",
              subtitle: "${data['alamat']} • ${data['jarak']}",
              price: "Rp ${data['harga']} / sesi",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailSiswaPage(
                      request: request,
                      showAcceptButton: true,
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

  // 🔧 helper jam
  TimeOfDay _parseTime(String time) {
    final parts = time.split(":");
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}
