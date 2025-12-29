import 'package:flutter/material.dart';
import '../home_guru_page.dart';
import 'availability_card.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? roleLabel;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (subtitle != null)
          Text(subtitle!, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
