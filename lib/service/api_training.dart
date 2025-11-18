import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:project_ppkd_b4/constant/endphoint.dart';

class TrainingAPI {
  static Future<List<dynamic>> getTraining() async {
    final url = Uri.parse(Endpoint.training);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log("STATUS TRAINING: ${response.statusCode}");
    log("BODY TRAINING: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      // AUTO DETECT DATA
      if (data["data"] != null && data["data"] is List) {
        return data["data"];
      } else if (data["training"] != null) {
        return data["training"];
      } else if (data is List) {
        return data;
      }

      return [];
    } else {
      throw Exception("Gagal mengambil data training");
    }
  }

  static Future<List<dynamic>> getBatch() async {
    final url = Uri.parse(Endpoint.batch);

    final response = await http.get(
      url,
      headers: {"Accept": "application/json"},
    );

    log("STATUS BATCH: ${response.statusCode}");
    log("BODY BATCH: ${response.body}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);

      // AUTO DETECT DATA
      if (data["data"] != null && data["data"] is List) {
        return data["data"];
      } else if (data["batch"] != null) {
        return data["batch"];
      } else if (data is List) {
        return data;
      }

      return [];
    } else {
      throw Exception("Gagal mengambil data batch");
    }
  }
}
