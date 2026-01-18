import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:ngelesin/models/guru_model.dart';
import '../detail/guru_detail_page.dart';
import '../booking/booking_page.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LatLng? userLatLng;
  Guru? selectedGuru;

  final Distance _distance = const Distance();

  // buat scroll list card
  final PageController _pageController = PageController(viewportFraction: 0.96);

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ================= LOCATION =================
  Future<void> _initLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        userLatLng = LatLng(pos.latitude, pos.longitude);
      });
    } catch (_) {}
  }

  // ================= HELPERS =================
  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  // ================= STREAM GURU ON =================
  Stream<List<Guru>> streamGuruOn() {
    return FirebaseFirestore.instance
        .collection('guru')
        .where('is_available', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final gurus = snap.docs.map(_guruFromDoc).toList();

          // hitung jarak
          if (userLatLng != null) {
            for (final g in gurus) {
              if (g.lat == null || g.lng == null) continue;

              final km = _distance.as(
                LengthUnit.Kilometer,
                userLatLng!,
                LatLng(g.lat!, g.lng!),
              );

              g.jarakKm = double.parse(km.toStringAsFixed(1));
            }

            gurus.sort((a, b) => a.jarakKm.compareTo(b.jarakKm));
          }

          return gurus;
        });
  }

  // ================= DOC TO MODEL =================
  Guru _guruFromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    String mapel = '-';
    final mapelSd = data['mapel_sd'];
    if (mapelSd is List && mapelSd.isNotEmpty) {
      mapel = mapelSd.first.toString();
    } else if (data['mapel'] != null) {
      mapel = data['mapel'].toString();
    }

    final hargaPerJam = _toInt(data['harga_per_jam']);
    final harga1_5 = _toInt(data['harga_1_5']);
    final harga6_10 = _toInt(data['harga_6_10']);

    HargaKelompok? hargaKelompok;
    if (harga1_5 > 0 || harga6_10 > 0) {
      hargaKelompok = HargaKelompok(
        harga1_5: harga1_5 > 0 ? harga1_5 : hargaPerJam,
        harga6_10: harga6_10 > 0 ? harga6_10 : hargaPerJam,
      );
    }

    return Guru(
      uid: doc.id,
      nama: (data['nama'] ?? 'Tanpa Nama').toString(),
      mapel: mapel,
      bio: (data['bio'] ?? '').toString(),
      fotoUrl: (data['foto_url'] ?? 'assets/images/user_dummy.png').toString(),
      rating: _toDouble(data['rating_avg']),
      totalUlasan: _toInt(data['rating_count']),
      ulasan: const [],
      hargaPerJam: hargaPerJam,
      hargaKelompok: hargaKelompok,
      jarakKm: 0,
      lat: _toDouble(data["lat"]),
      lng: _toDouble(data["lng"]),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map — Guru Terdekat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: userLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<Guru>>(
              stream: streamGuruOn(),
              builder: (context, snap) {
                final gurus = snap.data ?? [];

                // auto selected pertama
                final currentSelected =
                    selectedGuru ?? (gurus.isNotEmpty ? gurus.first : null);

                if (selectedGuru == null && currentSelected != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => selectedGuru = currentSelected);
                  });
                }

                return Column(
                  children: [
                    // ================= MAP =================
                    Expanded(
                      flex: 6,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: userLatLng!,
                          initialZoom: 13,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                            userAgentPackageName: "com.example.ngelesin",
                          ),
                          MarkerLayer(
                            markers: [
                              // user marker
                              Marker(
                                point: userLatLng!,
                                width: 50,
                                height: 50,
                                child: _buildUserDot(),
                              ),

                              // guru markers
                              ...gurus
                                  .where((g) => g.lat != null && g.lng != null)
                                  .map((g) {
                                    return Marker(
                                      point: LatLng(g.lat!, g.lng!),
                                      width: 110,
                                      height: 110,
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => selectedGuru = g);

                                          // saat marker dipencet, pindahin page
                                          final idx = gurus.indexWhere(
                                            (x) => x.uid == g.uid,
                                          );
                                          if (idx != -1) {
                                            _pageController.animateToPage(
                                              idx,
                                              duration: const Duration(
                                                milliseconds: 250,
                                              ),
                                              curve: Curves.easeOut,
                                            );
                                          }
                                        },
                                        child: _MapMarker(
                                          label: g.nama,
                                          selected:
                                              currentSelected?.uid == g.uid,
                                        ),
                                      ),
                                    );
                                  })
                                  .toList(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Divider(height: 1),

                    // ================= BOTTOM DETAIL =================
                    Expanded(
                      flex: 4,
                      child: SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 40,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Guru di Sekitar Kamu",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),

                              if (gurus.isEmpty)
                                const Expanded(
                                  child: Center(
                                    child: Text(
                                      "Belum ada guru yang sedang ON.",
                                    ),
                                  ),
                                )
                              else
                                // ✅ INI YANG BIKIN CARD BISA DI SCROLL
                                Expanded(
                                  child: PageView.builder(
                                    controller: _pageController,
                                    itemCount: gurus.length,
                                    onPageChanged: (i) {
                                      setState(() => selectedGuru = gurus[i]);
                                    },
                                    itemBuilder: (_, i) {
                                      final g = gurus[i];

                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          right: 10,
                                        ),
                                        child: _GuruCard(
                                          guru: g,
                                          onDetail: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    GuruDetailPage(guru: g),
                                              ),
                                            );
                                          },
                                          onBooking: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    BookingPage(guru: g),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildUserDot() => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: navy,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: const Icon(Icons.my_location_rounded, color: Colors.white, size: 16),
  );
}

// ================= MARKER =================
class _MapMarker extends StatelessWidget {
  final String label;
  final bool selected;

  const _MapMarker({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 120),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? yellowAcc : Colors.transparent,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
          ),
        ),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: yellowAcc,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.school_rounded,
            size: 16,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ================= CARD (ANTI OVERFLOW TOTAL) =================
class _GuruCard extends StatelessWidget {
  final Guru guru;
  final VoidCallback onDetail;
  final VoidCallback onBooking;

  const _GuruCard({
    required this.guru,
    required this.onDetail,
    required this.onBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: yellowAcc.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: yellowAcc),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            guru.nama,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "${guru.mapel} • ${guru.jarakKm} km",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Harga Privat: Rp ${guru.hargaPerJam}/jam"),
                  if (guru.hargaKelompok != null) ...[
                    const SizedBox(height: 6),
                    Text("1–5 siswa: Rp ${guru.hargaKelompok!.harga1_5}/jam"),
                    Text("6–10 siswa: Rp ${guru.hargaKelompok!.harga6_10}/jam"),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: yellowAcc,
                      foregroundColor: navy,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onDetail,
                    child: const Text(
                      "Detail Guru",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: navy,
                      side: const BorderSide(color: navy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onBooking,
                    child: const Text(
                      "Booking",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
