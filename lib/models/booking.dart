import 'package:flutter/material.dart';
import 'guru_model.dart';

class Booking {
  final Guru guru;
  final DateTime tanggal;
  final TimeOfDay jam;
  final int jumlahSiswa;
  final String alamat;
  final bool sudahBayar;

  Booking({
    required this.guru,
    required this.tanggal,
    required this.jam,
    required this.jumlahSiswa,
    required this.alamat,
    required this.sudahBayar,
  });
}
