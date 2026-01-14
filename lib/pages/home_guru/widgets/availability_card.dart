import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('guru')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return _loadingCard();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          // 🔥 DEFAULT FALSE KALAU BELUM ADA
          final bool isAvailable = data?['is_available'] ?? false;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                // TEXT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Status Ketersediaan",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Tampilkan jika siap dipanggil ke rumah",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                // SWITCH
                Switch(
                  value: isAvailable,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFF6C63FF),
                  onChanged: (value) async {
                    await FirebaseFirestore.instance
                        .collection('guru')
                        .doc(uid)
                        .update({
                      'is_available': value,
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🔄 Loading state
  Widget _loadingCard() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
