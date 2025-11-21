import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:project_ppkd_b4/constant/endphoint.dart';
import 'package:project_ppkd_b4/models/chekcaut.dart';
import 'package:project_ppkd_b4/models/profile_moderls.dart';
import 'package:project_ppkd_b4/models/register_models.dart';
import 'package:project_ppkd_b4/models/history_models.dart';
import 'package:project_ppkd_b4/models/statistik_models.dart';

class AuthAPI {
  // =====================================================
  //                    REGISTER
  // =====================================================
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

  // =====================================================
  //                    LOGIN
  // =====================================================
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

  // =====================================================
  //                    GET PROFILE
  // =====================================================
  static Future<Profilemodels> getProfile(String token) async {
    final url = Uri.parse(Endpoint.profile);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("STATUS PROFILE: ${response.statusCode}");
    log("BODY PROFILE: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Profilemodels.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal mengambil data profile");
    }
  }

  // =====================================================
  //                    EDIT PROFILE
  // =====================================================
  static Future<String> editProfile({
    required String token,
    required String name,
    required String email,
  }) async {
    final url = Uri.parse(Endpoint.editProfile);

    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({"name": name, "email": email}),
    );

    log("STATUS EDIT: ${response.statusCode}");
    log("BODY EDIT: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["message"] ?? "Berhasil update profil";
    } else {
      throw Exception("Gagal mengupdate profil");
    }
  }

  // =====================================================
  //                    CHECK IN
  // =====================================================
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
    final url = Uri.parse(Endpoint.attendanceIn);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": attendanceDate,
        "check_in": time,
        "check_in_address": address,
        "check_in_lat": latitude,
        "check_in_lng": longitude,
        "status": 'masuk',
      }),
    );

    log("STATUS ABSEN: ${response.statusCode}");
    log("BODY ABSEN: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["message"] ?? "Berhasil";
    } else {
      final msg =
          jsonDecode(response.body)["message"] ?? "Gagal mengirim absensi";
      throw Exception(msg);
    }
  }

  // =====================================================
  //                    CHECK OUT
  // =====================================================
  static Future<Chekcautmodel> postCheckout({
    required String token,
    required double latitude,
    required double longitude,
    required String base64Image,
    required String attendanceDate,
    required String address,
    required String time,
  }) async {
    final url = Uri.parse(Endpoint.attendanceOut);

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "attendance_date": attendanceDate,
        "check_out": time,
        "check_out_address": address,
        "check_out_lat": latitude,
        "check_out_lng": longitude,
        "status": 'pulang',
      }),
    );

    log("STATUS CHECKOUT: ${response.statusCode}");
    log("BODY CHECKOUT: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Chekcautmodel.fromJson(jsonDecode(response.body));
    } else {
      final msg =
          jsonDecode(response.body)["message"] ?? "Gagal melakukan checkout";
      throw Exception(msg);
    }
  }

  // =====================================================
  //                    GET HISTORY  (BARU)
  // =====================================================
  static Future<Historymodels> getHistory(String token) async {
    final url = Uri.parse(Endpoint.history);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("STATUS HISTORY: ${response.statusCode}");
    log("BODY HISTORY: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Historymodels.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Gagal mengambil riwayat");
    }
  }

  // =====================================================
  //                    DELETE HISTORY  (BARU)
  // =====================================================
  static Future<String> deleteHistory({
    required String token,
    required int id,
  }) async {
    final url = Uri.parse("${Endpoint.deleteHistory}?id=$id");

    final response = await http.delete(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    log("STATUS DELETE HISTORY: ${response.statusCode}");
    log("BODY DELETE HISTORY: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["message"] ?? "Berhasil menghapus";
    } else {
      throw Exception("Gagal menghapus riwayat");
    }
  }

  // =====================================================
  //                 UPDATE HISTORY (BARU)
  // =====================================================
  static Future<String> updateHistory({
    required String token,
    required int id,
    required String checkInTime,
    required String checkOutTime,
  }) async {
    final url = Uri.parse(Endpoint.updateHistory);

    final response = await http.put(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "id": id,
        "check_in_time": checkInTime,
        "check_out_time": checkOutTime,
      }),
    );

    log("STATUS UPDATE HISTORY: ${response.statusCode}");
    log("BODY UPDATE HISTORY: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body)["message"] ?? "Berhasil update";
    } else {
      throw Exception("Gagal update absensi");
    }
  }
  // =====================================================
//                   GET STATISTIK (BARU)
// =====================================================
static Future<Stasistikmodels> getStatistik(String token) async {
  final url = Uri.parse(Endpoint.statistik);

  final response = await http.get(
    url,
    headers: {
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  log("STATUS STATISTIK: ${response.statusCode}");
  log("BODY STATISTIK: ${response.body}");

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return Stasistikmodels.fromJson(jsonDecode(response.body));
  } else {
    throw Exception("Gagal mengambil data statistik");
  }
}

}
