// lib/map_shell.dart
import 'package:flutter/material.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

/// Panggil dari FAB: showMapShell(context);
void showMapShell(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
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
  final List<Map<String, dynamic>> teachers = [
    {
      "id": "t1",
      "name": "Bu Siti",
      "subject": "Matematika",
      "price": 75000,
      "x": 0.46,
      "y": 0.38,
    },
    {
      "id": "t2",
      "name": "Pak Budi",
      "subject": "Fisika",
      "price": 90000,
      "x": 0.62,
      "y": 0.52,
    },
    {
      "id": "t3",
      "name": "Mbak Rina",
      "subject": "Bahasa Inggris",
      "price": 65000,
      "x": 0.28,
      "y": 0.55,
    },
  ];

  String? selectedId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map — Guru Terdekat'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.grey.shade100,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _MapBackgroundPainter()),
                      ),
                      // mock user location (center-ish)
                      Positioned(
                        left: w * 0.5 - 14,
                        top: h * 0.45 - 14,
                        child: _buildUserDot(),
                      ),

                      // markers
                      for (var t in teachers)
                        Positioned(
                          left: (t['x'] as double) * w - 16,
                          top: (t['y'] as double) * h - 34,
                          child: GestureDetector(
                            onTap: () {
                              setState(() => selectedId = t['id']);
                              // optionally scroll list or animate
                            },
                            child: _MapMarker(
                              label: t['name'],
                              highlighted: selectedId == t['id'],
                            ),
                          ),
                        ),

                      // filter/search floating
                      Positioned(
                        right: 12,
                        top: 12,
                        child: Material(
                          color: Colors.white,
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.filter_list_rounded, size: 18),
                                SizedBox(width: 8),
                                Text("Filter"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: teachers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final t = teachers[i];
                        final isSelected = t['id'] == selectedId;
                        return ListTile(
                          onTap: () {
                            setState(() => selectedId = t['id']);
                            // In a real map: animate camera to marker
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: isSelected
                              ? yellowAcc.withOpacity(0.12)
                              : Colors.white,
                          leading: CircleAvatar(
                            backgroundColor: navy.withOpacity(0.08),
                            child: const Icon(Icons.person, color: navy),
                          ),
                          title: Text("${t['name']} • ${t['subject']}"),
                          subtitle: Text("Rp ${t['price']}/jam"),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: navy,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Booking ${t['name']} (mock)'),
                                ),
                              );
                            },
                            child: const Text("Pesan"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
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

class _MapMarker extends StatelessWidget {
  final String label;
  final bool highlighted;
  const _MapMarker({required this.label, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (highlighted)
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
            color: highlighted ? yellowAcc : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: navy.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.school_rounded,
            size: 16,
            color: highlighted ? Colors.white : navy,
          ),
        ),
      ],
    );
  }
}

class _MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.grey.shade200;
    canvas.drawRect(Offset.zero & size, paint);

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
