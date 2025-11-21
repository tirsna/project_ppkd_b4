import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:project_ppkd_b4/models/statistik_models.dart';
import 'package:project_ppkd_b4/service/api.dart';
import 'package:project_ppkd_b4/views/chekcaut.dart';
import 'package:project_ppkd_b4/views/chekin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Data? _statistikAbsen;
  bool _isLoadingStatistik = true;

  GoogleMapController? _googleMapController;

  LatLng _currentPosition = LatLng(-6.2000, 108.816666);
  String _currentAddress = "Alamat tidak ditemukan";
  Marker? _marker;

  String _userName = "pengguna";
  String _currentDate = "";
  String _greeting = "Halo";
  bool _isLoading = true;

  // Warna tema biru soft
  final Color primaryColor = const Color(0xFF5A86FF);
  final Color accentColor = const Color(0xFF8CC8FF);
  final Color backgroundColor = const Color(0xFFEFF5FF);
  final Color cardBackgroundColor = const Color(0xFFFFFFFF);
  final Color textPrimaryColor = const Color(0xFF1E2A78);
  final Color textSecondaryColor = const Color(0xFF4A6FA5);

  @override
  void initState() {
    super.initState();
    _loadUserDataAndDate();
    _getCurrentLocation();
    _loadStatistikAbsen();
  }

  Future<void> _loadStatistikAbsen() async {
    setState(() => _isLoadingStatistik = true);
    try {
      final pref = await SharedPreferences.getInstance();
      final token = pref.getString("token") ?? "";

      final stat = await AuthAPI.getStatistik(token);

      if (mounted) {
        setState(() {
          _statistikAbsen = stat.data;
        });
      }
    } catch (e) {
      debugPrint("Error load statistik: $e");
    } finally {
      if (mounted) setState(() => _isLoadingStatistik = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return "Selamat Pagi";
    if (hour < 15) return "Selamat Siang";
    if (hour < 18) return "Selamat Sore";
    return "Selamat Malam";
  }

  Future<void> _loadUserDataAndDate() async {
    setState(() => _isLoading = true);
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('userName');
      final dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');

      if (mounted) {
        setState(() {
          _userName = name ?? "Pengguna";
          _greeting = _getGreeting();
          _currentDate = dateFormat.format(DateTime.now());
        });
      }
    } catch (e) {
      debugPrint("Error loading user data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void openGoogleMaps() async {
    final lat = _currentPosition.latitude;
    final lng = _currentPosition.longitude;
    final googleUrl =
        "https://www.google.com/maps/search/?api=1&query=$lat,$lng";

    await launchUrl(Uri.parse(googleUrl), mode: LaunchMode.externalApplication);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();

      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _currentPosition = LatLng(position.latitude, position.longitude);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      _currentPosition.latitude,
      _currentPosition.longitude,
    );

    Placemark place = placemarks[0];

    setState(() {
      _marker = Marker(
        markerId: const MarkerId("lokasi_saya"),
        position: _currentPosition,
        infoWindow: InfoWindow(
          title: "Lokasi Anda",
          snippet: "${place.street}, ${place.locality}",
        ),
      );

      _currentAddress =
          "${place.name}, ${place.street}, ${place.locality}, ${place.country}, ${place.postalCode}";

      _googleMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentPosition, zoom: 16),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),

              // =========================
              //  HEADER BARU TANPA FOTO
              // =========================
              Text(
                _greeting,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: textPrimaryColor,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                _userName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                _currentDate,
                style: TextStyle(fontSize: 14, color: textSecondaryColor),
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CheckInPage(isCheckIn: true),
                          ),
                        );
                      },
                      child: const Text(
                        "CHECK IN",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const CheckInOutPage(isCheckIn: false),
                          ),
                        );
                      },
                      child: Text(
                        "CHECK OUT",
                        style: TextStyle(color: primaryColor, fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    myLocationEnabled: true,
                    markers: _marker != null ? {_marker!} : {},
                    initialCameraPosition: CameraPosition(
                      target: _currentPosition,
                      zoom: 15,
                    ),
                    onMapCreated: (controller) {
                      _googleMapController = controller;
                    },
                  ),
                ),
              ),

              const SizedBox(height: 25),

              _buildDistanceCard(),
              const SizedBox(height: 25),
              _buildStatistikCard(),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            "Distance from place",
            style: TextStyle(fontSize: 14, color: textSecondaryColor),
          ),
          const SizedBox(height: 5),
          Text(
            "250.43m",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: openGoogleMaps,
              child: Text(
                "Open Maps",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statItem("Total Absen", _statistikAbsen?.totalAbsen ?? 0, Icons.check),
        _statItem("Masuk", _statistikAbsen?.totalMasuk ?? 0, Icons.login),
        _statItem("Izin", _statistikAbsen?.totalIzin ?? 0, Icons.assignment),
        _statItem(
          "Hari Ini",
          (_statistikAbsen?.sudahAbsenHariIni ?? false) ? 1 : 0,
          Icons.today,
        ),
      ],
    );
  }

  Widget _statItem(String title, int value, IconData icon) {
    return Container(
      width: 75,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: 28),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: textSecondaryColor),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
