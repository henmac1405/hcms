import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'app_colors.dart'; // Memastikan manajemen warna terpusat tetap konsisten
import 'dart:async';
import 'user_session.dart';
import 'facedetector.dart';
// import 'package:hcms/database/function_helper.dart';

class HomeContentSection extends StatefulWidget {
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<List<dynamic>> absenceData;
  final List absenceHistoryData;
  final List imageslidePaths;
  final VoidCallback onRefreshData;
  const HomeContentSection(
      {required this.onIndexChanged,
      required this.absenceHistoryData,
      required this.absenceData,
      required this.imageslidePaths,
      required this.onRefreshData});

  @override
  State<HomeContentSection> createState() => _HomeContentSectionState();
}

class _HomeContentSectionState extends State<HomeContentSection> {
  // HelperFunction fh = new HelperFunction();
  // Tambahkan variabel berikut untuk kebutuhan slider otomatis
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _sliderTimer;
  final int _totalSlides = 3;

  String strlatitude = "";
  String strlongitude = "";
  Position? _currentPosition;
  String currentAddress = "";
  bool isLocation = false;
  bool isLoading = false;
  var dailyFormat = DateFormat("yyyy-MM-dd");
  DateTime now = DateTime.now();

  String date_now = "";
  // List absencehistory = [];
  String strcheck_in = "Masuk";
  String strcheck_out = "Keluar";
  Color color_in = AppColors.primary;
  Color color_out = AppColors.accent;

  bool outyesterday = false;
  String _date_yesterday = "";
  String _type = "";
  String strTimeZone = "";
  String formattedDate = "";
  List<dynamic> dataabsen = [];
  String shift_id = "";

  @override
  void initState() {
    super.initState();
    // Jalankan timer otomatis saat halaman dibuka
    dataabsen = widget.absenceHistoryData;
    strTimeZone = DateTime.now().timeZoneName;
    _startSliderTimer();
    _getCurrentLocation();
    cekabsenhariini();
    date_now = dailyFormat.format(now);
    formattedDate = DateFormat('EEEE dd MMM yyyy', 'id_ID').format(now);
    shift_id = UserSession.shift_id;
    // _absen_history();
  }

  @override
  void dispose() {
    // Bersihkan timer dan controller agar tidak bocor di memori
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  static String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("H:m:s").format(now);
  }

