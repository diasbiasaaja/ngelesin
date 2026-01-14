import 'package:flutter/material.dart';

import 'role_service.dart';

// ganti sesuai lokasi Home kamu
import '../home_guru/home_guru_page.dart';
import '../home_siswa/home_siswa_page.dart';

class RoleGate extends StatelessWidget {
  const RoleGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: RoleService.getRole(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        if (role == "guru") return const HomeGuruPage();
        if (role == "siswa") return const HomeSiswaPage();

        return const Scaffold(
          body: Center(child: Text("Role tidak ditemukan")),
        );
      },
    );
  }
}
