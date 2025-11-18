import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:project_ppkd_b4/constant/endphoint.dart';
import 'package:project_ppkd_b4/models/register_models.dart';

class AuthAPI {
  static Future<Registermodels> registerUser({
    required String name,
    required String email,
    required String password,
    required String jenisKelamin,
    required String? profilePhotoBase64,
    required int trainingId,
    required int batchId,
  }) async {
    final url = Uri.parse(Endpoint.register);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "jenis_kelamin": jenisKelamin,
        "profile_photo": profilePhotoBase64 ?? "",
        "training_id": trainingId,
        "batch_id": batchId,
      }),
    );

    log("STATUS: ${response.statusCode}");
    log("BODY: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Registermodels.fromJson(json.decode(response.body));
    } else {
      final msg = json.decode(response.body)["message"] ?? "Terjadi kesalahan";
      throw Exception(msg);
    }
  }

  static Future<Registermodels> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"email": email, "password": password}),
    );

    log("STATUS LOGIN: ${response.statusCode}");
    log("BODY LOGIN: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Registermodels.fromJson(json.decode(response.body));
    } else {
      final msg = json.decode(response.body)["message"] ?? "Login gagal";
      throw Exception(msg);
    }
  }

  static Future<String> postAttenddance({
    required String token,
    required double latitude,
    required double longitude,
    required String base64Image,
    required bool isCheckIn,
    required String attendanceDate,
    required String address,
    required String time,
  }) async {
    final url = Uri.parse(
      Endpoint.attendanceIn,
    ); // Pastikan Endpoint.attendance sudah ada

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": attendanceDate,
        "check_in" : time,
        "check_in_address": address,
        "check_in_lat": latitude,
        "check_in_lng": longitude,
        "status": 'masuk',
        // "photo": base64Image,
        // "type": isCheckIn ? "check_in" : "check_out",
      }),
    );

    log("STATUS ABSEN: ${response.statusCode}");
    log("BODY ABSEN: ${response.body}");

    // Jika sukses
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["message"] ?? "Berhasil";
    } else {
      final msg =
          jsonDecode(response.body)["message"] ?? "Gagal mengirim absensi";
      throw Exception(msg);
    }
  }
}
