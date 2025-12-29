enum UserRole { siswa, guru }

class UserModel {
  String nama;
  String fotoUrl;
  UserRole role;
  String alamat;
  int? hargaPerJam;

  // 🔥 TAMBAH INI
  String? bio;

  UserModel({
    required this.nama,
    required this.fotoUrl,
    required this.role,
    required this.alamat,
    this.hargaPerJam,
    this.bio,
  });
}
