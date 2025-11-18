import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:project_ppkd_b4/models/chekcaut.dart';
import 'package:project_ppkd_b4/preferences/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/api.dart';

class CheckInOutPage extends StatefulWidget {
  final bool isCheckIn;
  const CheckInOutPage({super.key, required this.isCheckIn});

  @override
  State<CheckInOutPage> createState() => _CheckInOutPageState();
}

class _CheckInOutPageState extends State<CheckInOutPage> {
  String _currentTime = "";
  Timer? _timer;
  bool _isLoading = true;
  bool _isSending = false;
  bool _isAuthenticated = false;

  String _statusMessage = "Memuat data...";
  String? _base64Image;
  File? _imageFile;
  Position? _currentPosition;
  String _distanceText = "...";

  final double _targetLat = -6.2000;
  final double _targetLng = 106.8167;

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
        showMessage("Sesi habis, login ulang!", isError: true);
        Navigator.pop(context);
        return false;
      }
      return true;
    } catch (e) {
      showMessage("Gagal memuat sesi", isError: true);
      return false;
    }
  }

  Future<void> _loadInitialData() async {
    final isAuthenticated = await _checkAuthToken();
    if (!mounted) return;

    if (!isAuthenticated) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final pos = await _getCurrentLocation();

      final dist = Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        _targetLat,
        _targetLng,
      );

      final distText = dist >= 1000
          ? "${(dist / 1000).toStringAsFixed(2)} km"
          : "${dist.toStringAsFixed(2)} m";

      setState(() {
        _currentPosition = pos;
        _distanceText = distText;
        _statusMessage = "Lokasi OK • $distText dari kantor";
        _isAuthenticated = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = e.toString();
        _isLoading = false;
      });
      showMessage(_statusMessage, isError: true);
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) throw Exception("GPS OFF, aktifkan dulu");

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception("Izin lokasi ditolak");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Izin lokasi ditolak permanen");
    }

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _takePhoto() async {
    if (_isSending || !_isAuthenticated) return;

    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 60,
    );

    if (img == null) {
      showMessage("Foto dibatalkan", isError: true);
      return;
    }

    final file = File(img.path);
    final base64 = base64Encode(await file.readAsBytes());

    setState(() {
      _imageFile = file;
      _base64Image = base64;
    });

    showMessage("Foto berhasil diambil");
  }

  Future<void> _sendCheckin() async {
    if (_isSending ||
        !_isAuthenticated ||
        _imageFile == null ||
        _currentPosition == null)
      return;

    setState(() {
      _isSending = true;
      _statusMessage = "Mengirim data...";
    });

    final token = await MyPref.getToken();

    final DateTime now = DateTime.now();
    final String onlyDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final String timeNow = DateFormat("HH:mm").format(now);

    try {
      Chekcautmodel result = await AuthAPI.postCheckout(
        token: token!,
        attendanceDate: onlyDate,
        time: timeNow,
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        base64Image: _base64Image!,
        address:
            "Lat: ${_currentPosition!.latitude}, Lng: ${_currentPosition!.longitude}",
      );

      showMessage(result.message ?? "Berhasil!");

      if (!mounted) return;
      Navigator.pop(context, widget.isCheckIn);
    } catch (e) {
      showMessage("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void showMessage(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isCheckIn ? "Check In" : "Check Out";
    final buttonColor = widget.isCheckIn
        ? const Color(0xff1D5DFF)
        : Colors.red.shade600;
    final buttonText = widget.isCheckIn ? "Kirim Check In" : "Kirim Check Out";

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: buttonColor),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusMessage,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            // Lokasi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xffe7f0ff),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on, color: buttonColor, size: 30),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Lokasi: ${_currentPosition?.latitude.toStringAsFixed(4) ?? '...'}, "
                      "${_currentPosition?.longitude.toStringAsFixed(4) ?? '...'}\n"
                      "Jarak: $_distanceText",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Jam realtime
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  const Text(
                    "Jam Sekarang",
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _currentTime,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            OutlinedButton(
              onPressed: _isSending ? null : _takePhoto,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: buttonColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                _imageFile == null ? "Ambil Foto" : "Ulangi Foto",
                style: TextStyle(color: buttonColor, fontSize: 16),
              ),
            ),

            const SizedBox(height: 15),

            if (_imageFile != null)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                ),
              )
            else
              const Spacer(),

            ElevatedButton(
              onPressed: _isSending ? null : _sendCheckin,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      buttonText,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
