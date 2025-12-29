import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../detail/detail_siswa.dart';
import '../../models/teaching_request.dart';

// ================= MODEL (DUMMY) =================

// ================= DETAIL SISWA =================

// ================= JADWAL PAGE =================
class JadwalPage extends StatefulWidget {
  const JadwalPage({super.key});

  @override
  State<JadwalPage> createState() => _JadwalPageState();
}

class _JadwalPageState extends State<JadwalPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  late final List<TeachingRequest> _jadwal;

  @override
  void initState() {
    super.initState();

    _jadwal = [
      TeachingRequest(
        namaSiswa: "Rudi",
        mapel: "Matematika",
        alamat: "Jakarta Barat",
        jarak: "2 km",
        harga: 85000,
        jumlahSiswa: 1,
        tanggal: DateTime.now(),
        jamMulai: const TimeOfDay(hour: 12, minute: 0), // ✅ koma
        jamSelesai: const TimeOfDay(hour: 15, minute: 0), // ✅ koma
      ),
      TeachingRequest(
        namaSiswa: "Ramon",
        mapel: "Matematika",
        alamat: "Jakarta Barat",
        jarak: "2 km",
        harga: 90000,
        jumlahSiswa: 2,
        tanggal: DateTime.now().add(const Duration(days: 2)),
        jamMulai: const TimeOfDay(hour: 16, minute: 0), // ✅ koma
        jamSelesai: const TimeOfDay(hour: 18, minute: 0), // ✅ koma
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final jadwalHariIni = _jadwal
        .where((j) => isSameDay(j.tanggal, today))
        .toList();

    final jadwalTanggalDipilih = _jadwal
        .where((j) => isSameDay(j.tanggal, _selectedDay))
        .toList();

    final selectedIsToday = isSameDay(_selectedDay, today);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TITLE =====
              const Text(
                "Jadwal Mengajar",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              // ===== GARIS KUNING 480 =====
              Container(
                width: 480,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              const SizedBox(height: 16),

              // ===== CALENDAR =====
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

              // ===== JADWAL HARI INI =====
              if (jadwalHariIni.isNotEmpty) ...[
                const Text(
                  "Jadwal Hari Ini",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...jadwalHariIni.map((j) => _JadwalTile(request: j)),
                const SizedBox(height: 20),
              ],

              // ===== JADWAL TANGGAL DIPILIH =====
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
                  const Text("Tidak ada jadwal di tanggal ini"),

                ...jadwalTanggalDipilih.map((j) => _JadwalTile(request: j)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ================= JADWAL TILE =================
class _JadwalTile extends StatelessWidget {
  final TeachingRequest request; // ✅ INI YANG KURANG

  const _JadwalTile({required this.request});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailSiswaPage(
              // ✅ NAMA BENAR
              request: request, // ✅ DATA DIKIRIM
            ),
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
