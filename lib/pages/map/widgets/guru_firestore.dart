import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ngelesin/models/guru_model.dart';

Guru guruFromFirestore(DocumentSnapshot doc, dynamic guru) {
  final data = doc.data() as Map<String, dynamic>;

  return Guru(
    uid: doc.id,
    nama: data['nama'] ?? 'Tanpa Nama',
    mapel: (data['mapel_sd'] is List && (data['mapel_sd'] as List).isNotEmpty)
        ? (data['mapel_sd'] as List).first.toString()
        : (data['mapel'] ?? '-').toString(),
    bio: data['bio'] ?? '',
    fotoUrl: data['foto_url'] ?? '',
    rating: (data['rating'] ?? 0).toDouble(),
    totalUlasan: (data['total_ulasan'] ?? 0).toInt(),
    ulasan: const [],
    hargaPerJam: (data['harga_per_jam'] ?? 0).toInt(),
    hargaKelompok: HargaKelompok(
      harga1_5: (data['harga_1_5'] ?? 0).toInt(),
      harga6_10: (data['harga_6_10'] ?? 0).toInt(),
    ),
    jarakKm: 0,
    lat: (data["lat"] != null) ? _toDouble(data["lat"]) : guru.lat,
    lng: (data["lng"] != null) ? _toDouble(data["lng"]) : guru.lng,
  );
}

_toDouble(data) {
  if (data == null) return 0.0;
  if (data is double) return data;
  if (data is int) return data.toDouble();
  if (data is num) return data.toDouble();
  return double.tryParse(data.toString()) ?? 0.0;
}
