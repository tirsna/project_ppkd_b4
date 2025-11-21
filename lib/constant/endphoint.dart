class Endpoint {
  static const String baseUrl = "https://appabsensi.mobileprojp.com/api";
  static const String register = "$baseUrl/register";
  static const String login = "$baseUrl/login";
  static const String batch = "$baseUrl/batches";
  static const String training = "$baseUrl/trainings";
  static const String attendanceIn = "$baseUrl/absen/check-in";
  static const String attendanceOut = "$baseUrl/absen/check-out";
  static const String editProfile = "$baseUrl/profile";
  static const String profile = "$baseUrl/profile";
  static const String deleteHistory = "$baseUrl/absen/history";
  static const String history = "$baseUrl/absen/history";
  static const String updateHistory = "$baseUrl/absen/history";
  static const String statistik = "$baseUrl/absen/stats?start=2025-07-31&end=2025-12-31";
}