  void _startSliderTimer() {
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _totalSlides - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  _getCurrentLocation() async {
    setState(() {
      isLoading = true;
    });
    print('_getAddressFromLatLng2');

    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      setState(() {
        isLocation = true;
        _currentPosition = position;
        currentAddress = "";

        _getAddressFromLatLng();
      });
    }).catchError((e) {
      setState(() {
        isLocation = false;
        isLoading = false;
      });
      print(e);
      print('_getAddressFromLatLng');
    });
  }

  _getCurrentLocationAbsence(String modeAbsen) async {
    setState(() {
      isLoading = true;
    });
    print('_getAddressFromLatLng2');

    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      setState(() {
        isLocation = true;
        isLoading = false;
        _currentPosition = position;
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
        _navigateToFaceDetector(context, modeAbsen);
      });
    }).catchError((e) {
      setState(() {
        isLocation = false;
        isLoading = false;
      });
      print(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];

      setState(() {
        isLoading = false;
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
        currentAddress =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print('strlatitude');
        print(strlatitude);
        print('strlongitude');
        print(strlongitude);
      });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';

    // Pecah nama berdasarkan spasi
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    String initials = '';

    // Ambil huruf pertama dari kata pertama
    initials += nameParts[0][0];

    // Jika ada kata kedua, ambil huruf pertama dari kata kedua
    if (nameParts.length > 1) {
      initials += nameParts[1][0];
    }

    // Kembalikan dalam bentuk huruf kapital (maksimal 2 karakter)
    return initials.toUpperCase();
  }

  void cekabsenhariini() {
    print("Menjalankan cekabsenhariini...");
    date_now = dailyFormat.format(now);

    if (widget.absenceHistoryData.isNotEmpty) {
      print("Total data absen: ${widget.absenceHistoryData.length}");

      // Ambil data pertama (terbaru) menggunakan indeks [0] secara langsung
      final item = widget.absenceHistoryData.first;

      String rawDate = item['absence_date'] ?? '';
      String absen_in = item['absence_oin'] ?? '';
      String absen_out = item['absence_oout'] ?? '';

      try {
        DateTime parsedDate = DateTime.parse(rawDate);
        rawDate = DateFormat('yyyy-MM-dd', 'id_ID').format(parsedDate);
      } catch (e) {
        rawDate = rawDate;
      }

      print("Tanggal data terbaru: $rawDate | Hari ini: $date_now");

      // Satukan perubahan state ke dalam satu kali panggilan setState
      setState(() {
        outyesterday = false;
        _type = "";
      });
      if (date_now == rawDate) {
        if (absen_in.isNotEmpty) {
          setState(() {
            strcheck_in = absen_in;
            color_in = Colors.grey;
          });
        }
        if (absen_out.isNotEmpty) {
          setState(() {
            strcheck_out = absen_out;
            color_out = Colors.grey;
          });
        }
      } else {
        // Opsional: Reset teks tombol jika data terbaru bukan hari ini (ganti hari)
        setState(() {
          strcheck_in = "Masuk";
          strcheck_out = "Keluar";
          color_in = AppColors.primary;
          color_out = AppColors.accent;
        });

        if (absen_in != "" && absen_out == "") {
          setState(() {
            strcheck_in = absen_in;
            color_in = Colors.grey;
            outyesterday = true;
            _type = "outyesterday";
            _date_yesterday = rawDate;
            print(
                "Anda Belum Melakukan Absen Keluar Kemarin, Segera Lakukan Absen Keluar Dahulu");
          });

          // _showDialog(
          //     "Anda Belum Melakukan Absen Keluar Kemarin, Segera Lakukan Absen Keluar Dahulu");
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant HomeContentSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika dataabsen berubah setelah refresh, otomatis jalankan pengecekan hari ini
    if (widget.absenceHistoryData != oldWidget.absenceHistoryData) {
      cekabsenhariini();
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        onRefresh: () async {
          widget
              .onRefreshData(); // <--- Panggil fungsi refresh milik parent di sini
        },
        child: Stack(
          children: [
            // 1. BACKGROUND APISAN ATAS: Warna Navy (Header Utama)
            // Container(
            //   height: 110,
            //   decoration: const BoxDecoration(
            //     color: AppColors.primary, // #001668 - Navy
            //   ),
            // ),

            // 2. KONTEN HALAMAN UTAMA (Scrollable)
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 10),
                    isLoading == true
                        ? const LinearProgressIndicator(
                            backgroundColor: Color(0xFFF1F1F1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 4, // Ketebalan garis progress
                          )
                        : Container(),

                    // APP BAR / HEADER PROFIL USER
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 20),
                    //   child: Row(
                    //     children: [
                    //       // Avatar Inisial "DH" dengan warna Orange
                    //       CircleAvatar(
                    //         radius: 26,
                    //         backgroundColor:
                    //             AppColors.accent, // #fd8a02 - Orange
                    //         child: Text(
                    //           _getInitials(UserSession.employee_name),
                    //           style: const TextStyle(
                    //             color: Colors.white,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 18,
                    //           ),
                    //         ),
                    //       ),
                    //       const SizedBox(width: 14),
                    //       // Nama & Informasi Instansi
                    //       Expanded(
                    //         child: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               'Halo, ${UserSession.employee_name}',
                    //               style: const TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 18,
                    //                 fontWeight: FontWeight.bold,
                    //               ),
                    //             ),
                    //             SizedBox(height: 2),
                    //             Text(
                    //               '${UserSession.office_name} · ${UserSession.divisi_name}',
                    //               style: TextStyle(
                    //                 color: Colors.white70,
                    //                 fontSize: 14,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       // Notifikasi Bell Icon
                    //       IconButton(
                    //         icon: const Icon(Icons.notifications,
                    //             color: Colors.white, size: 26),
                    //         onPressed: () {},
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 25),

                    // BANNER PROMO / SLIDER INFORMASI OTOMATIS (3 DETIK)
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: widget.imageslidePaths.length,
                          itemBuilder:
                              (BuildContext context, int index, int realIndex) {
                            return Stack(
                              children: [
                                Image.network(
                                  UserSession.url_api_slide +
                                      widget.imageslidePaths[index]['value'],
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                  // height: 200,
                                  // fit: BoxFit.fitWidth,
                                  // width: double.infinity,
                                ),
                                Positioned(
                                  bottom: 35.0,
                                  child: Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                TimerBuilder.periodic(
                                                    Duration(seconds: 1),
                                                    builder: (context) {
                                                  return Text(
                                                    "${getSystemTime()}" +
                                                        " " +
                                                        strTimeZone,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  );
                                                }),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ]),
                                        ]),
                                    color: Colors
                                        .black54, // Optional: for better text visibility
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
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
                        // SizedBox(
                        //   height: 160,
                        //   width: double.infinity,
                        //   child: CarouselSlider.builder(
                        //     itemCount: widget.imageslidePaths.length,
                        //     itemBuilder: (BuildContext context, int index,
                        //         int realIndex) {
                        //       return Container(
                        //         margin:
                        //             const EdgeInsets.symmetric(horizontal: 24),
                        //         decoration: BoxDecoration(
                        //           gradient: const LinearGradient(
                        //             colors: [
                        //               AppColors.secondary,
                        //               AppColors.secondaryLight,
                        //             ],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //         child: ClipRRect(
                        //           borderRadius: BorderRadius.circular(
                        //               16), // Memotong gambar sesuai bentuk container
                        //           child: Image.network(
                        //             UserSession.url_api_slide +
                        //                 widget.imageslidePaths[index]['value'],
                        //             width: double
                        //                 .infinity, // Membuat gambar memenuhi lebar container
                        //             height: double
                        //                 .infinity, // Membuat gambar memenuhi tinggi container
                        //             fit: BoxFit
                        //                 .cover, // Gambar otomatis terpotong rapi tanpa merusak rasio
                        //             errorBuilder: (context, error, stackTrace) {
                        //               return const Center(
                        //                 child: Icon(Icons.broken_image,
                        //                     color: Colors.white, size: 40),
                        //               );
                        //             },
                        //             loadingBuilder:
                        //                 (context, child, loadingProgress) {
                        //               if (loadingProgress == null) return child;
                        //               return const Center(
                        //                 child: CircularProgressIndicator(
                        //                     color: Colors.white),
                        //               );
                        //             },
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     options: CarouselOptions(
                        //       viewportFraction:
                        //           1.0, // Ensures full width for each item
                        //       // height: MediaQuery.of(context)
                        //       //     .size
                        //       //     .height, // Optional: full height
                        //       autoPlay: true,
                        //       enlargeCenterPage: false,
                        //       padEnds: false,
                        //       initialPage: 0,
                        //     ),
                        //   ),
                        // ),
                        // const SizedBox(height: 12),

                        // SLIDER DOT INDICATOR DINAMIS
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: List.generate(_totalSlides, (index) {
                        //     return AnimatedContainer(
                        //       duration: const Duration(milliseconds: 300),
                        //       margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        //       width: _currentPage == index ? 24.0 : 8.0,
                        //       height: 8.0,
                        //       decoration: BoxDecoration(
                        //         color: _currentPage == index
                        //             ? AppColors.accent
                        //             : Colors.grey.shade300,
                        //         borderRadius: BorderRadius.circular(4),
                        //       ),
                        //     );
                        //   }),
                        // ),
                      ],
                    ),

                    // const SizedBox(height: 25),

// SHIFT NULL
                    UserSession.shift_id == "NULL"
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFE8F0FE), // Background biru sangat muda
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Color(0xFF001668),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Anda Belum Memiliki Jadwal Shift',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    UserSession.shift_id == "NULL"
                        ? SizedBox(height: 12)
                        : Container(),

                    // BELUM OUT KEMARIN
                    outyesterday == true
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                  0xFFE8F0FE), // Background biru sangat muda
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info,
                                  color: Color(0xFF001668),
                                  size: 20,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Anda Belum Melakukan Absen Keluar Kemarin, Segera Lakukan Absen Keluar Dahulu',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    outyesterday == true ? SizedBox(height: 12) : Container(),
                    _buildSectionCard(
                      title: 'Absensi Hari Ini',
                      iconTitle: Icons.access_time_filled,
                      iconColor: AppColors.accent,
                      child: Row(
                        children: [
                          // 1. TOMBOL Masuk (Solid Navy Blue)
                          Expanded(
                            child: Container(
                              height: 95,
                              decoration: BoxDecoration(
                                color: color_in,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Aksi klik tombol Masuk (Misal: buka kamera untuk foto absen)
                                    //debugPrint('Tombol Masuk ditekan');
                                    if (strcheck_in == "Masuk") {
                                      if (isLocation == true) {
                                        // _getCurrentLocationAbsence("Masuk");
                                        if (UserSession.shift_id == "NULL") {
                                          _showDialog(
                                              "Anda belum memiliki jadwal shift");
                                        } else {
                                          _navigateToFaceDetector(
                                              context, "IN");
                                        }
                                      } else {
                                        _showDialog("Lokasi tidak ditemukan");
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(
                                      16), // Efek ripple melengkung rapi
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          color: Colors.white, size: 24),
                                      SizedBox(height: 8),
                                      Text(
                                        strcheck_in,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 2. TOMBOL Keluar (Outline Orange)
                          Expanded(
                            child: Container(
                              height: 95,
                              decoration: BoxDecoration(
                                color: color_out,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Aksi klik tombol Keluar
                                    if (strcheck_in == "Masuk") {
                                      _showDialog("Anda belum Masuk");
                                    } else {
                                      if (strcheck_out == "Keluar") {
                                        if (isLocation == true) {
                                          // _getCurrentLocationAbsence("Keluar");
                                          if (UserSession.shift_id == "NULL") {
                                            _showDialog(
                                                "Anda belum memiliki jadwal shift");
                                          } else {
                                            _showDialogReq(
                                                "Apakah Anda yakin ingin melakukan absen keluar sekarang?",
                                                "OUT");
                                          }
                                          // _navigateToFaceDetector(
                                          //     context, "OUT");
                                        } else {
                                          _showDialog("Lokasi tidak ditemukan");
                                        }
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(
                                      16), // Efek ripple melengkung rapi
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.camera_alt,
                                          color: Colors.white, size: 24),
                                      const SizedBox(height: 8),
                                      Text(
                                        strcheck_out,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // KELOMPOK MENU: PERJALANAN DINAS (List Tile Style - Interaktif)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.03 * 255).round()),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            // Mengalihkan halaman ke tab Perjalanan Dinas mandiri (Index 3)
                            // if (UserSession.employee_type =="EMP"){
                            // widget.onIndexChanged(3);
                            // }
                          },
                          borderRadius: BorderRadius.circular(
                              20), // Mengunci ripple agar tidak luber keluar sudut card
                          child: Padding(
                            padding: const EdgeInsets.all(
                                18), // Padding dipindahkan ke sini agar area klik luas
                            child: Row(
                              children: [
                                // Kotak Icon Berwarna Plum (Secondary)
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.secondary, // #4f0049 - Plum
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.business_center,
                                      color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 16),

                                // Deskripsi Teks
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Perjalanan Dinas',
                                        style: TextStyle(
                                          color: Color(0xFF0F1E4A),
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Ajukan perjalanan dinas baru',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Icon Indikator Panah Kanan
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey.shade400,
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    // ==================== KELOMPOK MENU: MENU CUTI (GRID 2x2) ====================
                    _buildSectionCard(
                      title: 'Pengajuan Tidak Hadir',
                      iconTitle: Icons.calendar_month,
                      iconColor: AppColors.accent,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // Berpindah halaman ke form Cuti Tahunan (Index 6)
                                    if (UserSession.employee_type == "EMP") {
                                      if (UserSession.shift_id == "NULL") {
                                        _showDialog(
                                            "Anda belum memiliki jadwal shift");
                                      } else {
                                        widget.onIndexChanged(6);
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(
                                      16), // Sesuai dengan radius border item menu
                                  child: _buildGridMenuItem(
                                    label: 'Cuti',
                                    iconData: Icons.calendar_today_rounded,
                                    iconBgColor:
                                        UserSession.employee_type == "EMP"
                                            ? AppColors.primary
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // Berpindah halaman ke form Cuti Tahunan (Index 6)
                                    if (UserSession.employee_type == "EMP") {
                                      widget.onIndexChanged(7);
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildGridMenuItem(
                                    label: 'Sakit',
                                    iconData: Icons.add_circle,
                                    iconBgColor:
                                        UserSession.employee_type == "EMP"
                                            ? AppColors.alert
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: InkWell(
                                onTap: () {
                                  // Berpindah halaman ke form Cuti Tahunan (Index 6)
                                  if (UserSession.employee_type == "EMP") {
                                    if (UserSession.shift_id == "NULL") {
                                      _showDialog(
                                          "Anda belum memiliki jadwal shift");
                                    } else {
                                      widget.onIndexChanged(8);
                                    }
                                  }
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: _buildGridMenuItem(
                                  label: 'Izin',
                                  iconData: Icons.assignment_outlined,
                                  iconBgColor:
                                      UserSession.employee_type == "EMP"
                                          ? AppColors.accent
                                          : Colors.grey,
                                ),
                              )),
                              const SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    // Berpindah halaman ke form Cuti Tahunan (Index 6)
                                    if (UserSession.employee_type == "EMP") {
                                      if (UserSession.shift_id == "NULL") {
                                        _showDialog(
                                            "Anda belum memiliki jadwal shift");
                                      } else {
                                        widget.onIndexChanged(9);
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: _buildGridMenuItem(
                                    label: 'Pengganti Hari',
                                    iconData: Icons.timelapse,
                                    iconBgColor:
                                        UserSession.employee_type == "EMP"
                                            ? AppColors.secondary
                                            : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ==================== KELOMPOK MENU: RIWAYAT KEHADIRAN ====================
                    _buildSectionCard(
                      title: 'Riwayat Kehadiran',
                      iconTitle: Icons.history_toggle_off_rounded,
                      iconColor: AppColors.accent,
                      showSeeAll: true,
                      child: Column(
                        children: [
                          // KONDISI 1: JIKA DATA MASIH LOADING / KOSONG
                          if (widget.absenceHistoryData.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 12),
                                    Text(
                                      'tidak ada riwayat kehadiran...',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          // KONDISI 2: JIKA DATA SUDAH BERHASIL DIAMBIL
                          else
                            ...() {
                              // 1. Filter data untuk menghilangkan tanggal yang duplikat
                              final Set<String> seenDates = {};
                              final List<dynamic> uniqueHistory =
                                  widget.absenceHistoryData.where((item) {
                                final String date = item['dateabsen'] ?? '';
                                if (date.isEmpty || seenDates.contains(date)) {
                                  return false; // Skip jika tanggal kosong atau sudah terdaftar
                                }
                                seenDates
                                    .add(date); // Tandai tanggal sudah terbaca
                                return true;
                              }).toList();

                              // 2. Ambil maksimal 2 data unik teratas dan petakan ke widget Row
                              return uniqueHistory.take(2).map((item) {
                                String rawDate = item['absence_date'] ?? '';
                                String formattedDate = '-';
                                String formattedAbsenceDate = '-';

                                print("rawDate2 $rawDate");
                                String absen_in = item['absence_oin'] ?? '';
                                String absen_out = item['absence_oout'] ?? '';

                                if (rawDate.isNotEmpty) {
                                  try {
                                    DateTime parsedDate =
                                        DateTime.parse(rawDate);
                                    formattedDate =
                                        DateFormat('dd MMM yyyy', 'id_ID')
                                            .format(parsedDate);
                                    formattedAbsenceDate =
                                        DateFormat('yyyy-MM-dd', 'id_ID')
                                            .format(parsedDate);
                                  } catch (e) {
                                    formattedDate = rawDate;
                                    formattedAbsenceDate = rawDate;
                                  }
                                }

                                setState(() {
                                  if (date_now == formattedAbsenceDate) {
                                    print("absen_in $absen_in");
                                    print("absen_out $absen_out");
                                    if (absen_in != "") {
                                      strcheck_in = absen_in;
                                      color_in = Colors.grey;
                                    }
                                    if (absen_out != "") {
                                      strcheck_out = absen_out;
                                      color_out = Colors.grey;
                                    }
                                  }
                                });

                                // LOGIKA KODE ABSENSI (H = Hadir, HL = Terlambat)
                                final String absenceCode =
                                    item['absence_code'] ?? '';
                                final bool isTerlambat =
                                    absenceCode.toUpperCase() == 'HL';

                                // Tentukan teks tampilan berdasarkan kode
                                final String statusText =
                                    isTerlambat ? 'Terlambat' : 'Hadir';

                                final Color statusColor = isTerlambat
                                    ? AppColors.accent
                                    : const Color(0xFF2ECC71);
                                final Color statusBgColor = isTerlambat
                                    ? const Color(0xFFFEF5E7)
                                    : const Color(0xFFE8F8F5);

                                // Tampilkan Baris Widget per Item Data
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildAttendanceRow(
                                    dayDate: formattedDate,
                                    statusText: statusText,
                                    statusColor: statusColor,
                                    statusBgColor: statusBgColor,
                                    timeIn:
                                        'Masuk: ${item['absence_oin'] ?? '--.--'}',
                                    timeOut:
                                        'Keluar: ${item['absence_oout'] ?? '--.--'}',
                                  ),
                                );
                              }).toList();
                            }(),

                          const SizedBox(
                              height: 6), // Menyeimbangkan jarak sebelum tombol

                          // TOMBOL OUTLINE: AJUKAN KOREKSI ABSENSI
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // widget.onIndexChanged(10);
                              },
                              icon: const Icon(Icons.edit,
                                  color: Color(0xFF001F82), size: 18),
                              label: const Text(
                                'Ajukan Koreksi Absensi',
                                style: TextStyle(
                                  color: Color(0xFF001F82),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                    color: Color(0xFF001F82), width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  // Reusable Widget untuk membuat item baris menu di dalam popup
  // Update pada helper widget yang sudah ada agar mendukung custom warna teks
  Widget _buildGridMenuItem({
    required String label,
    required IconData iconData,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F1E4A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow({
    required String dayDate,
    required String statusText,
    required Color statusColor,
    required Color statusBgColor,
    required String timeIn,
    required String timeOut,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayDate,
                style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(timeIn,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              Text(timeOut,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }

  // REUSABLE HELPER: Membuat Card Section Induk
  Widget _buildSectionCard({
    required String title,
    required IconData iconTitle,
    required Color iconColor,
    required Widget child,
    bool showSeeAll =
        false, // Tambahkan parameter opsional untuk mengontrol kemunculan tombol
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER CARD: Judul di Kiri & Tombol "Lihat Semua" di Kanan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bagian Kiri: Ikon + Judul Card
              Row(
                children: [
                  Icon(iconTitle, color: iconColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF0F1E4A),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // Bagian Kanan: Tombol "Lihat Semua" (Hanya muncul jika parameter showSeeAll bernilai true)
              if (showSeeAll)
                InkWell(
                  onTap: () {
                    // Navigasi masuk ke halaman Riwayat Absen tanpa Nav Bar
                    widget.onIndexChanged(11);
                    widget.absenceData(widget.absenceHistoryData);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors
                            .accent, // Menggunakan warna #fd8a02 - Orange
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // REUSABLE HELPER: Membuat Item Tombol Menu Grid di Bagian Bawah
  Widget _buildSubMenuIconButton({
    required String label,
    required IconData iconData,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconData, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0F1E4A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk membuat kontainer item promo slide
  Widget _buildPromoSlide({
    required String imageUrl, // Mengganti title & subtitle dengan URL gambar
    required List<Color>
        gradientColors, // Tetap dipertahankan untuk efek overlay/background
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            20), // Memotong gambar sesuai bentuk container
        child: Stack(
          children: [
            // 1. Gambar Utama dari Network
            Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: gradientColors.first.withOpacity(0.5),
                  child: const Center(
                    child:
                        Icon(Icons.broken_image, color: Colors.white, size: 40),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: gradientColors.first.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToFaceDetector(BuildContext context, String modeAbsen) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => FaceDetectorCameraScreen(
              modeAbsen: modeAbsen,
              url_api: UserSession.url_api,
              token: UserSession.token,
              type: _type,
              apikey: UserSession.apikey,
              employee_id: UserSession.employee_id,
              employee_personalid: UserSession.employee_personalid,
              employee_name: UserSession.employee_name,
              latitude: strlatitude,
              longitude: strlongitude,
              date_yesterday: _date_yesterday,
            ));

    // 1. Tambahkan 'await' agar program menunggu sampai halaman kamera di-pop/ditutup
    // ignore: unused_local_variable
    final result = await Navigator.push<void>(context, route);

    // 2. Eksekusi fungsi refresh data milik Parent setelah halaman ditutup
    // Nilai 'result' bisa digunakan untuk mengecek apakah upload sukses (jika Navigator.pop membawa data 'true')
    if (mounted) {
      widget
          .onRefreshData(); // <--- Tambahkan tanda kurung () untuk mengeksekusi fungsi
      print("Berhasil memicu widget.onRefreshData setelah kamera ditutup");
    }
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

  _showDialogReq(String keterangan, String input) async {
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
          Container(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: new Text("CANCEL"),
          )),
          Container(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToFaceDetector(context, input);
            },
            child: new Text("OK"),
          )),
        ],
      ),
    );
  }
}
