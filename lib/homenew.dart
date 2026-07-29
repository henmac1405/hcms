import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'app_colors.dart'; // Memastikan manajemen warna terpusat tetap konsisten
// import 'dart:async';
import 'loginnew.dart';
import 'profile.dart';
import 'changepassword.dart';
import 'riwayatabsen.dart';
// import 'perjalanandinas.dart';
import 'cuti.dart';
import 'sakit.dart';
import 'izin.dart';
import 'penggantihari.dart';
import 'koreksiabsen.dart';
// import 'approval.dart';
import 'user_session.dart';
// import 'facedetector.dart';
import 'homecontent.dart';
import 'package:hcms/database/function_helper.dart';
import 'riwayatdialogfullimage.dart';
import 'showfullimage.dart';
import 'idcard.dart';
import 'pdfexport.dart';
import 'requestabsence.dart';

class HomeNewPage extends StatefulWidget {
  final List imageslidePaths;
  final int noindex;
  final int userlevel;
  const HomeNewPage(
      {super.key,
      required this.imageslidePaths,
      required this.noindex,
      required this.userlevel});

  @override
  State<HomeNewPage> createState() => _HomeNewPageState();
}

// Abaikan ini, gunakan nama state yang benar di bawah

class _HomeNewPageState extends State<HomeNewPage> {
  HelperFunction fh = new HelperFunction();
  int _bottomNavIndex = 0;
  String titleLabel = "";
  String dayDate = "";
  String timeLabel = "";
  String statusLabel = "";
  Color statusColor = Colors.white;
  Color statusBgColor = Colors.white;
  String imageurl = "";
  int noindex = 0;

  String leave_date = "";
  String leave_datestart = "";
  String leave_dateend = "";
  String leave_qty = "";
  String leave_descr = "";
  String leave_nokontak = "";
  String leave_alamatkontak = "";
  String leave_type = "";
  String jatahCuti = "";
  String jumlahCuti = "";
  String sisaCuti = "";

  // late final List<Widget> _pages;
  List<dynamic> absencehistory = [];
  List<dynamic> absenceData = [];
  List<dynamic> datahistoryIzin = [];
  List<dynamic> datahistorySakit = [];
  List<dynamic> datahistoryPH = [];
  List<dynamic> datahistoryCuti = [];
  List<dynamic> datahistoryRequestAbsence = [];

