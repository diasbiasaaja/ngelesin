import 'package:flutter/material.dart';
import 'package:ngelesin/models/guru_model.dart';
import '../detail/guru_detail_page.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

/// Panggil dari FAB / button:
/// showMapShell(context);
void showMapShell(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: const MapShell(),
        ),
      );
    },
  );
}

class MapShell extends StatefulWidget {
  const MapShell({super.key});

  @override
  State<MapShell> createState() => _MapShellState();
}

class _MapShellState extends State<MapShell> {
  late Guru selectedGuru;

  final List<Guru> teachers = [
    Guru(
      nama: "Bu Siti",
      mapel: "Matematika",
      bio: "Guru berpengalaman 8 tahun, sabar dan komunikatif.",
      fotoUrl: "assets/images/guru1.png",
      rating: 4.8,
      totalUlasan: 20,
      ulasan: [
        GuruUlasan(nama: "Andi", komentar: "Cara ngajarnya mudah dipahami"),
        GuruUlasan(nama: "Rina", komentar: "Sabar dan ramah"),
      ],
      hargaPerJam: 75000,
      hargaKelompok: HargaKelompok(harga1_5: 60000, harga6_10: 45000),
      jarakKm: 1.2,
      uid: '',
    ),
  ];

  @override
  void initState() {
    super.initState();
    selectedGuru = teachers.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map — Guru Terdekat"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ================= MAP =================
          Expanded(
            flex: 6,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _MapBackgroundPainter()),
                    ),

                    // USER LOCATION
                    Positioned(
                      left: w * 0.5 - 14,
                      top: h * 0.45 - 14,
                      child: _buildUserDot(),
                    ),

                    // GURU MARKER
                    Positioned(
                      left: w * 0.55,
                      top: h * 0.5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGuru = teachers.first;
                          });
                        },
                        child: _MapMarker(label: selectedGuru.nama),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1),

          // ================= BOTTOM DETAIL =================
          Expanded(
            flex: 4,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HANDLE
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

                    // CARD DETAIL
                    Container(
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
                            selectedGuru.nama,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "${selectedGuru.mapel} • ${selectedGuru.jarakKm} km",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            "Harga Privat: Rp ${selectedGuru.hargaPerJam}/jam",
                          ),

                          if (selectedGuru.hargaKelompok != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              "1–5 siswa: Rp ${selectedGuru.hargaKelompok!.harga1_5}/jam",
                            ),
                            Text(
                              "6–10 siswa: Rp ${selectedGuru.hargaKelompok!.harga6_10}/jam",
                            ),
                          ],

                          const SizedBox(height: 12),

                          Text(
                            "⭐ ${selectedGuru.rating} (${selectedGuru.totalUlasan} ulasan)",
                          ),

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: yellowAcc,
                                foregroundColor: navy,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        GuruDetailPage(guru: selectedGuru),
                                  ),
                                );
                              },
                              child: const Text(
                                "Detail Guru__",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDot() => Container(
    width: 28,
    height: 28,
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
  const _MapMarker({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Container(
          width: 32,
          height: 32,
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

// ================= MAP BACKGROUND =================
class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Offset.zero & size, bg);

    final line = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), line);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
