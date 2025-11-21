import 'package:flutter/material.dart';
import 'package:project_ppkd_b4/views/home_screen.dart';
import 'package:project_ppkd_b4/views/profile.dart';
import 'package:project_ppkd_b4/views/riwayat_kehadiran.dart';

class Intinya extends StatefulWidget {
  const Intinya({super.key});

  @override
  State<Intinya> createState() => _IntinyaState();
}

class _IntinyaState extends State<Intinya> with TickerProviderStateMixin {
  int pageIndex = 0;
  final pages = [const HomePage(), const KehadiranPage(), const ProfilePage()];
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onNavTap(int index) {
    setState(() => pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: pages,
      ),
      bottomNavigationBar: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: navItem(icon: Icons.home_filled, label: "Home", index: 0),
            ),
            Expanded(
              child: navItem(icon: Icons.history, label: "Riwayat", index: 1),
            ),
            Expanded(
              child: navItem(icon: Icons.person, label: "Profil", index: 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget navItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isActive = pageIndex == index;

    return GestureDetector(
      onTap: () => onNavTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isActive ? Colors.blue : Colors.black54,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.blue : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
