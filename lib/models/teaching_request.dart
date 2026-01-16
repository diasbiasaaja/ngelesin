import 'package:flutter/material.dart';

class TeachingRequest {
  final String bookingId;
  final String muridUid;
  final String namaSiswa;

  final String mapel;
  final String alamat;
  final String jarak;
  final int harga;

  final int jumlahSiswa;
  final DateTime tanggal;
  final TimeOfDay jamMulai;
  final TimeOfDay jamSelesai;
  final String fotoUrl;

  TeachingRequest({
    required this.bookingId,
    required this.muridUid,
    required this.namaSiswa,
    required this.mapel,
    required this.alamat,
    required this.jarak,
    required this.harga,
    required this.jumlahSiswa,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    required this.fotoUrl,
  });
}
