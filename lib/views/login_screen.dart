import 'package:flutter/material.dart';
import 'package:project_ppkd_b4/preferences/preferences.dart';
import 'package:project_ppkd_b4/views/botomnavigatros.dart'; // Ganti intinya()
import 'package:project_ppkd_b4/views/register_screen.dart';
import 'package:project_ppkd_b4/views/reset_password.dart';
import 'package:project_ppkd_b4/service/api.dart'; // Pastikan path ini benar untuk AuthAPI
import 'package:project_ppkd_b4/models/register_models.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>(); // Key untuk Form
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();

  // State untuk Loading
  bool _isLoading = false;

  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  // FUNGSI UTAMA UNTUK LOGIN
  Future<void> _loginAction() async {
    // 1. Validasi Input (Pastikan field terisi dan format email benar)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Mulai Loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Panggil API Login
      final Registermodels result = await AuthAPI.loginUser(
        email: emailC.text,
        password: passC.text,
      );
      MyPref.saveToken(result.data!.token.toString());
      // 4. SUKSES: Pindah ke halaman utama
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Berhasil!")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Ganti intinya() dengan nama class bottom navigation Anda
          builder: (context) => const intinya(),
        ),
      );
    } catch (e) {
      // 5. GAGAL: Tampilkan pesan error dari API/Exception
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login Gagal: ${e.toString()}")));
    } finally {
      // 6. Sembunyikan Loading
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget untuk membuat field dengan validator
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: label == "Email"
              ? TextInputType.emailAddress
              : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$label wajib diisi';
            }
            if (label == "Email" && !value.contains('@')) {
              return 'Masukkan format email yang valid';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.all(15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(height: 1.0),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // HEADER
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
                    "Presence App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              Form(
                key: _formKey, // Tambahkan Form Key di sini
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // EMAIL FIELD
                      _buildField(
                        controller: emailC,
                        label: "Email",
                        hint: "Masukkan email anda...",
                        isPassword: false,
                      ),

                      const SizedBox(height: 20),

                      // PASSWORD FIELD
                      _buildField(
                        controller: passC,
                        label: "Kata Sandi",
                        hint: "Masukkan kata sandi...",
                        isPassword: true,
                      ),

                      const SizedBox(height: 15),

                      // LUPA PASSWORD
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResetPasswordPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Lupa Kata Sandi?",
                            style: TextStyle(
                              color: Color(0xff1D5DFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1D5DFF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          // Panggil fungsi _loginAction, dinonaktifkan saat loading
                          onPressed: _isLoading ? null : _loginAction,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // REGISTER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Belum punya akun? "),
                          GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Color(0xff1D5DFF),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
