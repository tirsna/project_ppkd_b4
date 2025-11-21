import 'package:flutter/material.dart';
import 'package:project_ppkd_b4/service/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfilePage extends StatefulWidget {
  final String oldName;
  final String oldEmail;

  const EditProfilePage({super.key, required this.oldName, required this.oldEmail});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    namaController.text = widget.oldName;
    emailController.text = widget.oldEmail;
  }

  Future<void> simpan() async {
    setState(() => loading = true);

    SharedPreferences pref = await SharedPreferences.getInstance();
    final token = pref.getString("token") ?? "";

    await AuthAPI.editProfile(
      token: token,
      name: namaController.text,
      email: emailController.text,
    );

    setState(() => loading = false);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff0f4ff),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit Profil", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundImage: AssetImage("assets/images/kucingtos.jpg"),
            ),
            const SizedBox(height: 20),

            _input("Nama Lengkap", namaController),
            _input("Email", emailController),

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
                onPressed: loading ? null : simpan,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Simpan Perubahan",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String title, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: title,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
