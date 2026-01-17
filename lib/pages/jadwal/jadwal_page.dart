import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

import '../detail/detail_siswa.dart';
import '../../models/teaching_request.dart';

class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  // ✅ parse tanggal "yyyy-MM-dd"
  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split("-");
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  // ✅ parse jam "HH:mm"
  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(":");
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Guru belum login")));
    }

    // ✅ FIX PENTING: guruKey selalu UID
    final guruKey = user.uid;

    final db = FirebaseDatabase.instanceFor(
      app: FirebaseAuth.instance.app,
      databaseURL: "https://ngelesin-default-rtdb.firebaseio.com",
    ).ref();

    final jadwalRef = db.child("jadwal_guru/$guruKey");

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: StreamBuilder<DatabaseEvent>(
          stream: jadwalRef.onValue,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            List<TeachingRequest> jadwalList = [];

            if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
              final raw = snapshot.data!.snapshot.value;

              if (raw is Map) {
                for (final entry in raw.entries) {
                  final data = entry.value;

                  if (data is Map) {
                    final mapel = (data["mapel"] ?? "").toString();
                    final muridUid = (data["muridUid"] ?? "").toString();

                    final tanggalStr = (data["tanggal"] ?? "").toString();
                    final jamStr = (data["jam"] ?? "00:00").toString();

                    final hargaRaw = data["totalHarga"];
                    final harga = (hargaRaw is int)
                        ? hargaRaw
                        : int.tryParse("$hargaRaw") ?? 0;

                    final tanggal = _parseDate(tanggalStr);
                    final jamMulai = _parseTime(jamStr);
                    final jamSelesai = TimeOfDay(
                      hour: (jamMulai.hour + 2) % 24,
                      minute: jamMulai.minute,
                    );

                    jadwalList.add(
                      TeachingRequest(
                        namaSiswa:
                            (data["muridNama"] ?? data["namaSiswa"] ?? "-")
                                .toString(),
                        mapel: mapel,
                        alamat: (data["alamat"] ?? "-").toString(),
                        jarak: (data["jarak"] ?? "-").toString(),
                        harga: harga,
                        jumlahSiswa: 1,
                        tanggal: tanggal,
                        jamMulai: jamMulai,
                        jamSelesai: jamSelesai,
                        bookingId: (data["bookingId"] ?? entry.key).toString(),
                        muridUid: muridUid,
                        fotoUrl: "",
                      ),
                    );
                  }
                }
              }
            }

            final jadwalHariIni = jadwalList
                .where((j) => isSameDay(j.tanggal, today))
                .toList();

            final jadwalTanggalDipilih = jadwalList
                .where((j) => isSameDay(j.tanggal, _selectedDay))
                .toList();

            final selectedIsToday = isSameDay(_selectedDay, today);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Jadwal Mengajar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),

                  Container(
                    width: 480,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.orange.shade300,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: selectedIsToday ? Colors.orange : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    "Jadwal Hari Ini",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),

                  if (jadwalHariIni.isEmpty)
                    const Text(
                      "Belum ada jadwal hari ini",
                      style: TextStyle(color: Colors.grey),
                    ),

                  ...jadwalHariIni.map((j) => _JadwalTile(request: j)),

                  const SizedBox(height: 20),

                  if (!selectedIsToday) ...[
                    Text(
                      "Jadwal Tanggal ${DateFormat('dd-MM-yyyy').format(_selectedDay)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (jadwalTanggalDipilih.isEmpty)
                      const Text(
                        "Tidak ada jadwal di tanggal ini",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ...jadwalTanggalDipilih.map((j) => _JadwalTile(request: j)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _JadwalTile extends StatelessWidget {
  final TeachingRequest request;

  const _JadwalTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                DetailSiswaPage(request: request, showAcceptButton: false),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F4FB),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.school),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Les ${request.mapel} - ${request.namaSiswa}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(request.alamat),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
