import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AvailabilityCard extends StatelessWidget {
  const AvailabilityCard({super.key});

  Future<void> _showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    bool showSettingsButton = false,
  }) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (showSettingsButton)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Geolocator.openAppSettings();
              },
              child: const Text("Buka Pengaturan"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<bool> _ensureLocationReady(BuildContext context) async {
    // 1) cek service lokasi nyala
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await _showInfoDialog(
        context,
        title: "Lokasi belum aktif",
        message:
            "Aktifkan GPS/Lokasi dulu agar kamu bisa muncul di peta murid.",
        showSettingsButton: true,
      );
      return false;
    }

    // 2) cek permission
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      await _showInfoDialog(
        context,
        title: "Izin lokasi ditolak",
        message:
            "Kamu harus mengizinkan akses lokasi agar bisa muncul di peta murid.",
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await _showInfoDialog(
        context,
        title: "Izin lokasi ditolak permanen",
        message:
            "Aktifkan izin lokasi dari pengaturan HP agar bisa muncul di peta murid.",
        showSettingsButton: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _setAvailability({
    required BuildContext context,
    required String uid,
    required bool value,
  }) async {
    final docRef = FirebaseFirestore.instance.collection('guru').doc(uid);

    if (value == false) {
      // OFF: tinggal update is_available false
      await docRef.update({'is_available': false});
      return;
    }

    // ON: harus lokasi siap
    final ok = await _ensureLocationReady(context);
    if (!ok) {
      // balikin switch OFF
      await docRef.update({'is_available': false});
      return;
    }

    // ambil lokasi
    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // update firestore: availability + koordinat
    await docRef.update({
      'is_available': true,
      'lat': pos.latitude,
      'lng': pos.longitude,
      'last_location_at': FieldValue.serverTimestamp(),
    });

    // optional toast/snack
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Kamu sekarang tampil di peta murid")),
      );
    }
  }

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

          // DEFAULT FALSE
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
                        style: TextStyle(fontSize: 12, color: Colors.grey),
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
                    try {
                      await _setAvailability(
                        context: context,
                        uid: uid,
                        value: value,
                      );
                    } catch (e) {
                      // kalau error, balikin switch OFF biar aman
                      await FirebaseFirestore.instance
                          .collection('guru')
                          .doc(uid)
                          .update({'is_available': false});

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Gagal update: $e")),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Loading state
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
