import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class MateriDetailSiswaPage extends StatelessWidget {
  final String bookingId;
  final String guruNama;
  final String mapel;
  final String tanggal;
  final String jam;

  const MateriDetailSiswaPage({
    super.key,
    required this.bookingId,
    required this.guruNama,
    required this.mapel,
    required this.tanggal,
    required this.jam,
  });

  Future<void> _openLink(String url) async {
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final materiRef = FirebaseFirestore.instance
        .collection("materi")
        .doc(bookingId)
        .collection("items")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Detail Materi",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // ===== BODY =====
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: materiRef.snapshots(),
        builder: (context, snap) {
          final docs = snap.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // ===== INFO GURU =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F4FB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guruNama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(mapel),
                    const SizedBox(height: 6),
                    Text(
                      "$tanggal • $jam",
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Booking: $bookingId",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (docs.isEmpty)
                const Text(
                  "Belum ada materi dari guru",
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...docs.map((d) {
                  final data = d.data();
                  final judul = (data["judul"] ?? "-").toString();
                  final deskripsi = (data["deskripsi"] ?? "-").toString();
                  final link = (data["link"] ?? "").toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 8,
                          color: Colors.black.withOpacity(0.05),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          judul,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(deskripsi),
                        const SizedBox(height: 10),

                        if (link.isNotEmpty)
                          InkWell(
                            onTap: () => _openLink(link),
                            child: Row(
                              children: [
                                const Icon(Icons.link, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    link,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const Text(
                            "Link materi tidak ada",
                            style: TextStyle(color: Colors.grey),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          );
        },
      ),
    );
  }
}
