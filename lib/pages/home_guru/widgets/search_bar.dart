import 'package:flutter/material.dart';

class GuruSearchInput extends StatelessWidget {
  const GuruSearchInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.grey),
            const SizedBox(width: 10),

            /// ✅ INI YANG BIKIN BISA DI KLIK & NGETIK
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: "Cari siswa atau permintaan...",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  // nanti buat filter request
                  print("search: $value");
                },
              ),
            ),

            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                print("filter diklik");
              },
            ),
          ],
        ),
      ),
    );
  }
}
