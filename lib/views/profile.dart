import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ppkd_b4/service/api.dart';
import 'package:project_ppkd_b4/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editprofile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String nama = "";
  String email = "";
  String telp = "-";
  String? photoUrl;

  File? localPhoto; // FOTO LOKAL HASIL PICKER
  bool loading = true;

  final ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    final data = await AuthAPI.getProfile(token);

    setState(() {
      nama = data.data?.name ?? "-";
      email = data.data?.email ?? "-";
      photoUrl = data.data?.profilePhotoUrl;
      loading = false;
    });
  }

  // =================================
  // GANTI FOTO TANPA API
  // =================================
  Future<void> pickPhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() {
      localPhoto = File(image.path); // SIMPAN FOTO DI LOCAL
    });
  }

  Future<void> _logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove("token");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ============================================
                    // FOTO PROFIL — PRIORITAS FOTO LOKAL DULU
                    // ============================================
                    GestureDetector(
                      onTap: pickPhoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 55,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: localPhoto != null
                                ? FileImage(localPhoto!)
                                : (photoUrl != null
                                      ? NetworkImage(photoUrl!)
                                      : const AssetImage(
                                              "assets/images/kucingtos.jpg",
                                            )
                                            as ImageProvider),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      nama,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    const SizedBox(height: 30),

                    _info("Nomor Telepon", telp),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff6c63ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          final hasil = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfilePage(
                                oldEmail: email,
                                oldName: nama,
                              ),
                            ),
                          );

                          if (hasil != null) {
                            getData();
                          }
                        },
                        child: const Text(
                          "Edit Profil",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _logout,
                        child: const Text(
                          "Logout",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    const Spacer(),

                    const Text(
                      "Crafted by Wangsa Aditrisna",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _info(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
