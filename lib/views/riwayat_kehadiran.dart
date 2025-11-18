import 'package:flutter/material.dart';

class KehadiranPage extends StatelessWidget {
  const KehadiranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Halaman
              const Text(
                "Riwayat Kehadiran",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // List Kehadiran
              Expanded(
                child: ListView(
                  children: [
                    _itemKehadiran(
                      tanggal: "10 November 2025",
                      jamMasuk: "08:02",
                      jamKeluar: "16:55",
                      status: "Hadir",
                      color: Colors.green,
                    ),
                    _itemKehadiran(
                      tanggal: "09 November 2025",
                      jamMasuk: "—",
                      jamKeluar: "—",
                      status: "Tidak Hadir",
                      color: Colors.red,
                    ),
                    _itemKehadiran(
                      tanggal: "08 November 2025",
                      jamMasuk: "08:40",
                      jamKeluar: "16:50",
                      status: "Telat",
                      color: Colors.orange,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Card Item Kehadiran — simple function biar rapih
  Widget _itemKehadiran({
    required String tanggal,
    required String jamMasuk,
    required String jamKeluar,
    required String status,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Info tanggal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tanggal,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text("Masuk : $jamMasuk"),
              Text("Keluar : $jamKeluar"),
            ],
          ),

          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
