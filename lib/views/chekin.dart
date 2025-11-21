import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_ppkd_b4/preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api.dart';

class CheckInPage extends StatefulWidget {
  final bool isCheckIn;
  const CheckInPage({super.key, required this.isCheckIn});

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  String _currentTime = "";
  Timer? _timer;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isAuthenticated = false;

  String _statusMessage = "Memuat data...";
  String? _base64Image;
  File? _imageFile;
  Position? _currentPosition;

  final double _targetLat = -6.2000;
  final double _targetLng = 106.8167;
  String _distanceText = "Mengecek jarak...";

  // Warna soft / adem
  final Color primaryColor = const Color(0xFF4A90E2);
  final Color accentColor = const Color(0xFF6AC7C9);
  final Color backgroundColor = const Color(0xFFF9FAFB);
  final Color cardBackgroundColor = const Color(0xFFE8F4FF);
  final Color textPrimaryColor = const Color(0xFF333333);
  final Color textSecondaryColor = const Color(0xFF666666);

  @override
  void initState() {
    super.initState();
    _startClock();
    _loadInitialData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime =
          "${now.hour.toString().padLeft(2, '0')} : ${now.minute.toString().padLeft(2, '0')} : ${now.second.toString().padLeft(2, '0')}";
    });
  }

  Future<bool> _checkAuthToken() async {
    try {
      final token = await MyPref.getToken();
      if (token == null || token.isEmpty) {
        if (!mounted) return false;
        showMessage("Sesi berakhir. Mohon login kembali.", isError: true);
        Navigator.pop(context);
        return false;
      }
      return true;
    } catch (e) {
      if (!mounted) return false;
      showMessage("Gagal memuat sesi: ${e.toString()}", isError: true);
      Navigator.pop(context);
      return false;
    }
  }

  Future<void> _loadInitialData() async {
    final isAuthenticated = await _checkAuthToken();
    if (!mounted) return;
    if (!isAuthenticated) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    try {
      final position = await _getCurrentLocation();
      final distanceInMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _targetLat,
        _targetLng,
      );
      final distanceText = distanceInMeters >= 1000
          ? "${(distanceInMeters / 1000).toStringAsFixed(2)} km"
          : "${distanceInMeters.toStringAsFixed(2)} meter";

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
        _distanceText = distanceText;
        _statusMessage = "Lokasi OK. Jarak: $distanceText";
        _isAuthenticated = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
      showMessage(_statusMessage, isError: true);
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw Exception('Layanan lokasi dinonaktifkan. Mohon aktifkan GPS.');
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Aktifkan di pengaturan.');
    }
    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _takePhoto() async {
    if (_isSending || !_isAuthenticated) return;
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (image == null) {
        showMessage("Pengambilan foto dibatalkan.", isError: true);
        return;
      }
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      final base64 = base64Encode(bytes);
      if (!mounted) return;
      setState(() {
        _imageFile = file;
        _base64Image = base64;
      });
      showMessage("Foto berhasil diambil!");
    } catch (_) {
      showMessage(
        "Gagal membuka kamera. Pastikan izin kamera aktif.",
        isError: true,
      );
    }
  }

  void _sendCheckin() async {
    if (_isSending || _isLoading || !_isAuthenticated) return;
    if (_currentPosition == null) {
      showMessage("Lokasi belum didapatkan.", isError: true);
      return;
    }
    if (_base64Image == null) {
      showMessage("Ambil foto terlebih dahulu.", isError: true);
      return;
    }

    setState(() {
      _isSending = true;
      _statusMessage = "Mengirim data...";
    });

    try {
      final token = await MyPref.getToken();
      final attendanceDate = DateTime.now();
      final dateOnly =
          "${attendanceDate.year}-${attendanceDate.month.toString().padLeft(2, '0')}-${attendanceDate.day.toString().padLeft(2, '0')}";
      final dateNow = DateTime.now();
      final formattedTime = DateFormat('HH:mm').format(dateNow);
      final address =
          "Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}";

      final message = await AuthAPI.postAttenddance(
        token: token!,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        base64Image: _base64Image!,
        isCheckIn: widget.isCheckIn,
        attendanceDate: dateOnly,
        address: address,
        time: formattedTime,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isCheckInDone', widget.isCheckIn);

      showMessage(message);
      if (mounted) {
        Navigator.pop(context, widget.isCheckIn);
      }
    } catch (e) {
      final msg = e.toString().replaceFirst("Exception: ", "");
      showMessage("Gagal mengirim: $msg", isError: true);
      if (mounted) {
        setState(() {
          _statusMessage = "Gagal: $msg";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? "Check In" : "Check Out";
    final buttonText = widget.isCheckIn ? "Kirim Check In" : "Kirim Check Out";
    final buttonColor = widget.isCheckIn ? primaryColor : Colors.red.shade600;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: buttonColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 14,
                color:
                    _statusMessage.contains("Gagal") ||
                        _statusMessage.contains("Sesi berakhir")
                    ? Colors.red
                    : textSecondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: primaryColor, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lokasi Anda: ${(_currentPosition?.latitude.toStringAsFixed(4) ?? '...')}, ${(_currentPosition?.longitude.toStringAsFixed(4) ?? '...')}",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        Text(
                          "Jarak dari kantor: $_distanceText",
                          style: TextStyle(
                            fontSize: 13,
                            color: textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: cardBackgroundColor,
              ),
              child: Column(
                children: [
                  Text(
                    "Jam Sekarang",
                    style: TextStyle(fontSize: 14, color: textSecondaryColor),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _currentTime,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: (_isSending || !_isAuthenticated)
                    ? null
                    : _takePhoto,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  side: BorderSide(color: buttonColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _imageFile == null ? "Ambil Foto" : "Ulangi Ambil Foto",
                  style: TextStyle(color: buttonColor, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 15),
            if (_imageFile != null)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
              )
            else
              const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    (_isSending ||
                        _isLoading ||
                        _imageFile == null ||
                        _currentPosition == null ||
                        !_isAuthenticated)
                    ? null
                    : _sendCheckin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
