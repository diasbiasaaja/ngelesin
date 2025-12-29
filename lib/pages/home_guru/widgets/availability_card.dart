import 'package:flutter/material.dart';

class AvailabilityCard extends StatefulWidget {
  const AvailabilityCard({super.key});

  @override
  State<AvailabilityCard> createState() => _AvailabilityCardState();
}

class _AvailabilityCardState extends State<AvailabilityCard> {
  bool isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Text(
                "Status Ketersediaan\nTampilkan jika siap dipanggil ke rumah",
                style: TextStyle(fontSize: 12),
              ),
            ),
            Switch(
              value: isAvailable,
              onChanged: (value) {
                setState(() {
                  isAvailable = value;
                });

                // nanti bisa kirim ke backend
                // updateAvailability(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
