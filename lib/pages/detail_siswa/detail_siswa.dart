import 'package:flutter/material.dart';
import '../../../models/teaching_request.dart';

class DetailSiswaPage extends StatelessWidget {
  final TeachingRequest request;
  final bool showAcceptButton;

  const DetailSiswaPage({
    super.key,
    required this.request,
    this.showAcceptButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Siswa")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.namaSiswa,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text("${request.mapel} • ${request.jarak}"),
            const SizedBox(height: 12),
            Text("Alamat:\n${request.alamat}"),
            const Spacer(),
            if (showAcceptButton)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("Terima"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
