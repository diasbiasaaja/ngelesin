class Guru {
  final String uid;
  final String nama;
  final String mapel;
  final String bio;
  final String fotoUrl;

  final double rating;
  final int totalUlasan;
  final List<GuruUlasan> ulasan;

  final int hargaPerJam;
  final HargaKelompok? hargaKelompok;

  final double jarakKm;

  Guru({
    required this.uid,
    required this.nama,
    required this.mapel,
    required this.bio,
    required this.fotoUrl,
    required this.rating,
    required this.totalUlasan,
    required this.ulasan,
    required this.hargaPerJam,
    this.hargaKelompok,
    required this.jarakKm,
  });
}

class GuruUlasan {
  final String nama;
  final String komentar;

  GuruUlasan({required this.nama, required this.komentar});
}

class HargaKelompok {
  final int harga1_5;
  final int harga6_10;

  HargaKelompok({required this.harga1_5, required this.harga6_10});
}
