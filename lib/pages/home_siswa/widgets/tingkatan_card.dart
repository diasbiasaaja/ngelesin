import 'package:flutter/material.dart';

// warna samakan dengan tema kamu
const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class TingkatanCard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> subjects;
  final Function(String subject)? onSubjectTap;

  const TingkatanCard({
    super.key,
    required this.title,
    required this.subjects,
    this.onSubjectTap,
  });

  @override
  State<TingkatanCard> createState() => _TingkatanCardState();
}

class _TingkatanCardState extends State<TingkatanCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final visibleSubjects = expanded
        ? widget.subjects
        : widget.subjects.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            blurRadius: 22,
            offset: const Offset(0, 10),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== TITLE + GARIS KUNING =====
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: navy,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: yellowAcc,
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          const SizedBox(height: 20),

          // ===== SUBJECT GRID =====
          Wrap(
            spacing: 25,
            runSpacing: 20,
            children: visibleSubjects.map((item) {
              return GestureDetector(
                onTap: () {
                  if (widget.onSubjectTap != null) {
                    widget.onSubjectTap!(item["name"]);
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: navy.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                            color: Colors.black.withOpacity(0.06),
                          ),
                        ],
                      ),
                      child: Icon(item["icon"], size: 34, color: navy),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        item["name"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // ===== LIHAT SEMUA / SEDIKIT =====
          Center(
            child: GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: yellowAcc.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  expanded ? "Lihat Lebih Sedikit" : "Lihat Semua",
                  style: const TextStyle(
                    color: yellowAcc,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
