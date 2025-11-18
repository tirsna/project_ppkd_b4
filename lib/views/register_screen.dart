import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_ppkd_b4/service/api.dart';
import 'package:project_ppkd_b4/service/api_training.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final namaC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final pass2C = TextEditingController();

  // State untuk data API
  bool isLoading = true;
  // State untuk proses registrasi
  bool isRegistering = false;

  String? selectedGender;
  int? selectedTrainingId;
  int? selectedBatchId;

  List<Map<String, dynamic>> trainingList = [];
  List<Map<String, dynamic>> batchList = [];

  String? profileBase64;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // --- FUNGSI AMBIL DATA API AWAL ---
  Future<void> fetchData() async {
    try {
      final trainingData = await TrainingAPI.getTraining();
      final batchData = await TrainingAPI.getBatch();

      trainingList = trainingData
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
      batchList = batchData
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (e) {
      log("Error fetching data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat data: ${e.toString()}")),
      );
    }

    // Pastikan loading berhenti terlepas dari berhasil atau gagal
    isLoading = false;
    setState(() {});
  }

  // --- FUNGSI AMBIL FOTO ---
  Future pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) {
      final bytes = await File(img.path).readAsBytes();
      // Format Base64 untuk JSON: Tambahkan prefix 'data:image/jpeg;base64,'
      profileBase64 = "data:image/jpeg;base64,${base64Encode(bytes)}";
      setState(() {});
    }
  }

  // --- FUNGSI AKSI REGISTRASI ---
  Future registerAction() async {
    // 1. Validasi Input
    if (namaC.text.isEmpty ||
        emailC.text.isEmpty ||
        passC.text.isEmpty ||
        pass2C.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua data wajib diisi!")));
      return;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis kelamin dulu!")),
      );
      return;
    }

    if (selectedTrainingId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih training dulu!")));
      return;
    }

    if (selectedBatchId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih batch dulu!")));
      return;
    }

    if (passC.text != pass2C.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak sama!")));
      return;
    }

    // Mencegah klik ganda saat proses berjalan
    if (isRegistering) return;

    // 2. Mulai Proses Registrasi dan tampilkan loading
    setState(() {
      isRegistering = true;
    });

    try {
      await AuthAPI.registerUser(
        name: namaC.text,
        email: emailC.text,
        password: passC.text,
        jenisKelamin: selectedGender!,
        profilePhotoBase64: profileBase64 ?? "",
        trainingId: selectedTrainingId!,
        batchId: selectedBatchId!,
      );

      // 3. Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berhasil daftar. Silakan Login!")),
      );

      // Kembali ke halaman login
      Navigator.pop(context);
      // Atau jika Anda ingin navigasi ke halaman login yang spesifik:
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } catch (e) {
      // 4. Gagal
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    // 5. Akhiri Proses Registrasi dan sembunyikan loading
    setState(() {
      isRegistering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        // Tampilkan Loading Awal jika data belum dimuat
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 50),
                      decoration: const BoxDecoration(
                        color: Color(0xff1D5DFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(35),
                          bottomRight: Radius.circular(35),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // FOTO PROFIL
                    GestureDetector(
                      onTap: pickPhoto,
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: profileBase64 == null
                            ? null
                            : MemoryImage(
                                base64Decode(profileBase64!.split(',').last),
                              ),
                        child: profileBase64 == null
                            ? const Icon(Icons.camera_alt, size: 40)
                            : null,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildLabel("Nama Lengkap"),
                          buildField(namaC, "Masukkan nama..."),

                          buildLabel("Email"),
                          buildField(emailC, "Masukkan email..."),

                          buildLabel("Jenis Kelamin"),
                          DropdownButtonFormField<String>(
                            decoration: dropdownStyle(),
                            value: selectedGender,
                            hint: const Text("Pilih jenis kelamin"),
                            items: const [
                              DropdownMenuItem(
                                value: "L",
                                child: Text("Laki-laki"),
                              ),
                              DropdownMenuItem(
                                value: "P",
                                child: Text("Perempuan"),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => selectedGender = v),
                          ),

                          buildLabel("Training"),
                          DropdownButtonFormField<int>(
                            decoration: dropdownStyle(),
                            value: selectedTrainingId,
                            hint: const Text("Pilih Training"),
                            isExpanded: true,
                            menuMaxHeight: 300,
                            items: trainingList.map<DropdownMenuItem<int>>((e) {
                              return DropdownMenuItem<int>(
                                value: e["id"],
                                child: Text(
                                  e["title"],
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedTrainingId = v),
                          ),

                          buildLabel("Batch"),
                          DropdownButtonFormField<int>(
                            decoration: dropdownStyle(),
                            value: selectedBatchId,
                            hint: const Text("Pilih Batch"),
                            isExpanded: true,
                            menuMaxHeight: 300,
                            items: batchList.map<DropdownMenuItem<int>>((e) {
                              return DropdownMenuItem<int>(
                                value: e["id"],
                                child: Text("Batch ${e["batch_ke"]}"),
                              );
                            }).toList(),
                            onChanged: (v) =>
                                setState(() => selectedBatchId = v),
                          ),

                          buildLabel("Password"),
                          buildField(
                            passC,
                            "Masukkan password...",
                            isPass: true,
                          ),

                          buildLabel("Konfirmasi Password"),
                          buildField(
                            pass2C,
                            "Ulangi password...",
                            isPass: true,
                          ),

                          const SizedBox(height: 25),

                          // TOMBOL DAFTAR
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1D5DFF),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Panggil registerAction. Tombol dinonaktifkan saat isRegistering = true
                            onPressed: isRegistering ? null : registerAction,
                            child: isRegistering
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Daftar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                          ),

                          // Link ke Halaman Login (Opsional)
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Sudah punya akun? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Login di sini",
                                  style: TextStyle(
                                    color: Color(0xff1D5DFF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 5),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget buildField(
    TextEditingController c,
    String hint, {
    bool isPass = false,
  }) {
    return TextField(
      controller: c,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(15),
      ),
    );
  }

  InputDecoration dropdownStyle() => InputDecoration(
    filled: true,
    fillColor: Colors.grey.shade100,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
  );
}
