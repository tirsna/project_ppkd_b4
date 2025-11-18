import 'package:flutter/material.dart';
import 'package:project_ppkd_b4/views/home_screen.dart';
import 'package:project_ppkd_b4/views/profile.dart';
import 'package:project_ppkd_b4/views/riwayat_kehadiran.dart';

class intinya extends StatefulWidget {
  const intinya({super.key});

  @override
  State<intinya> createState() => _intinyaState();
}

class _intinyaState extends State<intinya> {
  int pageIndex = 0;

  final pages = [
    const HomePage(),
    const KehadiranPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[pageIndex],

      // BOTTOM BAR
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.black12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(icon: Icons.home_filled, label: "Home", index: 0),

                const SizedBox(width: 70), // buat jarak si tombol tengah

                navItem(icon: Icons.person, label: "Profil", index: 2),
              ],
            ),
          ),

          Positioned(
            top: -25,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  pageIndex = 1;
                });
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: const Color(0xff1D5DFF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ITEM ICON KIRI & KANAN
  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = pageIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          pageIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Icon(
            icon,
            size: 28,
            color: isActive ? const Color(0xff1D5DFF) : Colors.black54,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? const Color(0xff1D5DFF) : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
