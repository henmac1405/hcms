import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'user_session.dart';
import 'uploadphoto.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePageContent extends StatefulWidget {
  final int userlevel;
  final List<dynamic> absenceHistoryData;
  final ValueChanged<List<dynamic>> absenceData;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<String> titleLabel;
  final ValueChanged<String> dayDate;
  final ValueChanged<String> timeLabel;
  final ValueChanged<String> statusLabel;
  final ValueChanged<Color> statusColor;
  final ValueChanged<Color> statusBgColor;
  final ValueChanged<String> imageurl;
  const ProfilePageContent({
    super.key,
    required this.userlevel,
    required this.absenceHistoryData,
    required this.absenceData,
    required this.onIndexChanged,
    required this.titleLabel,
    required this.dayDate,
    required this.timeLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.statusBgColor,
    required this.imageurl,
  });

  @override
  State<ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<ProfilePageContent> {
  HelperFunction fh = new HelperFunction();
  // Variabel untuk menyimpan file gambar yang dipilih
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String employeeName = "";
  bool isLoading = false;
  String strakun = "AKUN SAYA";
  final _nikController = TextEditingController(text: '');
  // Fungsi internal untuk memproses pengambilan gambar
  String database_name = "";
  var newFormat = DateFormat("dd MMM yyyy");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  String strbuttonupdate = "Perbarui Foto Profil";
  DateTime now = DateTime.now();
  List<dynamic> dataabsen = [];
  String _tglFilter = "";
  final _tglFilterController =
      TextEditingController(text: _getFormattedTodayStatic());

  @override
  void initState() {
    super.initState();
    if (widget.userlevel == 1) {
      strakun = "AKUN ADMIN";
      strbuttonupdate = "Reset Password";
      dataabsen = widget.absenceHistoryData;
    } else {
      strakun = "AKUN SAYA";
      strbuttonupdate = "Perbarui Foto Profil";
    }
    _tglFilter = dailyFormat.format(now);
    // _absen_history();
  }

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        // 1. Perbarui variabel state UI terlebih dahulu untuk menampilkan preview lokal
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // 2. Jalankan fungsi upload di luar setState setelah state selesai diperbarui
        // uploadimage();
      }
    } catch (e) {
      debugPrint("Gagal mengambil gambar: $e");
    }
  }

  Future<void> loadNetworkImageToOpenFile(String url) async {
    try {
      // Unduh file byte dari internet
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Dapatkan direktori temporary sistem handphone
        final tempDir = await getTemporaryDirectory();

        // Buat nama file tiruan beserta ekstensinya (.jpg / .png)
        final String fileName =
            "profile_downloaded${p.extension(url).isEmpty ? '.jpg' : p.extension(url)}";
        final file = File('${tempDir.path}/$fileName');

        // Tulis data bytes network langsung ke dalam file lokal tersebut
        await file.writeAsBytes(response.bodyBytes);

        // Masukkan file lokal baru tersebut ke dalam variabel _imageFile
        setState(() {
          _imageFile = file;
        });
        print("Sukses mengunduh gambar dari server.");
      } else {
        throw Exception("Gagal mengunduh gambar dari server.");
      }
    } catch (e) {
      debugPrint("Error loading network image: $e");
      print("Error loading network image: $e");
    }
  }

  void resetpassword() {
    setState(() {
      isLoading = true;
    });
    fh
        .resetpassword(
            UserSession.employee_personalid,
            UserSession.employee_dob,
            UserSession.apikey,
            UserSession.token,
            "absen/ResetPassword",
            UserSession.url_api)
        .then((result) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void uploadimage() {
    setState(() {
      isLoading = true;
    });
    print("UserSession.employee_id : " + UserSession.employee_id);
    fh
        .uploadimageabsen(
            _imageFile!, UserSession.employee_id, "uploadgambar/profile")
        .then((result) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void uploadimageIDCard() {
    setState(() {
      isLoading = true;
    });
    fh
        .uploadimageIDCard(
            _imageFile!,
            "idcard_te",
            "/assets/upload/idcard/",
            "uploadgambar/photo",
            UserSession.apikey,
            UserSession.token,
            UserSession.url_api)
        .then((result) {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _showImageSourcePopup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors
          .transparent, // Agar background rounded container terlihat melayang
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(
              left: 24,
              right: 24,
              bottom: 30), // Efek melayang di atas navigasi bawah
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Sumber Foto',
                style: TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Pilihan 1: Kamera
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Tempatkan logika mengambil foto dari Kamera asli di sini
                        _pickImage(ImageSource.camera); // Pic dari Kamera
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: Color(0xFF001F82), size: 28),
                            SizedBox(height: 8),
                            Text(
                              'Kamera',
                              style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Pilihan 2: Galeri Foto
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        // Tempatkan logika mengambil foto dari Galeri di sini
                        _pickImage(ImageSource.gallery); // Pic dari Galeri
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Column(
                          children: [
                            Icon(Icons.photo_library_rounded,
                                color: AppColors.accent,
                                size: 28), // Menggunakan Orange Accent
                            SizedBox(height: 8),
                            Text(
                              'Galeri',
                              style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
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

  int _calculateAge(dynamic dobSource) {
    if (dobSource == null) return 0;

    DateTime dob;

    // Jika tipe data berupa String (contoh: "1995-12-30")
    if (dobSource is String) {
      try {
        dob = DateTime.parse(dobSource);
      } catch (e) {
        return 0; // Mengembalikan 0 jika format string gagal di-parse
      }
    }
    // Jika tipe data sudah berupa DateTime
    else if (dobSource is DateTime) {
      dob = dobSource;
    } else {
      return 0;
    }

    DateTime today = DateTime.now();
    int age = today.year - dob.year;

    // Kurangi 1 tahun jika tanggal ulang tahun di tahun ini belum terlewat
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }

    return age;
  }

  void employee_login() {
    setState(() {
      isLoading = true;
      dataabsen.clear();
    });
    fh
        .loginadmin(_nikController.text, UserSession.apikey, UserSession.token,
            "absen/loginadmin", UserSession.url_api)
        .then((resultlogin) {
      setState(() {
        isLoading = false;
      });
      print(resultlogin);
      if (resultlogin.isEmpty) {
        _showSnackBar("Data Tidak Ditemukan +  (SSO)", Colors.red);
      } else {
        resultlogin.forEach((value) {
          database_name = value['company'] ?? "";
          employee_get();
        });
      }
    });
  }

  void employee_get() {
    fh
        .employee(_nikController.text, database_name, UserSession.apikey,
            UserSession.token, "employee/show", UserSession.url_api)
        .then((result) {
      print(result);

      if (result.isNotEmpty) {
        result.forEach((value) {
          setState(() {
            UserSession.office_id = value['office_id'];
            UserSession.company_id = value['company_id'];
            UserSession.employee_id = value['employee_id'];
            UserSession.employee_name = value['employee_name'];
            UserSession.employee_personalid = value['employee_personalid'];
            UserSession.employee_fingerid = value['employee_fingerid'];
            UserSession.office_id = value['office_id'];
            UserSession.employee_gender = value['employee_gender'] ?? "";
            UserSession.employee_dateofbirth = newFormat.format(DateTime.parse(
                value['employee_dateofbirth'] ?? DateTime.now().toString()));
            UserSession.employee_dob = dailyFormat.format(DateTime.parse(
                value['employee_dateofbirth'] ?? DateTime.now().toString()));
            UserSession.divisi_name = value['division_name'] ?? "";
            UserSession.office_name = value['office_name'] ?? "";
            UserSession.department_name = value['department_name'] ?? "";
            UserSession.employee_type = value['employee_type'] ?? "";
            UserSession.employee_phone = value['employee_notelp1'] ?? "";

            UserSession.employee_address1 = value['employee_address1'] ?? "";
            UserSession.employee_address2 = value['employee_address2'] ?? "";
            UserSession.employee_bpjs = value['employee_bpjs'] ?? "";
            UserSession.employee_entrydate = value['employee_entrydate'] ?? "";
            UserSession.employee_joindate = newFormat.format(DateTime.parse(
                value['employee_entrydate'] ?? DateTime.now().toString()));
            UserSession.employeetype_name = value['employeetype_name'] ?? "";
            UserSession.employeeeducation_level =
                value['employeeeducation_level'] ?? "";
            UserSession.position_name = value['position_name'] ?? "";
            UserSession.profile_image_url =
                UserSession.url_image_profile + value['employee_id'] + ".jpg";
            isLoading = false;
          });
          print("database_name : " + database_name);
          _absen_history_bydate();
        });
      } else {
        dataabsen.clear();
      }
    });
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Tanggal awal saat kalender dibuka
      firstDate: DateTime(2020), // Batas tahun paling awal
      lastDate: DateTime(2030), // Batas tahun paling akhir
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary, // Warna Navy untuk header kalender
              onPrimary: Colors.white, // Warna teks di dalam header
              onSurface: Color(0xFF0F1E4A), // Warna teks tanggal kalender
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor:
                    AppColors.accent, // Warna tombol Batal/OK (Orange)
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        // Format hasil tanggal menjadi DD/MM/YYYY (Misal: 08/07/2026)
        String day = picked.day.toString().padLeft(2, '0');
        String month = picked.month.toString().padLeft(2, '0');
        String year = picked.year.toString();
        controller.text = "$day-$month-$year";
        _tglFilter = "$year-$month-$day";
      });
    }
  }

  void _absen_history_bydate() {
    setState(() {
      isLoading = true;
    });
    fh
        .absen_history_bydate(
            database_name,
            UserSession.employee_fingerid,
            _tglFilter,
            UserSession.apikey,
            UserSession.token,
            "absen/showabsenbydate",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      print(hasils);
      if (hasils.length > 0) {
        setState(() {
          dataabsen = hasils;
        });
      }
    });
  }

  Future<void> _openGoogleMaps(String lat, String lng) async {
    Uri uri;

    if (Platform.isAndroid) {
      // Protokol geo memaksa sistem Android langsung meluncurkan aplikasi Google Maps fisik
      uri = Uri.parse("geo:$lat,$lng?q=$lat,$lng");
    } else if (Platform.isIOS) {
      // Protokol comgooglemaps memaksa iOS membuka aplikasi Google Maps jika terinstal
      uri = Uri.parse("comgooglemaps://?q=$lat,$lng");
    } else {
      uri = Uri.parse("https://google.com");
    }

    try {
      // Mencoba membuka dengan mode external application (aplikasi bawaan HP)
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Jika skema khusus gagal (misal di iOS tidak ada Google Maps), lempar ke Google Maps versi web browser
      final Uri fallbackWebUri = Uri.parse("https://google.com");
      try {
        await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
      } catch (innerError) {
        print("Gagal total membuka Google Maps: $innerError");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dobData = UserSession.employee_dob;
    final entryData = UserSession.employee_entrydate;
    int userAge = _calculateAge(dobData);
    int userWork = _calculateAge(entryData);

    return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
        // App Bar tetap ada di atas untuk tulisan "Akun Saya"
        // appBar: AppBar(
        //   backgroundColor: AppColors.primary,
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   centerTitle: true,
        //   title: const Text(
        //     'Akun Saya',
        //     style: TextStyle(
        //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        //   ),
        // ),
        body: Column(children: [
          // 1. Indikator Loading Bar (Hanya muncul jika isLoading bernilai true)
          if (isLoading == true)
            const LinearProgressIndicator(
              backgroundColor: Color(0xFFF1F1F1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 4, // Ketebalan garis progress
            ),

          // Memberikan jarak tipis jika sedang loading
          if (isLoading == true) const SizedBox(height: 10),

          // 2. Konten Utama yang Bisa Di-scroll
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: AppColors
                        .accent, // Mengatur warna latar belakang menjadi Oranye
                    alignment: Alignment
                        .center, // Berfungsi sama seperti widget Center untuk menaruh konten di tengah
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Membuat teks berada di tengah horizontal
                      children: [
                        Text(
                          strakun,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  if (widget.userlevel == 1) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _nikController,
                              decoration: InputDecoration(
                                hintText: "Masukkan NIK",
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Sets a circular border radius of 20
                              ),
                            ),
                            onPressed: () {
                              // Navigator.pop(context);
                              if (_nikController.text == "") {
                                _showSnackBar("NIK masih kosong", Colors.red);
                              } else if (_nikController.text == "uploadphoto") {
                                _nikController.text = "";
                                _navigateToUploadPhoto(context);
                              } else {
                                employee_login();
                              }
                            },
                            child: new Text("CARI"),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                  ],
                  // ==================== CARD 1: INFORMASI AVATAR PROFIL ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                // Skenario Gradasi: Hanya muncul jika TIDAK ADA file lokal baru DAN URL network-nya kosong
                                gradient: (_imageFile == null &&
                                        UserSession.profile_image_url.isEmpty)
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFF0F1E4A),
                                          AppColors.secondary,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )
                                    : null,
                                // Jika ada file atau URL, gunakan warna dasar Navy Gelap ini sebelum gambar termuat
                                color: const Color(0xFF0F1E4A),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    50), // Setengah dari lebar/tinggi agar bulat sempurna
                                child: _imageFile != null
                                    ? Image.file(
                                        _imageFile!,
                                        fit: BoxFit.cover,
                                      )
                                    : UserSession.profile_image_url.isNotEmpty
                                        ? Image.network(
                                            "${UserSession.profile_image_url}?t=${DateTime.now().millisecondsSinceEpoch}",
                                            fit: BoxFit.cover,
                                            // 💡 JIKA URL RUSAK ATAU SERVER DOWN, OTOMATIS MUNDUR TAMPILKAN INISIAL
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
                                                    fit: BoxFit.contain),
                                              )
                                                  // child: Text(
                                                  //   _getInitials(UserSession
                                                  //       .employee_name),
                                                  //   style: const TextStyle(
                                                  //     color: Colors.white,
                                                  //     fontSize: 28,
                                                  //     fontWeight: FontWeight.bold,
                                                  //   ),
                                                  // ),
                                                  );
                                            },
                                            // Efek loading indikator melingkar saat proses unduh gambar
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                ),
                                              );
                                            },
                                          )
                                        : Center(
                                            // Skenario Cadangan: Jika memang URL kosong sejak awal dari database
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
                                                fit: BoxFit.contain),
                                          )
                                            // child: Text(
                                            //   _getInitials(
                                            //       UserSession.employee_name),
                                            //   style: const TextStyle(
                                            //     color: Colors.white,
                                            //     fontSize: 28,
                                            //     fontWeight: FontWeight.bold,
                                            //   ),
                                            // ),
                                            ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showImageSourcePopup(context);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(UserSession.employee_name,
                            style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(
                            '${UserSession.office_name} · ${UserSession.divisi_name}',
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== CARD 2: DETAIL INFORMASI FORM PROFIL ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(4))),
                            const SizedBox(width: 8),
                            const Text('Informasi Profil',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildProfileInputField(
                            label: 'Employee NIK',
                            value: UserSession.employee_personalid),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Nama Lengkap',
                            value: UserSession.employee_name),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Alamat',
                            value: UserSession.employee_address1),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Phone', value: UserSession.employee_phone),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Jenis Kelamin',
                                    value: UserSession.employee_gender)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Status',
                                    value: UserSession.employeetype_name)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Tanggal Lahir',
                                    value: UserSession.employee_dateofbirth)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Usia', value: '$userAge Tahun')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Tanggal Gabung',
                                    value: UserSession.employee_joindate)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: _buildProfileInputField(
                                    label: 'Masa Kerja',
                                    value: '$userWork Tahun')),
                          ],
                        ),
                        const SizedBox(height: 16),

                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'No BPJS', value: UserSession.employee_bpjs),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Pendidikan',
                            value: UserSession.employeeeducation_level +
                                "   " +
                                UserSession.employeeeducation_name),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Perusahaan',
                            value: UserSession.company_name),
                        const SizedBox(height: 16),
                        _buildProfileInputField(
                            label: 'Kantor / Cabang',
                            value: UserSession.office_name),
                        const SizedBox(height: 20),

                        // ==================== TEKS NOTIFIKASI MODE BACA (READ-ONLY) ====================
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFF001F82),
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Data ditampilkan dalam mode baca (read-only). Perubahan data pribadi mengikuti kebijakan perusahaan melalui HR.',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // ==================== TOMBOL OUTLINE: PERBARUI FOTO PROFIL ====================

                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // _showImageSourcePopup(context);
                              if (widget.userlevel == 1) {
                                _showDialog("Yakin Reset Password??");
                              } else {
                                if (_imageFile != null &&
                                    _imageFile!.path.isNotEmpty) {
                                  uploadimage();
                                } else {
                                  _showSnackBar(
                                      "Foto Belum dipilih", Colors.red);
                                }
                              }
                            },
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF001F82), size: 18),
                            label: Text(
                              strbuttonupdate,
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
                        const SizedBox(height: 40),
                        if (widget.userlevel == 1) ...[
                          const Text('Riwayat Absen',
                              style: TextStyle(
                                  color: Color(0xFF0F1E4A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _selectDate(
                                      context, _tglFilterController),
                                  child: AbsorbPointer(
                                    // Memastikan keyboard bawaan HP tidak ikut muncul
                                    child: _buildDropdownInputField(
                                      controller: _tglFilterController,
                                      hintText: 'Pilih Tanggal',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 30),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Sets a circular border radius of 20
                                  ),
                                ),
                                onPressed: () {
                                  _absen_history_bydate();
                                }, // The icon to display
                                child: const Text(
                                    'Filter'), // The text label for the button
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          if (dataabsen.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 16),
                                    Text(
                                      'Tidak ada data absensi valid.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 15),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            // 🔑 SOLUSI: Menggunakan builder dari perulangan map secara langsung tanpa fungsi anonim buntu
                            ...() {
                              // 1. Filter data untuk menghilangkan tanggal yang duplikat
                              final Set<String> seenDates = {};
                              final List<dynamic> uniqueHistory =
                                  dataabsen.where((item) {
                                final String date = item['dateabsen'] ?? '';
                                if (date.isEmpty || seenDates.contains(date)) {
                                  return false;
                                }
                                seenDates.add(date);
                                return true;
                              }).toList();

                              // 2. Jika setelah difilter hasilnya kosong (misal data corrupt)
                              if (uniqueHistory.isEmpty) {
                                return [
                                  const Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 40),
                                      child: Text(
                                        'Tidak ada data absensi valid.',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  )
                                ];
                              }

                              // 3. Render list item menggunakan map secara langsung (mengembalikan List<Widget> untuk Column)
                              return uniqueHistory.map((item) {
                                // Format Tanggal ke "dd MMM yyyy"
                                String rawDate = item['absence_date'] ?? '';
                                String absence_latin =
                                    item['absence_latin'] ?? '';
                                String absence_latout =
                                    item['absence_latout'] ?? '';
                                String absence_longin =
                                    item['absence_longin'] ?? '';
                                String absence_longout =
                                    item['absence_longout'] ?? '';
                                String formattedDate = '-';
                                if (rawDate.isNotEmpty) {
                                  try {
                                    DateTime parsedDate =
                                        DateTime.parse(rawDate);
                                    formattedDate =
                                        DateFormat('dd MMM yyyy', 'id_ID')
                                            .format(parsedDate);
                                  } catch (e) {
                                    formattedDate = rawDate;
                                  }
                                }

                                // Logika Kode Absensi (H = Hadir, HL = Terlambat)
                                final String absenceCode =
                                    item['absence_code'] ?? '';
                                final bool isTerlambat =
                                    absenceCode.toUpperCase() == 'HL';

                                final String statusLabel =
                                    isTerlambat ? 'Terlambat' : 'Hadir';
                                final Color statusColor = isTerlambat
                                    ? AppColors.accent
                                    : const Color(0xFF2ECC71);
                                final Color statusBgColor = isTerlambat
                                    ? const Color(0xFFFEF5E7)
                                    : const Color(0xFFE8F8F5);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildAttendanceHistoryCard(
                                      context: context,
                                      dayDate: formattedDate,
                                      statusLabel: statusLabel,
                                      statusColor: statusColor,
                                      statusBgColor: statusBgColor,
                                      checkInTime:
                                          item['absence_oin'] ?? '--.--',
                                      checkOutTime:
                                          item['absence_oout'] ?? '--.--',
                                      imageurl_in: UserSession.url_api_image +
                                          (item['absence_imagein'] ?? ''),
                                      imageurl_out: UserSession.url_api_image +
                                          (item['absence_imageout'] ?? ''),
                                      imageurl_in_dev:
                                          UserSession.url_api_image_dev +
                                              (item['absence_imagein'] ?? ''),
                                      imageurl_out_dev:
                                          UserSession.url_api_image_dev +
                                              (item['absence_imageout'] ?? ''),
                                      absence_latin: absence_latin,
                                      absence_latout: absence_latout,
                                      absence_longin: absence_longin,
                                      absence_longout: absence_longout),
                                );
                              }).toList();
                            }(),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ]));
  }

  Widget _buildProfileInputField(
      {required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF0F1E4A),
                fontSize: 14,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: const Color(0xFFF0F2F6),
              borderRadius: BorderRadius.circular(14)),
          child: Text(value,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  void _showSnackBar(String pesan, Color warnaBg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: warnaBg,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDropdownInputField(
      {required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      readOnly: true, // Membuatnya beraksi seperti selektor
      style: const TextStyle(
          fontSize: 15, color: Color(0xFF0F1E4A), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFFBFBFD),
        suffixIcon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade500, size: 24),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }

  // REUSABLE HELPER CARD WIDGET (Diperbarui dengan BuildContext)
  Widget _buildAttendanceHistoryCard({
    required BuildContext context, // Tambahkan parameter context di sini
    required String dayDate,
    required String statusLabel,
    required Color statusColor,
    required Color statusBgColor,
    required String checkInTime,
    required String checkOutTime,
    required String imageurl_in,
    required String imageurl_out,
    required String imageurl_in_dev,
    required String imageurl_out_dev,
    required String absence_latin,
    required String absence_latout,
    required String absence_longin,
    required String absence_longout,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.02 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Kolom Foto Check-In (Bungkus InkWell untuk aksi klik)
              Expanded(
                child: InkWell(
                  onTap: () {
                    print("imageurl_in : $imageurl_in");
                    widget.onIndexChanged(12);
                    widget.titleLabel('Masuk');
                    widget.dayDate(dayDate);
                    widget.timeLabel(checkInTime);
                    widget.statusLabel(statusLabel);
                    widget.statusColor(statusColor);
                    widget.statusBgColor(statusBgColor);
                    widget.imageurl(imageurl_in);
                    widget.absenceData(dataabsen);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageAttachmentBox(
                      titleLabel: 'Masuk',
                      timeLabel: checkInTime,
                      imageurl: imageurl_in,
                      imageurl_dev: imageurl_in_dev,
                      latitude: absence_latin,
                      longitude: absence_longin),
                ),
              ),
              const SizedBox(width: 16),

              // Kolom Foto Check-Out (Bungkus InkWell untuk aksi klik)
              Expanded(
                child: InkWell(
                  onTap: () {
                    print("imageurl_out : $imageurl_out");
                    widget.onIndexChanged(12);
                    widget.titleLabel('Keluar');
                    widget.dayDate(dayDate);
                    widget.timeLabel(checkOutTime);
                    widget.statusLabel(statusLabel);
                    widget.statusColor(statusColor);
                    widget.statusBgColor(statusBgColor);
                    widget.imageurl(imageurl_out);
                    widget.absenceData(dataabsen);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageAttachmentBox(
                      titleLabel: 'Keluar',
                      timeLabel: checkOutTime,
                      imageurl: imageurl_out,
                      imageurl_dev: imageurl_out_dev,
                      latitude: absence_latout,
                      longitude: absence_longout),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // REUSABLE HELPER: Kotak Foto Mini dari Network Khusus Attachment List Absen
  Widget _buildImageAttachmentBox({
    required String titleLabel,
    required String timeLabel,
    required String imageurl,
    required String imageurl_dev,
    required String latitude,
    required String longitude,
  }) {
    return Column(
      children: [
        // Box Pratinjau Gambar Mini dari Network
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: const Color(
                0xFF0A1E46), // Background dasar gelap jika gambar loading
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
                5), // Memastikan sudut gambar melengkung rapi
            child: Image.network(
              // URL contoh foto untuk daftar list riwayat. Silakan ganti dengan variabel URL API Anda nantinya.
              imageurl,
              fit: BoxFit
                  .fill, // Gambar dipotong proporsional mengisi seluruh kotak mini

              // 1. INDIKATOR LOADING: Spinner kecil saat gambar mini sedang diunduh
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accent), // Spinner warna Orange
                    ),
                  ),
                );
              },

              // 2. ERROR CADANGAN: Tampilan gradasi Navy-Plum jika koneksi gagal / URL kosong
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF0A1E46),
                        AppColors.secondary, // #4f0049 - Plum
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.white24,
                      size: 22,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Label Teks Judul (e.g. Check In)
        Text(
          titleLabel,
          style: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),

        // Angka Jam Absensi Tebal
        Text(
          timeLabel,
          style: const TextStyle(
            color: Color(0xFF0F1E4A),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        IconButton(
          icon: Icon(Icons.location_on, color: Colors.red, size: 28),
          onPressed: () {
            print("latitude : " + latitude);
            print("longitude : " + longitude);
            _openGoogleMaps(latitude, longitude);
          },
        ),
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.white,
        //   ),
        //   onPressed: () {
        //     print("latitude : " + latitude);
        //     print("longitude : " + longitude);
        //     _openGoogleMaps(latitude, longitude);
        //   }, // The icon to display
        //   child: const Icon(Icons.location_on,
        //       color: Colors.red, size: 28), // The text label for the button
        // ),
      ],
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
              resetpassword();
            },
            child: new Text("OK"),
          )),
        ],
      ),
    );
  }

  void _navigateToUploadPhoto(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => UploadPhotoPage(
              url_api: UserSession.url_api,
              apikey: UserSession.apikey,
              token: UserSession.token,
            ));
    Navigator.push<void>(context, route);
  }
}
