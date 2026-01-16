import 'package:flutter/material.dart';
import '../home_guru_page.dart'; // ambil warna navy

class SummaryRow extends StatelessWidget {
  final int saldo;
  final int sesiHariIni;
  final int requestCount;

  const SummaryRow({
    super.key,
    required this.saldo,
    required this.sesiHariIni,
    required this.requestCount,
  });

  String _formatRupiah(int value) {
    return "Rp ${value.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => "${m[1]}.")}";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(title: "Saldo", value: _formatRupiah(saldo)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(title: "Hari Ini", value: "$sesiHariIni Sesi"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              title: "Request",
              value: requestCount.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: navy,
            ),
          ),
        ],
      ),
    );
  }
}
