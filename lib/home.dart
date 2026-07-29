import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hcms/absence/absence.dart';
import 'package:hcms/absence/camera.dart';
import 'package:hcms/absence/camera_page.dart';
import 'package:hcms/dinas/dinas.dart';
import 'package:hcms/config.dart';
import 'package:hcms/login.dart';
import 'package:hcms/temp.dart';
import 'package:hcms/facedetector.dart';
import 'package:hcms/download.dart';
import 'package:hcms/error.dart';
import 'package:hcms/radius.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:hcms/models/config.dart';
import 'package:hcms/models/company.dart';
import 'package:hcms/models/nik.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms/dialog/loading_screen.dart';
import 'package:hcms/upload.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:link_text/link_text.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:dropdown_search/dropdown_search.dart';
//tes git
class MenuItem {
  final String company_name;
  final String database_name;

  MenuItem(this.company_name, this.database_name);
}

class MenuNIK {
  final String personalid;
  final String name;

  MenuNIK(this.personalid, this.name);
}

final List<String> imagePaths = [
  'assets/Logo-TSG-S.png',
  'assets/TE.png',
  'assets/citygarden.png',
];

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.url_api,
    required this.token,
    required this.type,
    required this.apikey,
    required this.imageslidePaths,
    required this.url_api_slide,
    required this.strdebug,
  });

  final String url_api;
  final String token;
  final String type;
  final String apikey;
  final List imageslidePaths;
  final String url_api_slide;
  final String strdebug;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();

  GlobalKey _globalKey = GlobalKey();
  bool isLoading = false;
  TextEditingController _NIKController = new TextEditingController();
  List<Company> itemlistcompany = [];

  List<MenuItem> menuItems = [];

  List<MenuNIK> menuNIKS = [];

  List imageslidePaths = [];

  String _tanggal = "";
  var newFormat = DateFormat("dd MMM yyyy");
  var clientFormat = DateFormat("yyyy-MM-dd");
  var yearFormat = DateFormat("yyyy");
  var monthFormat = DateFormat("M");
  var dayFormat = DateFormat("d");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");
  var tglFormat = DateFormat("dd MMM yyyy HH:mm:ss");
  final dt = new DateTime.now();
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime.now();

  String dayName = "";
  String dayNameInd = "";
  int dayOfMonth = 0;
  String url_api = "";

  String token = "";
  List companyItemlist = [];
  var dropdownvalue;
  String company_id = "";
  String company_name = "";
  String company_name2 = "";
  String listcompany_id = "";
  String listcompany_remark = "";
  String NIK = "";
  String employee_id = "";
  String employee_name = "";
  String employee_personalid = "";
  String employee_fingerid = "";
  String office_id = "";
  String _year = "";
  String _month = "";
  String employee_gender = "";
  String employee_dateofbirth = "";
  String divisi_name = "";
  String ho_date = "";
  String client_date = "";
  String database_name = "";
  String shift_id = "";
  String daynow = "";
  String dayyesterday = "";
  String _type = "";
  Uri uri = Uri.parse('http://www.example.com');

  bool _isSwitched = false;
  String strdebug = "Off";
  String url_api_prod =
      "https://api-hcm.transentertainment.com/index.php/api/v1/";

  // String url_api_dev = "http://172.16.4.96/api-ci3-dev/index.php/api/v1/";

  String url_api_dev =
      "https://api-hcmdev.transentertainment.com/index.php/api/v1/";

  String url_api_root = "";
  String url_api_slide = "";
  String url_api_image = "";
  String url_image_dev = "https://ssodev.transentertainment.com/";
  String url_image_prod = "https://sso.transentertainment.com/";
  String apikey = "";
  String _brand = "";
  String _model = "";
  String device_info = "";
  String strTimeZone = "";
  String office_name = "";
  String department_name = "";
  Position? _currentPosition;
  String _currentAddress = "";
  String strlatitude = "";
  String strlongitude = "";
  bool isLocation = false;
  String projectVersion = "";
  String _version_id = "";

  final Uri _url = Uri.parse('https://sso.transentertainment.com/download.php');
  String employee_type = "";

  final ImagePicker _picker = ImagePicker();

  TextEditingController _strController = TextEditingController();

  static const Color primaryBlue = Color(0xFF0A3D91); // Biru Gelap
  static const Color accentBlue = Color(0xFF00A6EB); // Biru Muda
  static const Color transRed = Color(0xFFE52320); // Merah
  static const Color transYellow = Color(0xFFFABE00); // Kuning
  static const Color textDark = Color(0xFF333333); // Hitam

  Color cekincolor = Colors.green;
  Color cekoutcolor = Colors.orange;

  @override
  void initState() {
    super.initState();
    getFromSharedPreferences();
    url_api_slide = widget.url_api_slide;
    imageslidePaths = widget.imageslidePaths;
    strdebug = widget.strdebug;
    requestPermission();
    strTimeZone = DateTime.now().timeZoneName;
    daynow = dayFormat.format(now);

    yesterday = now.subtract(Duration(days: 1));
    dayyesterday = dayFormat.format(yesterday);

    _tanggal = newFormat.format(now);
    _year = yearFormat.format(now);
    _month = monthFormat.format(now);
    client_date = clientFormat.format(now);
    dayName = DateFormat('EEEE').format(now);
    dayOfMonth = dt.day;
    if (dayName == "Sunday") {
      dayNameInd = "Minggu";
    } else if (dayName == "Monday") {
      dayNameInd = "Senin";
    } else if (dayName == "Tuesday") {
      dayNameInd = "Selasa";
    } else if (dayName == "Wednesday") {
      dayNameInd = "Rabu";
    } else if (dayName == "Thursday") {
      dayNameInd = "Kamis";
    } else if (dayName == "Friday") {
      dayNameInd = "Jumat";
    } else if (dayName == "Saturday") {
      dayNameInd = "Sabtu";
    }
    // dayNameInd = dayName;
    initPlatformState().then((result) {
      if (_deviceData.isNotEmpty) {
        _brand = _deviceData['brand'];
        _model = _deviceData['model'];
        device_info = _brand + " - " + _model;
        print(device_info);
      }
    });
    _getCurrentLocation();
  }

  Future<void> requestPermission() async {
    var status = await Permission.camera.status;
    var statusStorage = await Permission.storage.status;
    // _showDialog('Camera permission status 0 : $status');

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (statusStorage.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // Permission granted, proceed with camera operations
      print('Camera permission granted');
      // _showDialog("Camera permission granted");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, guide user to app settings
      print('Camera permission permanently denied. Open app settings.');
      // _showDialog("Camera permission permanently denied. Open app settings.");
      openAppSettings(); // Opens app settings for the user
    } else {
      // Handle other statuses like restricted or limited
      print('Camera permission status: $status');
      // _showDialog('Camera permission status2: $status');
    }

    if (statusStorage.isGranted) {
      // Permission granted, proceed with camera operations
      print('Storage permission granted');
      // _showDialog("Camera permission granted");
    } else if (statusStorage.isPermanentlyDenied) {
      // Permission permanently denied, guide user to app settings
      print('Storage permission permanently denied. Open app settings.');
      // _showDialog("Camera permission permanently denied. Open app settings.");
      openAppSettings(); // Opens app settings for the user
    } else {
      // Handle other statuses like restricted or limited
      print('Storage permission status: $statusStorage');
      // _showDialog('Camera permission status2: $status');
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 12;
    final TextEditingController menuController = TextEditingController();
    MenuItem? selectedMenu;

    final TextEditingController niksController = TextEditingController();
    MenuNIK? selectedNiks;

    // Warna utama ungu sesuai tema aplikasi pada gambar
    const Color primaryBlue = Color.fromARGB(255, 2, 115, 243);
    const Color cardBgColor = Color(0xFFE8F0FE);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        print('didPop');
      },
      child: Scaffold(
        backgroundColor: const Color(
            0xFFF5F5F5), // Mengubah background agar kontras dengan card menu putih
        body: RefreshIndicator(
          onRefresh: () async {
            _refresh();
            return Future<void>.delayed(const Duration(seconds: 2));
          },
          child: ListView(
            children: <Widget>[
              // 1. Banner Carousel
              CarouselSlider.builder(
                itemCount: imageslidePaths.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Stack(
                    children: [
                      Image.network(
                        url_api_slide + imageslidePaths[index]['value'],
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        bottom: 5.0,
                        child: Container(
                          color: Colors.black54,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      TimerBuilder.periodic(
                                          const Duration(seconds: 1),
                                          builder: (context) {
                                        return Text(
                                          "${getSystemTime()} $strTimeZone",
                                          textAlign: TextAlign.left,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        );
                                      }),
                                      Text(
                                        "$dayNameInd, $_tanggal",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w700),
                                        textAlign: TextAlign.left,
                                      ),
                                    ]),
                              ]),
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  viewportFraction: 1.0,
                  autoPlay: true,
                  enlargeCenterPage: false,
                  padEnds: false,
                  initialPage: 0,
                ),
              ),

              isLoading
                  ? const Center(
                      child: LinearProgressIndicator(),
                    )
                  : Container(),

              Text(
                "Selamat Datang, Suhendra",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),

              const SizedBox(height: 10),
              // Tombol Absen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: <Widget>[
                    // TOMBOL IN
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cekincolor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _navigateToFaceDetector(context, "Masuk");
                        },
                        child: const Text('IN'),
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                      width: 50,
                    ),
                    // TOMBOL OUT
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cekoutcolor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          _navigateToFaceDetector(context, "Keluar");
                        },
                        child: const Text('OUT'),
                      ),
                    ),
                  ],
                ),
              ),

              // 3. Tambahan Baru: Kontainer Menu
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: .0, vertical: 0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16.0),
                    child: Column(
                      children: [
                        // Grid Menu 2x2
                        GridView.count(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Agar tidak bentrok scroll dengan ListView utama
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _buildMenuCard(
                                'ABSENCE', "assets/absen_new.png", cardBgColor,
                                () {
                              _type = "ABSEN";
                              _navigateToAbsence(context);
                            }),
                            _buildMenuCard(
                                'CUTI', "assets/cuti_new.png", cardBgColor, () {
                              _type = "CUTI";
                              _navigateToAbsence(context);
                            }),
                            _buildMenuCard(
                                'SAKIT', "assets/sakit_new.png", cardBgColor,
                                () {
                              _type = "SAKIT";
                              _navigateToAbsence(context);
                            }),
                            _buildMenuCard(
                                'IZIN', "assets/izin_new.png", cardBgColor, () {
                              _type = "IZIN";
                              _navigateToAbsence(context);
                            }),
                            _buildMenuCard('SLIP GAJI',
                                "assets/slipgaji_new.png", cardBgColor, () {
                              // Aksi ketika menu ASSET HISTORY diklik
                            }),
                            _buildMenuCard(
                                'SPD', "assets/spd_new.png", cardBgColor, () {
                              // Aksi ketika menu ASSET HISTORY diklik
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Section 2: Info Lokasi / Kantor Terdekat
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Pengumuman',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Lihat Semua →',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 20),
                  children: [
                    _buildNewsCard(
                      'Aturan Kerja Baru',
                      'Wajib melakukan foto selfie saat melakukan absensi masuk.',
                      onTap: () {
                        // Tulis aksi navigasi atau logika Anda di sini
                        _showFullScreenDialog(context, 'Aturan Kerja Baru',
                            'Wajib melakukan foto selfie saat melakukan absensi masuk.');

                        // Contoh Navigasi ke Halaman Detail Berita:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailBeritaPage()));
                      },
                    ),
                    _buildNewsCard(
                      'Cuti Bersama 22 Juni 2026',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat',
                      onTap: () {
                        // Tulis aksi navigasi atau logika Anda di sini
                        _showFullScreenDialog(
                            context,
                            'Cuti Bersama 22 Juni 2026',
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat');

                        // Contoh Navigasi ke Halaman Detail Berita:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailBeritaPage()));
                      },
                    ),
                    _buildNewsCard(
                      'Lorem Ipsum',
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat',
                      onTap: () {
                        // Tulis aksi navigasi atau logika Anda di sini
                        _showFullScreenDialog(context, 'Lorem Ipsum',
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat');

                        // Contoh Navigasi ke Halaman Detail Berita:
                        // Navigator.push(context, MaterialPageRoute(builder: (context) => DetailBeritaPage()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),

        // 4.  Bottom Navigation Bar
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            // Memberikan bayangan halus di atas navbar agar efek melengkungnya lebih terlihat menonjol
            boxShadow: [
              BoxShadow(color: Colors.black12, spreadRadius: 0, blurRadius: 10),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: ClipRRect(
            // PENTING: Harus ditambahkan borderRadius di sini agar konten di dalamnya ikut terpotong melengkung
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: primaryBlue,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              currentIndex: 0,
              iconSize:
                  22, // Sedikit diperkecil dari default (24) agar muat 5 menu dengan rapi
              selectedLabelStyle: const TextStyle(
                fontSize:
                    11, // Disesuaikan ke 11 agar teks tidak memotong satu sama lain
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.2,
              ),
              onTap: (int index) {
                print("Navigasi ke index: $index");

                // 1. JIKA MENU ATTENDANCE (INDEX 2) DIKLIK
                if (index == 2) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors
                        .transparent, // Agar sudut melengkung Container terlihat
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize
                              .min, // Tinggi mengikuti jumlah konten
                          children: [
                            // Garis indikator kecil di atas modal
                            Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Attendence',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(),

                            // Pilihan 1: Absen
                            ListTile(
                              leading:
                                  const Icon(Icons.timer, color: primaryBlue),
                              title: const Text('Absen'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka halaman Absen");
                                _type = "ABSEN";
                                _navigateToAbsence(context);
                              },
                            ),

                            // Pilihan 2: Cuti
                            ListTile(
                              leading: const Icon(Icons.event_available,
                                  color: primaryBlue),
                              title: const Text('Cuti'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka formulir Cuti");
                                _type = "CUTI";
                                _navigateToAbsence(context);
                              },
                            ),

                            // Pilihan 3: Izin
                            ListTile(
                              leading: const Icon(Icons.assignment_turned_in,
                                  color: primaryBlue),
                              title: const Text('Izin'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka formulir Izin");
                                _type = "IZIN";
                                _navigateToAbsence(context);
                              },
                            ),

                            // Pilihan 4: PH (Public Holiday / Kerja di Hari Libur)
                            ListTile(
                              leading: const Icon(Icons.calendar_month,
                                  color: primaryBlue),
                              title: const Text('PH'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka formulir PH");
                                _type = "PH";
                                _navigateToAbsence(context);
                              },
                            ),
                            const SizedBox(height: 20), // Jarak aman bawah
                          ],
                        ),
                      );
                    },
                  );
                }
                // SPD
                else if (index == 3) {
                  Route route = MaterialPageRoute<void>(
                      builder: (context) => MainMenuAbsensi());
                  Navigator.push<void>(context, route);
                }
                // 2. JIKA MENU PROFILE (INDEX 4) DIKLIK
                else if (index == 4) {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                'Akun Saya',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.account_box,
                                  color: primaryBlue),
                              title: const Text('My Account'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka My Account");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.lock_reset,
                                  color: primaryBlue),
                              title: const Text('Change Password'),
                              onTap: () {
                                Navigator.pop(context);
                                print("Membuka Change Password");
                              },
                            ),
                            ListTile(
                              leading:
                                  const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Logout',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)),
                              onTap: () {
                                Navigator.pop(context);
                                print("Proses Logout");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage(
                                            title: "ABSENCE",
                                          )),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    },
                  );
                }
                // 3. LOGIKA UNTUK MENU LAIN (HOME, APPROVAL, SPD)
                else {
                  // Jalankan setState atau pindah halaman biasa di sini
                }
              },

              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_turned_in),
                  label: 'Approval',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.timer),
                  label: 'Attendance', // Sedikit koreksi typo dari 'Attendence'
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment_ind),
                  label: 'SPD',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsCard(String title, String artikel,
      {required VoidCallback onTap}) {
    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
            12), // Menjaga efek ripple tetap di dalam lengkungan
        child: Ink(
          decoration: BoxDecoration(
            color: accentBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                artikel,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(
      String title, String assetPath, Color bgColor, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mengganti Icon dengan Image.asset pembatas ukuran
            Image.asset(
              assetPath,
              height: 40, // Ukuran ideal untuk ikon menu grid
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _showDialog(String keterangan) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              //padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                keterangan,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: const Text(
              "OK",
              style: TextStyle(
                color: Color.fromARGB(255, 2, 8, 134),
                fontSize: 16.0,
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _showDialogDebug() async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              //padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                autofocus: true,
                controller: _strController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                //onChanged: (value) {
                //
                // },
              ),
            ),
          ],
        ),
        actions: <Widget>[
          Container(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("BATAL"),
          )),
          Container(
              child: ElevatedButton(
            onPressed: () {
              setState(() {
                _isSwitched = true;
                strdebug = "On";
                url_api = _strController.text;
                _NIKController.text = "";
              });
              Navigator.pop(context);
            },
            child: new Text("OK"),
          )),
        ],
      ),
    );
  }

  _showDialogDownload() async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text('Mohon update apps yang terbaru, silahkan download : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                )),
        content: SizedBox(
          height: 100, // Fixed height for the content area
          child: Column(children: <Widget>[
            // LinkText("https://sso.transentertainment.com/download.php"),
            GestureDetector(
              onTap: () async {
                _launchInAppWebView();
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  // "https://sso.transentertainment.com/download.php",
                  "https://sso.transentertainment.com/download.php",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFullScreenDialog(
      BuildContext context, String title, String artikel) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.white, // Dark background for the dialog
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.white, // Black background for the image
          body: Stack(
            children: [
              // Menggunakan SingleChildScrollView agar konten artikel panjang bisa di-scroll
              SingleChildScrollView(
                // PERBAIKAN: Menambahkan padding di seluruh sisi konten teks
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Jarak atas disesuaikan agar tidak tertutup tombol close
                    const SizedBox(height: 80),
                    Text(
                      title,
                      // maxLines dihapus agar judul panjang bisa turun ke baris baru di halaman detail
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize:
                            20, // Ukuran font judul diperbesar agar lebih proporsional
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      artikel,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height:
                            1.5, // Mengatur spasi antar baris agar lebih nyaman dibaca
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40, // Adjust position as needed
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFullScreenAllDialog(
      BuildContext context, String title, String artikel) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.white, // Dark background for the dialog
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.white, // Black background for the image
          body: Stack(
            children: [
              // Menggunakan SingleChildScrollView agar konten artikel panjang bisa di-scroll
              SingleChildScrollView(
                // PERBAIKAN: Menambahkan padding di seluruh sisi konten teks
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Jarak atas disesuaikan agar tidak tertutup tombol close
                    const SizedBox(height: 80),
                    Text(
                      title,
                      // maxLines dihapus agar judul panjang bisa turun ke baris baru di halaman detail
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize:
                            20, // Ukuran font judul diperbesar agar lebih proporsional
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      artikel,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        height:
                            1.5, // Mengatur spasi antar baris agar lebih nyaman dibaca
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40, // Adjust position as needed
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("H:m:s").format(now);
  }

  Future<int> getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      listcompany_id = prefs.getString("listcompany_id") ?? "";
      listcompany_remark = prefs.getString("listcompany_remark") ?? "";
      company_id = prefs.getString("company_id") ?? "";
      company_name = prefs.getString("company_name") ?? "";
      employee_id = prefs.getString("employee_id") ?? "";
      employee_name = prefs.getString("employee_name") ?? "";
      employee_personalid = prefs.getString("employee_personalid") ?? "";
      employee_fingerid = prefs.getString("employee_fingerid") ?? "";
      office_id = prefs.getString("office_id") ?? "";
      employee_dateofbirth = prefs.getString("employee_dateofbirth") ?? "";
      employee_gender = prefs.getString("employee_gender") ?? "";
      divisi_name = prefs.getString("divisi_name") ?? "";
      database_name = prefs.getString("database_name") ?? "";
      shift_id = prefs.getString("shift_id") ?? "";
      url_api_slide = prefs.getString("url_api_slide") ?? "";
      url_api_image = prefs.getString("url_api_image") ?? "";
      device_info = prefs.getString("device_info") ?? "";
      department_name = prefs.getString("department_name") ?? "";
      office_name = prefs.getString("office_name") ?? "";
      company_name2 = prefs.getString("company_name2") ?? "";
      employee_type = prefs.getString("employee_type") ?? "";
    });
    return 0;
  }

  void _navigateToFaceDetector(BuildContext context, String modeAbsen) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => FaceDetectorCameraScreen(
              modeAbsen: modeAbsen,
              url_api: widget.url_api,
              token: widget.token,
              type: _type,
              apikey: widget.apikey,
              employee_id: employee_id,
              employee_personalid: employee_personalid,
              employee_name: employee_name,
              latitude: strlatitude,
              longitude: strlongitude,
              date_yesterday: "",
              // camera: firstCamera,
            ));
    Navigator.push<void>(context, route);
  }

  void _navigateToAbsence(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => AbsencePage(
              url_api: url_api,
              token: token,
              type: _type,
              apikey: apikey,
              imageslidePaths: imageslidePaths,
              url_api_slide: url_api_slide,
              strdebug: strdebug,
              // camera: firstCamera,
            ));
    Navigator.push<void>(context, route);
  }

  Future<int> setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("listcompany_id", listcompany_id);
    await prefs.setString("listcompany_remark", listcompany_remark);
    await prefs.setString("employee_idno", NIK);
    await prefs.setString("company_id", company_id);
    await prefs.setString("company_name", company_name);
    await prefs.setString("employee_id", employee_id);
    await prefs.setString("employee_name", employee_name);
    await prefs.setString("employee_personalid", employee_personalid);
    await prefs.setString("employee_fingerid", employee_fingerid);
    await prefs.setString("office_id", office_id);
    await prefs.setString("url_api", url_api);
    await prefs.setString("employee_dateofbirth", employee_dateofbirth);
    await prefs.setString("employee_gender", employee_gender);
    await prefs.setString("divisi_name", divisi_name);
    await prefs.setString("database_name", database_name);
    await prefs.setString("shift_id", shift_id);
    await prefs.setString("url_api_slide", url_api_slide);
    await prefs.setString("url_api_image", url_api_image);
    await prefs.setString("device_info", device_info);
    await prefs.setString("office_name", office_name);
    await prefs.setString("department_name", department_name);
    await prefs.setString("company_name2", company_name2);
    await prefs.setString("employee_type", employee_type);

    return 0;
  }

  Future<void> _refresh() async {
    _getCurrentLocation();
  }

  // Future<String> HOdate() async {
  //   String strhasil = "";
  //   fh.HOdate(apikey, token, "headofficedate/show", url_api).then((hasils) {
  //     if (hasils.length > 0) {
  //       hasils.forEach((rows) {
  //         setState(() {
  //           strhasil = rows['ho_date'];
  //         });
  //       });
  //     }
  //   });
  //   return strhasil;
  // }

  //to show our dialog
  Future<void> showLoadingDialog(
    String status,
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(status),
            ],
          ),
        );
      },
    );
  }

// to hide our current dialog
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> initPlatformState() async {
    late Map<String, dynamic> deviceData;
    String platformVersion;

    String platformImei;
    String idunique;
    String mac_address;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        print('_deviceData');
        print(_deviceData['id']);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
      // _deviceNew = _mac_address;
      // print("_mac_address : " + _mac_address);
      print("_platformVersion");
      // print(_platformVersion);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
      platformVersion = 'Failed to get Device MAC Address.';
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'brand': build.brand,
      'display': build.display,
      'board': build.board,
      'device': build.device,
      'androidId': build.androidId,
    };
  }

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<String> getLocalTimezone() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print(currentTimeZone);
    return currentTimeZone;
  }

  _getCurrentLocation() async {
    print('_getAddressFromLatLng2');
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      print('_getAddressFromLatLng');
      setState(() {
        isLocation = true;
        _currentPosition = position;

        _getAddressFromLatLng();

        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLocation = false;
      });
      print(e);
      print('_getAddressFromLatLng');
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
        _currentAddress =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print('strlatitude');
        print(strlatitude);
        print('strlongitude');
        print(strlongitude);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchWebUrl() async {
    final Uri url =
        Uri.parse('https://sso.transentertainment.com/download.php');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInAppWebView() async {
    final Uri url =
        Uri.parse('https://sso.transentertainment.com/download.php');
    await launchUrl(url, mode: LaunchMode.inAppWebView);
  }

  Future<void> _takePicture() async {
    DateTime now = DateTime.now();
    // String tglRemark = tglFormat.format(now);
    // String imgname = imageFormat.format(now);

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );
    if (pickedFile != null) {}
  }
}
