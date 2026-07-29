import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'app_colors.dart';
import 'package:image_picker/image_picker.dart';
import 'user_session.dart';
import 'package:hcms/database/function_helper.dart';

class UploadPhotoPage extends StatefulWidget {
  final String url_api;
  final String apikey;
  final String token;
  const UploadPhotoPage({
    super.key,
    required this.url_api,
    required this.apikey,
    required this.token,
  });

  @override
  State<UploadPhotoPage> createState() => _UploadPhotoPageState();
}

class _UploadPhotoPageState extends State<UploadPhotoPage> {
  HelperFunction fh = new HelperFunction();
  // Variabel untuk menyimpan file gambar yang dipilih
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  String employeeName = "";
  bool isLoading = false;
  String strakun = "AKUN SAYA";
  final _nikController = TextEditingController(text: '/assets/upload/idcard/');
  final _nameController = TextEditingController(text: 'idcard_te');
  // Fungsi internal untuk memproses pengambilan gambar
  String database_name = "";
  var newFormat = DateFormat("dd MMM yyyy");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  String strbuttonupdate = "Perbarui Foto Profil";
  DateTime now = DateTime.now();
  List<dynamic> dataabsen = [];

  @override
  void initState() {
    super.initState();
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
            _nameController.text,
            _nikController.text,
            "uploadgambar/photo",
            widget.apikey,
            widget.token,
            widget.url_api)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),
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
                  const SizedBox(height: 50),
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
                          "UPLOAD PHOTO",
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
                          ],
                        ),

                        // ==================== TEKS NOTIFIKASI MODE BACA (READ-ONLY) ====================

                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nikController,
                                  decoration: InputDecoration(
                                    hintText: "Path",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    hintText: "Name",
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
                              if (_nikController.text == "") {
                                _showSnackBar("path kosong", Colors.red);
                              } else if (_nameController.text == "") {
                                _showSnackBar("nama belum diisi", Colors.red);
                              } else if (_imageFile == null) {
                                _showSnackBar(
                                    "gambar belum dipilih", Colors.red);
                              } else {
                                uploadimageIDCard();
                              }
                            },
                            icon: const Icon(Icons.edit,
                                color: Color(0xFF001F82), size: 18),
                            label: Text(
                              "UPLOAD",
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
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageAttachmentBox(
                      titleLabel: 'Masuk',
                      timeLabel: checkInTime,
                      imageurl: imageurl_in,
                      imageurl_dev: imageurl_in_dev),
                ),
              ),
              const SizedBox(width: 16),

              // Kolom Foto Check-Out (Bungkus InkWell untuk aksi klik)
              Expanded(
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(16),
                  child: _buildImageAttachmentBox(
                      titleLabel: 'Keluar',
                      timeLabel: checkOutTime,
                      imageurl: imageurl_out,
                      imageurl_dev: imageurl_out_dev),
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
                  // child: Image.network(
                  //    imageurl_dev,
                  //   fit: BoxFit.fill,
                  // ),
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
            },
            child: new Text("OK"),
          )),
        ],
      ),
    );
  }
}
