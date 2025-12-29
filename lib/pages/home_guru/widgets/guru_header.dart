import 'package:flutter/material.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class GuruHeader extends StatelessWidget {
  const GuruHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ================= HEADER UTAMA =================
        Container(
          padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A2A43), Color(0xFF1B3B5A)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: navy),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Collage Private - Guru",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Siap mengajar dan bantu murid berkembang",
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text(
                  "Halo, Guru 👋",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // ================= GARIS KUNING =================
        Container(height: 4, width: double.infinity, color: yellowAcc),
      ],
    );
  }
}
