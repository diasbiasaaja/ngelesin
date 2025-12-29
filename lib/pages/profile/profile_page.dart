import 'package:flutter/material.dart';
import '/dummy/dummy_user.dart';
import 'edit_profile_page.dart';
import 'edit_addres_page.dart';
import 'package:ngelesin/models/usermodel.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PROFIL"), centerTitle: true),
      body: Column(
        children: [
          const SizedBox(height: 24),

          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(currentUser.fotoUrl),
          ),

          const SizedBox(height: 12),

          Text(
            currentUser.nama,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 32),

          _menu(
            context,
            "Data Pribadi",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),

          _menu(
            context,
            "Alamat",
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditAddressPage()),
            ),
          ),

          _menu(context, "Keluar", () {}),
        ],
      ),
    );
  }

  Widget _menu(BuildContext context, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
