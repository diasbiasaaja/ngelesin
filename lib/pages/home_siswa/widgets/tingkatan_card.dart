import 'package:flutter/material.dart';

const navy = Color(0xFF0A2A43);
const yellowAcc = Color(0xFFFFC947);

class TingkatanCard extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> subjects;
  final Set<String> selectedSubjects;
  final Function(String subject)? onSubjectTap;
  final VoidCallback? onSelectAll;

  const TingkatanCard({
    super.key,
    required this.title,
    required this.subjects,
    required this.selectedSubjects,
    this.onSubjectTap,
    this.onSelectAll,
  });

  @override
  State<TingkatanCard> createState() => _TingkatanCardState();
}

class _TingkatanCardState extends State<TingkatanCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // ================= RESPONSIVE SIZE (BALIK KE PUNYA KAMU) =================
    double circleSize = 64;
    double iconSize = 28;
    double fontSize = 12;

    if (screenWidth < 360) {
      circleSize = 56;
      iconSize = 24;
      fontSize = 11;
    } else if (screenWidth > 600) {
      circleSize = 72;
      iconSize = 32;
      fontSize = 13;
    }

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
          // ================= HEADER =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: navy,
                ),
              ),

              // 🔥 PILIH SEMUA PER JENJANG
              if (widget.onSelectAll != null)
                GestureDetector(
                  onTap: widget.onSelectAll,
                  child: const Text(
                    "Pilih Semua",
                    style: TextStyle(
                      color: yellowAcc,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 20),

          // ================= MAPEL =================
          Wrap(
            spacing: 20,
            runSpacing: 18,
            children: visibleSubjects.map((item) {
              final isSelected = widget.selectedSubjects.contains(item["name"]);

              return GestureDetector(
                onTap: () {
                  if (widget.onSubjectTap != null) {
                    widget.onSubjectTap!(item["name"]);
                  }
                },
                child: Column(
                  children: [
                    Container(
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? yellowAcc : Colors.white,
                        border: Border.all(
                          color: isSelected ? yellowAcc : navy.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        item["icon"],
                        size: iconSize,
                        color: isSelected ? Colors.white : navy,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: circleSize + 8,
                      child: Text(
                        item["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? yellowAcc : navy,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // ================= TOGGLE =================
          Center(
            child: GestureDetector(
              onTap: () => setState(() => expanded = !expanded),
              child: Text(
                expanded ? "Lihat Lebih Sedikit" : "Lihat Semua",
                style: const TextStyle(
                  color: yellowAcc,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
