import 'package:flutter/material.dart';
import '../home_siswa_page.dart';

class SiswaSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const SiswaSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: "Cari materi atau guru...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: const Icon(Icons.tune_rounded),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