  void _absen_history() {
    fh
        .absen_history(
            UserSession.database_name,
            UserSession.employee_fingerid,
            UserSession.apikey,
            UserSession.token,
            "absen/showabsen",
            UserSession.url_api)
        .then((hasils) async {
      print(hasils);
      if (hasils.length > 0) {
        print("_absen_history");
        setState(() {
          absencehistory = hasils;
          absenceData = hasils;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Jika Anda memanggil via referensi global atau fungsi callback, jalankan di sini
          // Jika fungsi cekabsenhariini ada di dalam HomeContentPage, fungsi ini otomatis terpicu
          // karena widget mendeteksi perubahan data baru pada parameter 'dataabsen'.
        });
      }
    });
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

  @override
  void initState() {
    super.initState();
    _bottomNavIndex = widget.noindex;
    if (widget.noindex == 0) {
      _absen_history();
    }
    print(
        "${UserSession.profile_image_url}?t=${DateTime.now().millisecondsSinceEpoch}"); //
    // _pages = [
    //   _HomeContentSection(
    //     dataabsen: absencehistory,
    //     onIndexChanged: (newIndex) {
    //       setState(() {
    //         _bottomNavIndex = newIndex;
    //       });
    //     },
    //   ),
    //   const Center(child: Text('Approval Page')), // Index 1: Placeholder
    //   const SizedBox(), // Index 2: Kosong (karena memicu popup)
    //   const PerjalananDinasPage(), // Index 3: Placeholder
    //   const ProfilePageContent(), // Index 4: Konten Profil
    //   const ChangePasswordPage(), // Index 5: Konten Profil  // Index 6: Konten Riwayat Absen
    //   const CutiPage(), // Index 6: Konten Cuti
    //   const SakitPage(), // Index 7: Konten Sakit
    //   const IzinPage(), // Index 8: Konten Izin
    //   const PenggantiHariPage(), // Index 9: Konten Izin
    //   const KoreksiAbsenPage(), // Index 10: Konten Koreksi Absen
    //   const RiwayatAbsenPage(), // Index 11: Konten Koreksi Riwayat Absen
    // ];
  }

  @override
  Widget build(BuildContext context) {
    // 1. Definisikan atau update list _pages di dalam fungsi build
    final List<Widget> _pages = [
      HomeContentSection(
        imageslidePaths: widget.imageslidePaths,
        absenceHistoryData:
            absencehistory, // Sekarang otomatis ter-update setiap kali setState dipanggil!
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
          });
        },
        absenceData: (newData) {
          setState(() {
            absenceData = newData;
          });
        },
        onRefreshData: () {
          // <--- OPER FUNGSI REFRESH DI SINI
          _absen_history();
        },
      ),
      const Center(child: Text('Approval')), //const ApprovalPage(), // Index 1
      const SizedBox(), // Index 2
      const Center(
          child: Text('Trips')), //const PerjalananDinasPage(), // Index 3
      ProfilePageContent(
        userlevel: widget.userlevel,
        absenceHistoryData: absenceData,
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 4;
          });
        },
        absenceData: (newData) {
          setState(() {
            absenceData = newData;
          });
        },
        titleLabel: (newString) {
          setState(() {
            titleLabel = newString;
          });
        },
        dayDate: (newString) {
          setState(() {
            dayDate = newString;
          });
        },
        timeLabel: (newString) {
          setState(() {
            timeLabel = newString;
          });
        },
        statusLabel: (newString) {
          setState(() {
            statusLabel = newString;
          });
        },
        statusColor: (newString) {
          setState(() {
            statusColor = newString;
          });
        },
        statusBgColor: (newString) {
          setState(() {
            statusBgColor = newString;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // Index 4
      const ChangePasswordPage(), // Index 5
      CutiPage(onIndexChanged: (newIndex) {
        setState(() {
          _bottomNavIndex = newIndex;
          noindex = 6;
        });
      }, leave_date: (newData) {
        setState(() {
          leave_date = newData;
        });
      }, leave_datestart: (newData) {
        setState(() {
          leave_datestart = newData;
        });
      }, leave_dateend: (newData) {
        setState(() {
          leave_dateend = newData;
        });
      }, leave_qty: (newData) {
        setState(() {
          leave_qty = newData;
        });
      }, leave_descr: (newData) {
        setState(() {
          leave_descr = newData;
        });
      }, leave_nokontak: (newData) {
        setState(() {
          leave_nokontak = newData;
        });
      }, leave_alamatkontak: (newData) {
        setState(() {
          leave_alamatkontak = newData;
        });
      }, leave_type: (newData) {
        setState(() {
          leave_type = newData;
        });
      }, jatahCuti: (newData) {
        setState(() {
          jatahCuti = newData;
        });
      }, sisaCuti: (newData) {
        setState(() {
          sisaCuti = newData;
        });
      }), // Index 6
      SakitPage(
        HistoryData: datahistorySakit,
        DataHistory: (newData) {
          setState(() {
            datahistorySakit = newData;
          });
        },
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 7;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // Index 7
      IzinPage(
        HistoryData: datahistoryIzin,
        DataHistory: (newData) {
          setState(() {
            datahistoryIzin = newData;
          });
        },
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 8;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // Index 8
      PenggantiHariPage(
        HistoryData: datahistoryPH,
        DataHistory: (newData) {
          setState(() {
            datahistoryPH = newData;
          });
        },
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 9;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // Index 9
      const KoreksiAbsenPage(), // Index 10
      RiwayatAbsenPage(
        absenceHistoryData: absenceData,
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 11;
          });
        },
        absenceData: (newData) {
          setState(() {
            absenceData = newData;
          });
        },
        titleLabel: (newString) {
          setState(() {
            titleLabel = newString;
          });
        },
        dayDate: (newString) {
          setState(() {
            dayDate = newString;
          });
        },
        timeLabel: (newString) {
          setState(() {
            timeLabel = newString;
          });
        },
        statusLabel: (newString) {
          setState(() {
            statusLabel = newString;
          });
        },
        statusColor: (newString) {
          setState(() {
            statusColor = newString;
          });
        },
        statusBgColor: (newString) {
          setState(() {
            statusBgColor = newString;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // Index 11: Oper juga data ke halaman riwayat lengkap
      DialogFullImagePage(
        noindex: noindex,
        absenceHistoryData: absenceData,
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
          });
        },
        absenceData: (newData) {
          setState(() {
            absenceData = newData;
          });
        },
        titleLabel: titleLabel,
        dayDate: dayDate,
        timeLabel: timeLabel,
        statusLabel: statusLabel,
        statusColor: statusColor,
        statusBgColor: statusBgColor,
        imageurl: imageurl,
      ), // Index 12 : DialogFullImage
      ShowFullImagePage(
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            // titleLabel = titleLabel;
            // dayDate = dayDate;
            // timeLabel = timeLabel;
            // statusLabel = statusLabel;
            // statusColor = statusColor;
            // statusBgColor = statusBgColor;
            // imageurl = imageurl;
          });
        },
        imageUrl: imageurl,
        noindex: noindex,
      ), // Index 13 : Show Full Image
      IdCardPage(
          namaKaryawan: "",
          jabatanKaryawan: "",
          fotoUrl: ""), // Index 14 : ID CARD
      PdfParamScreen(
          onIndexChanged: (newIndex) {
            setState(() {
              _bottomNavIndex = newIndex;
            });
          },
          leave_date: leave_date,
          leave_datestart: leave_datestart,
          leave_dateend: leave_dateend,
          leave_qty: leave_qty,
          leave_descr: leave_descr,
          leave_nokontak: leave_nokontak,
          leave_alamatkontak: leave_alamatkontak,
          leave_type: leave_type,
          jatahCuti: jatahCuti,
          sisaCuti: sisaCuti), // Index 15 : PDF
      RequestAbsencePage(
        HistoryData: datahistoryRequestAbsence,
        DataHistory: (newData) {
          setState(() {
            datahistoryRequestAbsence = newData;
          });
        },
        onIndexChanged: (newIndex) {
          setState(() {
            _bottomNavIndex = newIndex;
            noindex = 16;
          });
        },
        imageurl: (newString) {
          setState(() {
            imageurl = newString;
          });
        },
      ), // index 16 : Request Absence
    ];

    return PopScope(
      canPop: false, // Menolak perintah back dari tombol fisik HP
      onPopInvoked: (didPop) {
        // 💡 Perubahan ke versi SDK Flutter Anda
        if (didPop) return;

        // Logika opsional saat tombol back ditekan
        debugPrint("Tombol back HP ditekan, tetapi berhasil diblokir!");
      },
      child: Scaffold(
        backgroundColor:
            const Color(0xFFF4F6FA), // Background abu-abu muda bersih
        body: Stack(
          children: [
            // 1. BACKGROUND LAPISAN ATAS: Warna Navy (Header Utama Statis)
            Container(
              height: 110,
              decoration: const BoxDecoration(
                color: AppColors.primary, // #001668
              ),
            ),

            // 2. STRUKTUR KONTEN UTAMA
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // ==================== HEADER PROFIL USER (PINDAHAN) ====================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Avatar Inisial Dinamis dari UserSession
                        GestureDetector(
                          onTap: () {
                            // 💡 JIKA URL TIDAK KOSONG, TAMPILKAN POP-UP PREVIEW GAMBAR FULLSCREEN
                            if (UserSession.profile_image_url.isNotEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => Dialog(
                                  backgroundColor: Colors
                                      .transparent, // Membuat latar belakang modal tembus pandang
                                  insetPadding: const EdgeInsets.all(
                                      20), // Jarak modal dari tepi layar HP
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Tombol Close di Atas Kanan Gambar
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.white, size: 30),
                                          onPressed: () =>
                                              Navigator.pop(context),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // Wadah Gambar Ukuran Besar
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(16),
                                        child: Image.network(
                                          "${UserSession.profile_image_url}?t=${DateTime.now().millisecondsSinceEpoch}",
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.85, // Lebar gambar 85% layar
                                          fit: BoxFit.contain,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                color: Colors.white,
                                                child: SizedBox(
                                                  height: 100.0,
                                                  child: Image.asset(
                                                      UserSession.employee_gender
                                                                      .toLowerCase() ==
                                                                  "male" ||
                                                              UserSession
                                                                      .employee_gender ==
                                                                  "L"
                                                          ? "assets/male.png"
                                                          : "assets/female.png",
                                                      fit: BoxFit.fill),
                                                ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          child: CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                AppColors.accent, // #fd8a02 - Orange
                            child: UserSession.profile_image_url.isEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: SizedBox(
                                      height: 100.0,
                                      child: Image.asset(
                                          UserSession.employee_gender
                                                          .toLowerCase() ==
                                                      "male" ||
                                                  UserSession.employee_gender ==
                                                      "L"
                                              ? "assets/male.png"
                                              : "assets/male.png",
                                          fit: BoxFit.fill),
                                    ))
                                // Text(
                                //     _getInitials(UserSession.employee_name),
                                //     style: const TextStyle(
                                //       color: Colors.white,
                                //       fontWeight: FontWeight.bold,
                                //       fontSize: 18,
                                //     ),
                                //   )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(26),
                                    child: Image.network(
                                      "${UserSession.profile_image_url}",
                                      width:
                                          52, // Setara dengan diameter (radius 26 * 2)
                                      height: 52,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                            child: SizedBox(
                                          height: 100.0,
                                          child: Image.asset(
                                              UserSession.employee_gender
                                                              .toLowerCase() ==
                                                          "male" ||
                                                      UserSession
                                                              .employee_gender ==
                                                          "L"
                                                  ? "assets/male.png"
                                                  : "assets/female.png",
                                              fit: BoxFit.fill),

                                          // Text(
                                          //   _getInitials(
                                          //       UserSession.employee_name),
                                          //   style: const TextStyle(
                                          //     color: Colors.white,
                                          //     fontWeight: FontWeight.bold,
                                          //     fontSize: 18,
                                          //   ),
                                          // ),
                                        ));
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return const Center(
                                          child: SizedBox(
                                            width: 15,
                                            height: 15,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(width: 14),
                        // Nama & Informasi Instansi Dinamis
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Mengubah tab aktif navigasi bawah langsung ke indeks 4 (Halaman Profile)
                              setState(() {
                                _bottomNavIndex = 4;
                              });
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Halo, ${UserSession.employee_name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${UserSession.office_name} · ${UserSession.divisi_name}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Notifikasi Bell Icon
                        IconButton(
                          icon: const Icon(Icons.notifications,
                              color: Colors.white, size: 26),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ==================== AREA KONTEN TAB DINAMIS ====================
                  Expanded(
                    child: _pages[_bottomNavIndex],
                  ),
                ],
              ),
            ),
          ],
        ),

        // BOTTOM NAVIGATION BAR UTAMA (Sesuai Gambar)
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.05 * 255).round()),
                blurRadius: 15,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: (_bottomNavIndex == 5 || _bottomNavIndex == 14)
                ? 4 // Jika halaman Change Password (5) aktif, sorot tab Profile (4)
                : ([6, 7, 8, 9, 10, 15].contains(_bottomNavIndex)
                    ? 2 // Jika sub-halaman cuti/sakit aktif, sorot tab Leave (2)
                    : ([11, 12, 13].contains(_bottomNavIndex)
                        ? 0 // 🔑 SOLUSI: Jika index 11 atau 12 aktif, sorot tab Home (0)
                        : _bottomNavIndex)),
            onTap: (index) {
              if (UserSession.userlevel != 1) {
                if (index == 2) {
                  _showLeaveMenuPopup(context);
                } else if (index == 4) {
                  // Jika menu Profile (indeks 4) diklik, tampilkan Profile Pop-up Menu
                  _showProfileMenuPopup(context);
                } else {
                  setState(() {
                    _bottomNavIndex = index;
                  });
                }
              }
              if (UserSession.userlevel == 1) {
                if (index == 4) {
                  // Jika menu Profile (indeks 4) diklik, tampilkan Profile Pop-up Menu
                  _showProfileMenuPopupAdmin(context);
                }
              }
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 30), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle, size: 30), label: 'Approval'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today_outlined, size: 30),
                  label: 'Leave'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.business_center_outlined, size: 30),
                  label: 'Trips'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline, size: 30), label: 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk memunculkan Bottom Sheet Menu Leave yang melayang
  void _showLeaveMenuPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Membuat background bawaan transparan agar bisa custom shape
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(
              left: 32,
              right: 32,
              bottom: 20), // Memberikan jarak agar melayang
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.15 * 255).round()),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize
                .min, // Membuat tinggi modal menyesuaikan jumlah item menu
            children: [
              // 4. Day Replacement (Plum Secondary)
              _buildPopupMenuItem(
                label: 'Pengganti Hari',
                iconData: Icons.timelapse,
                iconColor: UserSession.employee_type == "EMP"
                    ? AppColors.secondary
                    : Colors.grey,
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi navigasi ke form Day Replacement di sini
                  if (UserSession.employee_type == "EMP") {
                    setState(() {
                      _bottomNavIndex = 9;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 3. Permission Leave (Orange Accent)
              _buildPopupMenuItem(
                label: 'Izin',
                iconData: Icons.assignment_outlined,
                iconColor: UserSession.employee_type == "EMP"
                    ? AppColors.accent
                    : Colors.grey,
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi navigasi ke form Permission Leave di sini
                  if (UserSession.employee_type == "EMP") {
                    setState(() {
                      _bottomNavIndex = 8;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
// 2. Sick Leave (Red Alert)
              _buildPopupMenuItem(
                label: 'Sakit',
                iconData: Icons.add_circle,
                iconColor: UserSession.employee_type == "EMP"
                    ? AppColors.alert
                    : Colors.grey,
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi navigasi ke form Sick Leave di sini
                  if (UserSession.employee_type == "EMP") {
                    setState(() {
                      _bottomNavIndex = 7;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 1. Leave Request (Navy Blue)
              _buildPopupMenuItem(
                label: 'Cuti',
                iconData: Icons.calendar_month,
                iconColor: UserSession.employee_type == "EMP"
                    ? AppColors.primary
                    : Colors.grey,
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi navigasi ke form Leave Request di sini
                  if (UserSession.employee_type == "EMP") {
                    setState(() {
                      _bottomNavIndex = 6;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              // 1. Leave Request (Navy Blue)
              _buildPopupMenuItem(
                label: 'Pengajuan Absensi',
                iconData: Icons.calendar_month,
                iconColor: Colors.green,
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi navigasi ke form Leave Request di sini

                  setState(() {
                    _bottomNavIndex = 6;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Fungsi untuk memunculkan Bottom Sheet Menu Profile yang melayang di sebelah kanan
  void _showProfileMenuPopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Transparan agar rounded corner & margin terlihat
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          // Margin disesuaikan agar pop-up condong melayang di area kanan layar sesuai ikon profile
          margin: const EdgeInsets.only(left: 60, right: 24, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.15 * 255).round()),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tinggi dinamis sesuai jumlah menu
            children: [
              // 1. My Account (Navy Blue)
              _buildPopupMenuItem(
                label: 'ID Card',
                iconData: Icons.assignment_ind,
                iconColor: const Color(0xFF002283), // Navy Blue sesuai gambar
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi ke halaman detail akun di sini
                  setState(() {
                    _bottomNavIndex = 14; // 3. ID CARD
                  });
                },
              ),
              const SizedBox(height: 16),
              // 1. My Account (Navy Blue)
              _buildPopupMenuItem(
                label: 'Akun Saya',
                iconData: Icons.person,
                iconColor: const Color(0xFF002283), // Navy Blue sesuai gambar
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi ke halaman detail akun di sini
                  setState(() {
                    _bottomNavIndex =
                        4; // 3. LANGSUNG PINDAHKAN INDEX NYALA KE PROFILE (INDEX 4)
                  });
                },
              ),
              const SizedBox(height: 16),

              // 2. Change Password (Navy Blue)
              _buildPopupMenuItem(
                label: 'Ganti Password',
                iconData: Icons.lock,
                iconColor: const Color(0xFF002283), // Navy Blue sesuai gambar
                textColor: const Color(0xFF0F1E4A),
                onTap: () {
                  Navigator.pop(context);
                  // Tambahkan aksi ke halaman ganti password di sini
                  setState(() {
                    _bottomNavIndex =
                        5; // 3. LANGSUNG PINDAHKAN INDEX NYALA KE CHANGE PASSWORD (INDEX 5)
                  });
                },
              ),
              const SizedBox(height: 16),

              // Divider halus pemisah menu logout
              Divider(color: Colors.grey.shade100, height: 1),
              const SizedBox(height: 16),

              // 3. Logout (Red Alert)
              _buildPopupMenuItem(
                label: 'Logout',
                iconData: Icons.logout,
                iconColor: AppColors.alert, // #ff0000 - Red
                textColor:
                    AppColors.alert, // Teks logout berwarna merah sesuai gambar
                onTap: () {
                  Navigator.pop(context);
                  // Aksi kembali ke halaman login (LoginNewPage)
                  //Navigator.pushReplacementNamed(context, '/login');
                  // Catatan: Jika belum setup rute, bisa gunakan Navigator.pushReplacement dengan MaterialPageRoute

                  Route route = MaterialPageRoute<void>(
                      builder: (context) => LoginNewPage(
                          url_api_part1: UserSession.url_api_part1,
                          url_api_part2: UserSession.url_api_part2,
                          url_api_dev_part1: UserSession.url_api_dev_part1,
                          url_api_image_part1: UserSession.url_api_image_part1,
                          url_api_image_part2: UserSession.url_api_image_part2,
                          url_api_image_dev_part1:
                              UserSession.url_api_image_dev_part1,
                          url_image_profile_part1:
                              UserSession.url_image_profile_part1,
                          url_image_profile_part2:
                              UserSession.url_image_profile_part2,
                          url_image_profile_dev_part1:
                              UserSession.url_image_profile_dev_part1,
                          url_api_slide: UserSession.url_api_slide,
                          url_api_lokal: UserSession.url_api_lokal,
                          debug: UserSession.debug
                          // camera: firstCamera,
                          ));
                  Navigator.push<void>(context, route);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileMenuPopupAdmin(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Transparan agar rounded corner & margin terlihat
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          // Margin disesuaikan agar pop-up condong melayang di area kanan layar sesuai ikon profile
          margin: const EdgeInsets.only(left: 60, right: 24, bottom: 20),
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.15 * 255).round()),
                blurRadius: 25,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Tinggi dinamis sesuai jumlah menu
            children: [
              // 3. Logout (Red Alert)
              _buildPopupMenuItem(
                label: 'Logout',
                iconData: Icons.logout,
                iconColor: AppColors.alert, // #ff0000 - Red
                textColor:
                    AppColors.alert, // Teks logout berwarna merah sesuai gambar
                onTap: () {
                  Navigator.pop(context);
                  // Aksi kembali ke halaman login (LoginNewPage)
                  //Navigator.pushReplacementNamed(context, '/login');
                  // Catatan: Jika belum setup rute, bisa gunakan Navigator.pushReplacement dengan MaterialPageRoute

                  Route route = MaterialPageRoute<void>(
                      builder: (context) => LoginNewPage(
                          url_api_part1: UserSession.url_api_part1,
                          url_api_part2: UserSession.url_api_part2,
                          url_api_dev_part1: UserSession.url_api_dev_part1,
                          url_api_image_part1: UserSession.url_api_image_part1,
                          url_api_image_part2: UserSession.url_api_image_part2,
                          url_api_image_dev_part1:
                              UserSession.url_api_image_dev_part1,
                          url_image_profile_part1:
                              UserSession.url_image_profile_part1,
                          url_image_profile_part2:
                              UserSession.url_image_profile_part2,
                          url_image_profile_dev_part1:
                              UserSession.url_image_profile_dev_part1,
                          url_api_slide: UserSession.url_api_slide,
                          url_api_lokal: UserSession.url_api_lokal,
                          debug: UserSession.debug
                          // camera: firstCamera,
                          ));
                  Navigator.push<void>(context, route);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPopupMenuItem({
    required String label,
    required IconData iconData,
    required Color iconColor,
    required Color textColor, // Tambahkan parameter ini
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 20),
            Text(
              label,
              style: TextStyle(
                color: textColor, // Menggunakan warna teks dinamis
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ BINDING KONTEN HALAMAN UTAMA HOME SEBELUMNYA KE WIDGET BARU =================

// class _HomeContentSection extends StatefulWidget {
//   final ValueChanged<int> onIndexChanged;
//   final List dataabsen;
//   const _HomeContentSection(
//       {required this.onIndexChanged, required this.dataabsen});

//   @override
//   State<_HomeContentSection> createState() => _HomeContentSectionState();
// }

// class _HomeContentSectionState extends State<_HomeContentSection> {
//   // HelperFunction fh = new HelperFunction();
//   // Tambahkan variabel berikut untuk kebutuhan slider otomatis
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   Timer? _sliderTimer;
//   final int _totalSlides = 3;

//   String strlatitude = "";
//   String strlongitude = "";

//   // List absencehistory = [];

//   @override
//   void initState() {
//     super.initState();
//     // Jalankan timer otomatis saat halaman dibuka
//     _startSliderTimer();
//     // _absen_history();
//   }

//   @override
//   void dispose() {
//     // Bersihkan timer dan controller agar tidak bocor di memori
//     _sliderTimer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _startSliderTimer() {
//     _sliderTimer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
//       if (_pageController.hasClients) {
//         if (_currentPage < _totalSlides - 1) {
//           _currentPage++;
//         } else {
//           _currentPage = 0;
//         }
//         _pageController.animateToPage(
//           _currentPage,
//           duration: const Duration(milliseconds: 350),
//           curve: Curves.easeIn,
//         );
//       }
//     });
//   }

//   String _getInitials(String name) {
//     if (name.trim().isEmpty) return '';

//     // Pecah nama berdasarkan spasi
//     List<String> nameParts = name.trim().split(RegExp(r'\s+'));
//     String initials = '';

//     // Ambil huruf pertama dari kata pertama
//     initials += nameParts[0][0];

//     // Jika ada kata kedua, ambil huruf pertama dari kata kedua
//     if (nameParts.length > 1) {
//       initials += nameParts[1][0];
//     }

//     // Kembalikan dalam bentuk huruf kapital (maksimal 2 karakter)
//     return initials.toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         // 1. BACKGROUND APISAN ATAS: Warna Navy (Header Utama)
//         Container(
//           height: 110,
//           decoration: const BoxDecoration(
//             color: AppColors.primary, // #001668 - Navy
//           ),
//         ),

//         // 2. KONTEN HALAMAN UTAMA (Scrollable)
//         SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.only(bottom: 30),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 10),

//                 // APP BAR / HEADER PROFIL USER
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: Row(
//                     children: [
//                       // Avatar Inisial "DH" dengan warna Orange
//                       CircleAvatar(
//                         radius: 26,
//                         backgroundColor: AppColors.accent, // #fd8a02 - Orange
//                         child: Text(
//                           _getInitials(UserSession.employee_name),
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 14),
//                       // Nama & Informasi Instansi
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Halo, ${UserSession.employee_name}',
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 2),
//                             Text(
//                               '${UserSession.office_name} · ${UserSession.divisi_name}',
//                               style: TextStyle(
//                                 color: Colors.white70,
//                                 fontSize: 14,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Notifikasi Bell Icon
//                       IconButton(
//                         icon: const Icon(Icons.notifications,
//                             color: Colors.white, size: 26),
//                         onPressed: () {},
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 25),

//                 // BANNER PROMO / SLIDER INFORMASI OTOMATIS (3 DETIK)
//                 Column(
//                   children: [
//                     SizedBox(
//                       height: 160,
//                       child: PageView(
//                         controller: _pageController,
//                         onPageChanged: (int page) {
//                           setState(() {
//                             _currentPage = page;
//                           });
//                         },
//                         children: [
//                           // SLIDE 1 (Sesuai Gambar Anda)
//                           _buildPromoSlide(
//                             imageUrl:
//                                 'https://ssodev.transentertainment.com/assets/upload/slides/banner1.jpg',
//                             gradientColors: [
//                               const Color(0xFF0F3BB1),
//                               const Color(0xFF255BE3)
//                             ],
//                           ),
//                           // SLIDE 2
//                           _buildPromoSlide(
//                             imageUrl:
//                                 'https://ssodev.transentertainment.com/assets/upload/slides/banner2.jpg',
//                             gradientColors: [
//                               const Color(0xFF1E3C72),
//                               const Color(0xFF2A5298)
//                             ],
//                           ),
//                           // SLIDE 3
//                           _buildPromoSlide(
//                             imageUrl:
//                                 'https://ssodev.transentertainment.com/assets/upload/slides/banner3.jpg',
//                             gradientColors: [
//                               const Color(0xFF11998E),
//                               const Color(0xFF38EF7D)
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 12),

//                     // SLIDER DOT INDICATOR DINAMIS
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(_totalSlides, (index) {
//                         return AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(horizontal: 2.5),
//                           width: _currentPage == index ? 24.0 : 8.0,
//                           height: 8.0,
//                           decoration: BoxDecoration(
//                             color: _currentPage == index
//                                 ? AppColors.accent
//                                 : Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                         );
//                       }),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),

//                 // KELOMPOK MENU: ABSENSI HARI INI
//                 _buildSectionCard(
//                   title: 'Absensi Hari Ini',
//                   iconTitle: Icons.access_time_filled,
//                   iconColor: AppColors.accent,
//                   child: Row(
//                     children: [
//                       // 1. TOMBOL CHECK-IN (Solid Navy Blue)
//                       Expanded(
//                         child: Container(
//                           height: 95,
//                           decoration: BoxDecoration(
//                             color: const Color(0xFF001F82),
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () {
//                                 // Aksi klik tombol Check-In (Misal: buka kamera untuk foto absen)
//                                 //debugPrint('Tombol Check-In ditekan');
//                                 _navigateToFaceDetector(context, "Masuk");
//                               },
//                               borderRadius: BorderRadius.circular(
//                                   16), // Efek ripple melengkung rapi
//                               child: const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.camera_alt,
//                                       color: Colors.white, size: 24),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Check-In',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 16),

//                       // 2. TOMBOL CHECK-OUT (Outline Orange)
//                       Expanded(
//                         child: Container(
//                           height: 95,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(16),
//                             border:
//                                 Border.all(color: AppColors.accent, width: 2),
//                           ),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () {
//                                 // Aksi klik tombol Check-Out
//                                 _navigateToFaceDetector(context, "Keluar");
//                               },
//                               borderRadius: BorderRadius.circular(
//                                   16), // Efek ripple melengkung rapi
//                               child: const Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(Icons.camera_alt,
//                                       color: AppColors.accent, size: 24),
//                                   SizedBox(height: 8),
//                                   Text(
//                                     'Check-Out',
//                                     style: TextStyle(
//                                       color: AppColors.accent,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 15,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // KELOMPOK MENU: PERJALANAN DINAS (List Tile Style - Interaktif)
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withAlpha((0.03 * 255).round()),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       )
//                     ],
//                   ),
//                   child: Material(
//                     color: Colors.transparent,
//                     child: InkWell(
//                       onTap: () {
//                         // Mengalihkan halaman ke tab Perjalanan Dinas mandiri (Index 3)
//                         widget.onIndexChanged(3);
//                       },
//                       borderRadius: BorderRadius.circular(
//                           20), // Mengunci ripple agar tidak luber keluar sudut card
//                       child: Padding(
//                         padding: const EdgeInsets.all(
//                             18), // Padding dipindahkan ke sini agar area klik luas
//                         child: Row(
//                           children: [
//                             // Kotak Icon Berwarna Plum (Secondary)
//                             Container(
//                               width: 48,
//                               height: 48,
//                               decoration: BoxDecoration(
//                                 color: AppColors.secondary, // #4f0049 - Plum
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                               child: const Icon(Icons.business_center,
//                                   color: Colors.white, size: 24),
//                             ),
//                             const SizedBox(width: 16),

//                             // Deskripsi Teks
//                             const Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Perjalanan Dinas',
//                                     style: TextStyle(
//                                       color: Color(0xFF0F1E4A),
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   SizedBox(height: 4),
//                                   Text(
//                                     'Ajukan business trip baru',
//                                     style: TextStyle(
//                                       color: Colors.grey,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),

//                             // Icon Indikator Panah Kanan
//                             Icon(
//                               Icons.chevron_right,
//                               color: Colors.grey.shade400,
//                               size: 24,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),
//                 // ==================== KELOMPOK MENU: MENU CUTI (GRID 2x2) ====================
//                 _buildSectionCard(
//                   title: 'Menu Cuti',
//                   iconTitle: Icons.calendar_month,
//                   iconColor: AppColors.accent,
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Expanded(
//                             child: InkWell(
//                               onTap: () {
//                                 // Berpindah halaman ke form Cuti Tahunan (Index 6)
//                                 widget.onIndexChanged(6);
//                               },
//                               borderRadius: BorderRadius.circular(
//                                   16), // Sesuai dengan radius border item menu
//                               child: _buildGridMenuItem(
//                                 label: 'Cuti Tahunan',
//                                 iconData: Icons.calendar_today_rounded,
//                                 iconBgColor:
//                                     const Color(0xFF001F82), // Navy Blue
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: InkWell(
//                               onTap: () {
//                                 // Berpindah halaman ke form Cuti Tahunan (Index 6)
//                                 widget.onIndexChanged(7);
//                               },
//                               borderRadius: BorderRadius.circular(16),
//                               child: _buildGridMenuItem(
//                                 label: 'Cuti Sakit',
//                                 iconData: Icons.add_circle,
//                                 iconBgColor: AppColors.alert, // Red Alert
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Row(
//                         children: [
//                           Expanded(
//                               child: InkWell(
//                             onTap: () {
//                               // Berpindah halaman ke form Cuti Tahunan (Index 6)
//                               widget.onIndexChanged(8);
//                             },
//                             borderRadius: BorderRadius.circular(16),
//                             child: _buildGridMenuItem(
//                               label: 'Izin',
//                               iconData: Icons.assignment_outlined,
//                               iconBgColor: AppColors.accent, // Orange Accent
//                             ),
//                           )),
//                           const SizedBox(width: 16),
//                           Expanded(
//                             child: InkWell(
//                               onTap: () {
//                                 // Berpindah halaman ke form Cuti Tahunan (Index 6)
//                                 widget.onIndexChanged(9);
//                               },
//                               borderRadius: BorderRadius.circular(16),
//                               child: _buildGridMenuItem(
//                                 label: 'Ganti Hari',
//                                 iconData: Icons.timelapse,
//                                 iconBgColor:
//                                     AppColors.secondary, // Plum Secondary
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // ==================== KELOMPOK MENU: RIWAYAT KEHADIRAN ====================
//                 _buildSectionCard(
//                   title: 'Riwayat Kehadiran',
//                   iconTitle: Icons.history_toggle_off_rounded,
//                   iconColor: AppColors.accent,
//                   showSeeAll: true,
//                   child: Column(
//                     children: [
//                       // KONDISI 1: JIKA DATA MASIH LOADING / KOSONG
//                       if (widget.dataabsen.isEmpty)
//                         const Padding(
//                           padding: EdgeInsets.symmetric(vertical: 20),
//                           child: Center(
//                             child: Column(
//                               children: [
//                                 SizedBox(
//                                   width: 24,
//                                   height: 24,
//                                   child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         AppColors.accent),
//                                     strokeWidth: 2.5,
//                                   ),
//                                 ),
//                                 SizedBox(height: 12),
//                                 Text(
//                                   'Memuat riwayat kehadiran...',
//                                   style: TextStyle(
//                                       color: Colors.grey, fontSize: 14),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       // KONDISI 2: JIKA DATA SUDAH BERHASIL DIAMBIL
//                       else
//                         ...() {
//                           // 1. Filter data untuk menghilangkan tanggal yang duplikat
//                           final Set<String> seenDates = {};
//                           final List<dynamic> uniqueHistory =
//                               widget.dataabsen.where((item) {
//                             final String date = item['absence_date'] ?? '';
//                             if (date.isEmpty || seenDates.contains(date)) {
//                               return false; // Skip jika tanggal kosong atau sudah terdaftar
//                             }
//                             seenDates.add(date); // Tandai tanggal sudah terbaca
//                             return true;
//                           }).toList();

//                           // 2. Ambil maksimal 2 data unik teratas dan petakan ke widget Row
//                           return uniqueHistory.take(2).map((item) {
//                             String rawDate = item['absence_date'] ?? '';
//                             String formattedDate = '-';

//                             if (rawDate.isNotEmpty) {
//                               try {
//                                 DateTime parsedDate = DateTime.parse(rawDate);
//                                 formattedDate =
//                                     DateFormat('dd MMM yyyy', 'id_ID')
//                                         .format(parsedDate);
//                               } catch (e) {
//                                 formattedDate = rawDate;
//                               }
//                             }

//                             // LOGIKA KODE ABSENSI (H = Hadir, HL = Terlambat)
//                             final String absenceCode =
//                                 item['absence_code'] ?? '';
//                             final bool isTerlambat =
//                                 absenceCode.toUpperCase() == 'HL';

//                             // Tentukan teks tampilan berdasarkan kode
//                             final String statusText =
//                                 isTerlambat ? 'Terlambat' : 'Hadir';

//                             final Color statusColor = isTerlambat
//                                 ? AppColors.accent
//                                 : const Color(0xFF2ECC71);
//                             final Color statusBgColor = isTerlambat
//                                 ? const Color(0xFFFEF5E7)
//                                 : const Color(0xFFE8F8F5);

//                             // Tampilkan Baris Widget per Item Data
//                             return Padding(
//                               padding: const EdgeInsets.only(bottom: 14),
//                               child: _buildAttendanceRow(
//                                 dayDate: formattedDate,
//                                 statusText: statusText,
//                                 statusColor: statusColor,
//                                 statusBgColor: statusBgColor,
//                                 timeIn:
//                                     'Masuk: ${item['absence_oin'] ?? '--.--'}',
//                                 timeOut:
//                                     'Pulang: ${item['absence_oout'] ?? '--.--'}',
//                               ),
//                             );
//                           }).toList();
//                         }(),

//                       const SizedBox(
//                           height: 6), // Menyeimbangkan jarak sebelum tombol

//                       // TOMBOL OUTLINE: AJUKAN KOREKSI ABSENSI
//                       SizedBox(
//                         width: double.infinity,
//                         height: 52,
//                         child: OutlinedButton.icon(
//                           onPressed: () {
//                             widget.onIndexChanged(10);
//                           },
//                           icon: const Icon(Icons.edit,
//                               color: Color(0xFF001F82), size: 18),
//                           label: const Text(
//                             'Ajukan Koreksi Absensi',
//                             style: TextStyle(
//                               color: Color(0xFF001F82),
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             side: const BorderSide(
//                                 color: Color(0xFF001F82), width: 2),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // Reusable Widget untuk membuat item baris menu di dalam popup
//   // Update pada helper widget yang sudah ada agar mendukung custom warna teks
//   Widget _buildGridMenuItem({
//     required String label,
//     required IconData iconData,
//     required Color iconBgColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100, width: 1.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: iconBgColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(iconData, color: Colors.white, size: 22),
//           ),
//           const SizedBox(height: 14),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF0F1E4A),
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAttendanceRow({
//     required String dayDate,
//     required String statusText,
//     required Color statusColor,
//     required Color statusBgColor,
//     required String timeIn,
//     required String timeOut,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100, width: 1.5),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 dayDate,
//                 style: const TextStyle(
//                   color: Color(0xFF0F1E4A),
//                   fontSize: 15,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: statusBgColor,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   statusText,
//                   style: TextStyle(
//                     color: statusColor,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 12,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(timeIn,
//                   style: const TextStyle(color: Colors.grey, fontSize: 14)),
//               Text(timeOut,
//                   style: const TextStyle(color: Colors.grey, fontSize: 14)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // REUSABLE HELPER: Membuat Card Section Induk
//   Widget _buildSectionCard({
//     required String title,
//     required IconData iconTitle,
//     required Color iconColor,
//     required Widget child,
//     bool showSeeAll =
//         false, // Tambahkan parameter opsional untuk mengontrol kemunculan tombol
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha((0.03 * 255).round()),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           )
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // HEADER CARD: Judul di Kiri & Tombol "Lihat Semua" di Kanan
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Bagian Kiri: Ikon + Judul Card
//               Row(
//                 children: [
//                   Icon(iconTitle, color: iconColor, size: 20),
//                   const SizedBox(width: 8),
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       color: Color(0xFF0F1E4A),
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               // Bagian Kanan: Tombol "Lihat Semua" (Hanya muncul jika parameter showSeeAll bernilai true)
//               if (showSeeAll)
//                 InkWell(
//                   onTap: () {
//                     // Navigasi masuk ke halaman Riwayat Absen tanpa Nav Bar
//                     widget.onIndexChanged(11);
//                   },
//                   borderRadius: BorderRadius.circular(8),
//                   child: const Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                     child: Text(
//                       'Lihat Semua',
//                       style: TextStyle(
//                         color: AppColors
//                             .accent, // Menggunakan warna #fd8a02 - Orange
//                         fontSize: 13,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           child,
//         ],
//       ),
//     );
//   }

//   // REUSABLE HELPER: Membuat Item Tombol Menu Grid di Bagian Bawah
//   Widget _buildSubMenuIconButton({
//     required String label,
//     required IconData iconData,
//     required Color iconBgColor,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade100, width: 1.5),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Container(
//             width: 44,
//             height: 44,
//             decoration: BoxDecoration(
//               color: iconBgColor,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(iconData, color: Colors.white, size: 22),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             label,
//             style: const TextStyle(
//               color: Color(0xFF0F1E4A),
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Helper Widget untuk membuat kontainer item promo slide
//   Widget _buildPromoSlide({
//     required String imageUrl, // Mengganti title & subtitle dengan URL gambar
//     required List<Color>
//         gradientColors, // Tetap dipertahankan untuk efek overlay/background
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(
//             20), // Memotong gambar sesuai bentuk container
//         child: Stack(
//           children: [
//             // 1. Gambar Utama dari Network
//             Image.network(
//               imageUrl,
//               width: double.infinity,
//               height: double.infinity,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: gradientColors.first.withOpacity(0.5),
//                   child: const Center(
//                     child:
//                         Icon(Icons.broken_image, color: Colors.white, size: 40),
//                   ),
//                 );
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: gradientColors.first.withOpacity(0.1),
//                   child: const Center(
//                     child: CircularProgressIndicator(color: Colors.white),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _navigateToFaceDetector(BuildContext context, String modeAbsen) async {
//     Route route = MaterialPageRoute<void>(
//         builder: (context) => FaceDetectorCameraScreen(
//               modeAbsen: modeAbsen,
//               url_api: UserSession.url_api,
//               token: UserSession.token,
//               type: "",
//               apikey: UserSession.apikey,
//               employee_id: UserSession.employee_id,
//               employee_personalid: UserSession.employee_personalid,
//               employee_name: UserSession.employee_name,
//               latitude: strlatitude,
//               longitude: strlongitude,
//               // camera: firstCamera,
//             ));
//     Navigator.push<void>(context, route);
//   }
// }
