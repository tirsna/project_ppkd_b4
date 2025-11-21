import 'package:flutter/material.dart';
import 'package:project_ppkd_b4/service/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_ppkd_b4/models/history_models.dart';

class KehadiranPage extends StatefulWidget {
  const KehadiranPage({super.key});

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  List<Datum> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() => isLoading = true);

    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      final result = await AuthAPI.getHistory(token);
      setState(() {
        history = result.data ?? [];
      });
    } catch (e) {
      debugPrint("ERR: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // === KONFIRMASI HAPUS ===
  Future<void> confirmDelete(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Hapus Riwayat"),
          content: const Text("Yakin ingin menghapus riwayat ini?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteItem(id);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // === PROSES HAPUS API ===
  Future<void> deleteItem(int id) async {
    final pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    try {
      await AuthAPI.deleteHistory(token: token, id: id);
      loadHistory();
    } catch (e) {
      debugPrint("ERR DELETE: $e");
    }
  }

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
              const Text(
                "Riwayat Kehadiran",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : history.isEmpty
                    ? const Center(child: Text("Belum ada riwayat"))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, i) {
                          final item = history[i];

                          return _itemKehadiran(
                            id: item.id!,
                            tanggal:
                                "${item.attendanceDate!.day}-${item.attendanceDate!.month}-${item.attendanceDate!.year}",
                            jamMasuk: item.checkInTime ?? "-",
                            jamKeluar: item.checkOutTime ?? "-",
                            status: item.status ?? "-",
                            color: Colors.green,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemKehadiran({
    required int id,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT INFO
          Expanded(
            child: Column(
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
          ),

          // STATUS BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(width: 10),

          // DELETE BUTTON
          GestureDetector(
            onTap: () => confirmDelete(id),
            child: const Icon(Icons.delete, color: Colors.red, size: 26),
          ),
        ],
      ),
    );
  }
}
