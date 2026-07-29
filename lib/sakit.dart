import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'user_session.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class SakitPage extends StatefulWidget {
  final List<dynamic> HistoryData;
  final ValueChanged<List<dynamic>> DataHistory;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<String> imageurl;
  const SakitPage({
    super.key,
    required this.HistoryData,
    required this.DataHistory,
    required this.onIndexChanged,
    required this.imageurl,
  });

  @override
  State<SakitPage> createState() => _SakitPageState();
}

class _SakitPageState extends State<SakitPage> {
  // Controller untuk menangani input teks dinamis
  final _subjekController = TextEditingController(text: '');
  final _tanggalawalController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _tanggalakhirController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _nomorKontakController =
      TextEditingController(text: UserSession.employee_phone);
  final _alamatKontakController = TextEditingController(text: "");

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  // Variabel state untuk menyimpan file dokumen yang diunggah
  File? _dokumenPendukung;
  // File? _catatanDokter;
  // File? _dokumenLain;

  final ImagePicker _imagePicker = ImagePicker();

  String strlatitude = "";
  String strlongitude = "";
  Position? _currentPosition;
  HelperFunction fh = HelperFunction();
  String date_from = "";
  String date_to = "";
  var imageFormat = DateFormat("yyyyMMddHHmmss");
  String uploadimage_name = "";
  String file_image_name = "";
  bool isLoading = false;

  List<dynamic> dataabsen = [];

  // Fungsi inti untuk memproses pengambilan gambar dari Kamera/Galeri
  Future<void> _pickDocument(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Kompres kualitas gambar ke 80%
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'surat') {
            _dokumenPendukung = File(pickedFile.path);
          }
          // else if (type == 'catatan') {
          //   _catatanDokter = File(pickedFile.path);
          // } else if (type == 'lain') {
          //   _dokumenLain = File(pickedFile.path);
          // }
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil berkas: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.HistoryData.isEmpty) {
      _absen_history();
    } else {
      dataabsen = widget.HistoryData;
    }
  }

  @override
  void dispose() {
    _subjekController.dispose();
    _tanggalawalController.dispose();
    _tanggalakhirController.dispose();
    _nomorKontakController.dispose();
    _alamatKontakController.dispose();
    super.dispose();
  }

  void _absen_history() {
    setState(() {
      isLoading = true;
    });
    fh
        .absen_history(
            UserSession.database_name,
            UserSession.employee_fingerid,
            UserSession.apikey,
            UserSession.token,
            "absen/showsakit_izin",
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

  // Fungsi untuk memunculkan Date Picker Kalender
  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2045),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F1E4A),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        String day = picked.day.toString().padLeft(2, '0');
        String month = picked.month.toString().padLeft(2, '0');
        String year = picked.year.toString();
        controller.text = "$day-$month-$year";
        if (controller == _tanggalawalController) {
          _tanggalakhirController.text = "$day-$month-$year";
        }
      });
    }
  }

  // Jendela Opsi Opsi Pilihan Kamera/Galeri yang Melayang
  void _showSourceSelectionPopup(BuildContext context, String targetType) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.only(left: 24, right: 24, bottom: 30),
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
                'Pilih Sumber Dokumen',
                style: TextStyle(
                    color: Color(0xFF0F1E4A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  // Kamera
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickDocument(ImageSource.camera, targetType);
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
                            Text('Kamera',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Galeri
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        _pickDocument(ImageSource.gallery, targetType);
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
                                color: AppColors.accent, size: 28),
                            SizedBox(height: 8),
                            Text('Galeri',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontWeight: FontWeight.bold)),
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

  _getCurrentLocation(File imageFile) async {
    print('_getAddressFromLatLng2');

    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
      });

      //insert data absen
      if (UserSession.debug == "on") {
        insertdata(imageFile);
      } else {
        _showDialog("Data Production...!!!!");
      }
    }).catchError((e) {
      print(e);
      print('error : _getAddressFromLatLng');
      setState(() {
        isLoading = false;
      });
    });
  }

  void insertdata(File imageFile) {
    print("insertdata");
    DateTime now = DateTime.now();
    try {
      // 1. Validasi & Parse Tanggal Awal
      if (_tanggalawalController.text.isNotEmpty) {
        String tanggalAsal = _tanggalawalController.text;
        DateTime parsedDateFrom = DateFormat('dd-MM-yyyy').parse(tanggalAsal);
        date_from = DateFormat('yyyy-MM-dd').format(parsedDateFrom);
      } else {
        // Jika kosong, berikan fallback tanggal hari ini atau string kosong
        date_from = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
      }

      // 2. Validasi & Parse Tanggal Akhir (Pastikan menggunakan controller tanggal akhir!)
      if (_tanggalakhirController.text.isNotEmpty) {
        String tanggalAkhir = _tanggalakhirController.text;
        DateTime parsedDateTo = DateFormat('dd-MM-yyyy').parse(tanggalAkhir);
        date_to = DateFormat('yyyy-MM-dd').format(parsedDateTo);
      } else {
        // Jika kosong, berikan fallback tanggal hari ini atau string kosong
        date_to = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
      }
    } catch (e) {
      // Menangkap error jika teks di dalam controller formatnya rusak (misal: "09-07-2026" bukan "2026-07-09")
      debugPrint("Gagal memproses tanggal: $e");

      // Tampilkan pesan peringatan ke user jika diperlukan
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Format tanggal salah atau belum dipilih!')),
      );
    }

    file_image_name =
        UserSession.employee_id + "_" + imageFormat.format(now) + ".jpg";
    uploadimage_name = UserSession.employee_id + "_" + imageFormat.format(now);
    print("insertdata2");
    fh
        .absenceonline_insert_new(
            imageFile,
            uploadimage_name,
            UserSession.database_name,
            UserSession.employee_id,
            UserSession.listcompany_id,
            UserSession.company_id,
            UserSession.office_id,
            UserSession.employee_personalid,
            UserSession.employee_fingerid,
            UserSession.employee_name,
            "SAKIT",
            "00:00:00",
            date_from,
            file_image_name,
            _subjekController.text,
            UserSession.employee_type,
            _subjekController.text,
            date_to,
            strlongitude,
            strlatitude,
            UserSession.device_info,
            "ANDROID MOBILE APPS",
            UserSession.apikey,
            UserSession.token,
            "absen/insertnew",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      if (hasils == "sukses") {
        _absen_history();
        // fh
        //     .uploadimageabsen(
        //         imageFile, uploadimage_name, "uploadgambar/upload")
        //     .then((hasilfoto) {
        //   print("hasilfoto : " + hasilfoto);
        setState(() {
          _dokumenPendukung = null;
          _tanggalawalController.text = _getFormattedTodayStatic();
          _tanggalakhirController.text = _getFormattedTodayStatic();
          _subjekController.text = "";
        });
        _showDialog("Data Berhasil Disimpan");
        //   if (hasilfoto == "sukses") {

        //   }
        // });
      } else {
        _showDialog(hasils);
        // _resetCameraStream();
      }
    });
  }

  Future<File?> _compressImage(File file) async {
    // Menentukan lokasi dan nama file target kompresi (.jpg)
    print('_compressImage');
    final filePath = file.absolute.path;
    final lastIndex = filePath.lastIndexOf(RegExp(r'.png|.jpg|.jpeg'));
    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_compressed.jpg";

    // Memulai proses kompresi native
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality:
          80, // Menurunkan kualitas ke 70% (ukuran turun drastis, visual tetap tajam)
      minWidth: 1080, // Membatasi lebar maksimal gambar ke 1080 piksel
      minHeight: 1080, // Membatasi tinggi maksimal gambar ke 1080 piksel
    );

    if (result == null) return null;
    return File(result.path); // Mengembalikan objek File yang sudah dikompresi
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary,
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: const Row(
      //     children: [
      //       SizedBox(width: 12),
      //       Text(
      //         'Pengajuan Cuti Sakit',
      //         style: TextStyle(
      //             color: Colors.white,
      //             fontWeight: FontWeight.bold,
      //             fontSize: 20),
      //       ),
      //     ],
      //   ),
      // ),
      body: Column(
        children: [
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    color: AppColors
                        .accent, // Mengatur warna latar belakang menjadi Oranye
                    alignment: Alignment
                        .center, // Berfungsi sama seperti widget Center untuk menaruh konten di tengah
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, // Membuat teks berada di tengah horizontal
                      children: [
                        Text(
                          'SAKIT',
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
                  // ==================== CARD 1: INFORMASI PEGAWAI (READ-ONLY) ====================
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section Informasi Pegawai
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.accent, // Orange
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.dns_rounded,
                                  color: Colors.white, size: 11),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Informasi Pegawai',
                              style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        _buildReadOnlyField(
                            label: 'Employee ID',
                            value: UserSession.employee_personalid),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            label: 'Nama Lengkap',
                            value: UserSession.employee_name),
                        const SizedBox(height: 16),

                        // Baris Gabungan: Tanggal Lahir & Jenis Kelamin
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyField(
                                  label: 'Tanggal Lahir',
                                  value: UserSession.employee_dateofbirth),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildReadOnlyField(
                                  label: 'Jenis Kelamin',
                                  value: UserSession.employee_gender),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildReadOnlyField(
                            label: 'Kantor', value: UserSession.office_name),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================== CARD 2: DETAIL CUTI SAKIT (DIPERBARUI) ====================
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.add,
                                  color: Colors.white, size: 12),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Detail Sakit',
                              style: TextStyle(
                                  color: Color(0xFF0F1E4A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Input Subjek
                        _buildFormLabel('Subjek'),
                        _buildTextAreaField(
                            controller: _subjekController,
                            hintText: 'Masukkan alasan sakit'),
                        const SizedBox(height: 16),

                        // Input Tanggal Kalender
                        _buildFormLabel('Tanggal Awal'),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context, _tanggalawalController);
                          },
                          child: AbsorbPointer(
                            child: _buildDropdownInputField(
                                controller: _tanggalawalController,
                                hintText: 'Pilih tanggal'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Tanggal Kalender
                        _buildFormLabel('Tanggal Akhir'),
                        GestureDetector(
                          onTap: () {
                            _selectDate(context, _tanggalakhirController);
                          },
                          child: AbsorbPointer(
                            child: _buildDropdownInputField(
                                controller: _tanggalakhirController,
                                hintText: 'Pilih tanggal'),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Nomor Kontak (Tambahan Baru Sesuai Gambar)
                        _buildFormLabel('Nomor Kontak'),
                        _buildInputField(
                          controller: _nomorKontakController,
                          hintText: 'Masukkan nomor kontak aktif',
                          keyboardType: TextInputType.phone,
                        ),
                        // const SizedBox(height: 16),

                        // // Input Nomor Kontak (Tambahan Baru Sesuai Gambar)
                        // _buildFormLabel('Alamat Kontak'),
                        // _buildTextAreaField(
                        //   controller: _alamatKontakController,
                        //   hintText: 'Masukkan Alamat kontak aktif',
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== CARD 3: DOKUMEN PENDUKUNG DINAMIS ====================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Icon(Icons.description,
                                color: AppColors.accent, size: 20),
                            const SizedBox(width: 10),
                            const Text(
                              'Dokumen Pendukung',
                              style: TextStyle(
                                  color: Color(0xFF0F1E4A),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 6),
                            Text('(opsional)',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                        const SizedBox(height: 24), // Kotak Unggah 1
                        _buildUploadBox(
                          label: _dokumenPendukung != null
                              ? 'Berhasil Diunggah (Ketuk untuk ubah)'
                              : 'Unggah Dokumen Pendukung',
                          isUploaded: _dokumenPendukung != null,
                          onTap: () =>
                              _showSourceSelectionPopup(context, 'surat'),
                        ),
                        // const SizedBox(height: 16), // Kotak Unggah 2
                        // _buildUploadBox(
                        //   label: _catatanDokter != null
                        //       ? 'Catatan Dokter Terunggah (Ketuk untuk ubah)'
                        //       : 'Unggah Catatan Dokter',
                        //   isUploaded: _catatanDokter != null,
                        //   onTap: () =>
                        //       _showSourceSelectionPopup(context, 'catatan'),
                        // ),
                        // const SizedBox(height: 16), // Kotak Unggah 3
                        // _buildUploadBox(
                        //   label: _dokumenLain != null
                        //       ? 'Lampiran Lain Terunggah (Ketuk untuk ubah)'
                        //       : 'Unggah Dokumen Pendukung Lain',
                        //   isUploaded: _dokumenLain != null,
                        //   onTap: () => _showSourceSelectionPopup(context, 'lain'),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== CARD 4: ALUR PERSETUJUAN ====================
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(20),
                  //   decoration: BoxDecoration(
                  //     color: Colors.white,
                  //     borderRadius: BorderRadius.circular(24),
                  //     boxShadow: [
                  //       BoxShadow(
                  //         color: Colors.black.withAlpha((0.02 * 255).round()),
                  //         blurRadius: 10,
                  //         offset: const Offset(0, 4),
                  //       )
                  //     ],
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       // Header Section Alur Persetujuan
                  //       const Row(
                  //         children: [
                  //           Icon(
                  //             Icons.check_circle_rounded,
                  //             color: AppColors.accent, // Orange
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 10),
                  //           Text(
                  //             'Alur Persetujuan',
                  //             style: TextStyle(
                  //               color: Color(0xFF0F1E4A),
                  //               fontSize: 18,
                  //               fontWeight: FontWeight.bold,
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 24),

                  //       // Stepper 1: Atasan Langsung (Selesai/Disetujui - Hijau)
                  //       _buildSakitTimelineTile(
                  //         title: 'Atasan Langsung',
                  //         subtitle: 'Disetujui · 3 Jul 2026, 08.20',
                  //         statusIcon: Icons.check,
                  //         statusColor: const Color(0xFF2ECC71), // Hijau Sukses
                  //       ),

                  //       // Stepper 2: Human Resources (Sedang Berjalan - Orange)
                  //       _buildSakitTimelineTile(
                  //         title: 'Human Resources',
                  //         subtitle: 'Menunggu persetujuan',
                  //         statusIcon: Icons.access_time_filled_rounded,
                  //         statusColor: AppColors.accent, // Orange Accent
                  //         isLast: true,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),

                  // ==================== TOMBOL UTAMA: AJUKAN CUTI SAKIT ====================
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_subjekController.text == "") {
                          _showDialog("Subjek Sakit Belum Diisi");
                        } else if (_dokumenPendukung != null) {
                          setState(() {
                            isLoading = true;
                          });

                          File? compressedFile =
                              await _compressImage(_dokumenPendukung!);
                          _getCurrentLocation(compressedFile!);
                        } else {
                          _showDialog("Dokumen Pendukung belum dipilih");
                        }
                      },
                      icon: const Icon(Icons.check_circle,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Ajukan Sakit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent, // #fd8a02 - Orange
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // ==================== KELOMPOK MENU: RIWAYAT ====================
                  _buildSectionCard(
                    title: 'Riwayat Sakit',
                    iconTitle: Icons.history_toggle_off_rounded,
                    iconColor: AppColors.accent,
                    showSeeAll: true,
                    child: Column(
                      children: [
                        // KONDISI 1: JIKA DATA MASIH LOADING / KOSONG
                        if (dataabsen.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: Column(
                                children: [
                                  // SizedBox(
                                  //   width: 24,
                                  //   height: 24,
                                  //   child: CircularProgressIndicator(
                                  //     valueColor: AlwaysStoppedAnimation<Color>(
                                  //         AppColors.accent),
                                  //     strokeWidth: 2.5,
                                  //   ),
                                  // ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Tidak ada data...',
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
                            // 1. Filter data untuk menghilangkan tanggal duplikat DAN memfilter absence_code = "C"
                            final Set<String> seenDates = {};
                            final List<dynamic> uniqueHistory =
                                dataabsen.where((item) {
                              final String date = item['absence_date'] ?? '';
                              final String absenceCode = item['absence_code'] ??
                                  ''; // Ambil nilai absence_code

                              // FILTER UTAMA: Hanya loloskan item jika absence_code bernilai "C"
                              if (absenceCode != 'S') {
                                return false;
                              }

                              // FILTER DUPLIKAT: Skip jika tanggal kosong atau sudah terdaftar sebelumnya
                              if (date.isEmpty || seenDates.contains(date)) {
                                return false;
                              }

                              seenDates
                                  .add(date); // Tandai tanggal sudah terbaca
                              return true;
                            }).toList();

                            // 2. Ambil maksimal 5 data unik teratas dan petakan ke widget Row
                            return uniqueHistory.take(5).map((item) {
                              String rawDate = item['absence_date'] ?? '';
                              String statusText = item['absence_reason'] ?? '';
                              String formattedDate = '-';
                              String image_url = item['absence_imagein'] ?? '';

                              print("rawDate2 $rawDate");

                              if (rawDate.isNotEmpty) {
                                try {
                                  DateTime parsedDate = DateTime.parse(rawDate);
                                  formattedDate =
                                      DateFormat('dd MMMM yyyy', 'id_ID')
                                          .format(parsedDate);
                                } catch (e) {
                                  formattedDate = rawDate;
                                }
                              }

                              // Tampilkan Baris Widget per Item Data
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 0),
                                child: _buildAttendanceRow(
                                    dayDate: formattedDate,
                                    statusText: statusText,
                                    image_url: image_url),
                              );
                            }).toList();
                          }(),

                        const SizedBox(
                            height: 6), // Menyeimbangkan jarak sebelum tombol
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WIDGET FORM & UPLOAD CARD ====================
  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
            color: Color(0xFF0F1E4A),
            fontSize: 14,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // REUSABLE HELPER: Membuat Kotak Read-Only Abu-abu Terkunci (Informasi Pegawai)
  Widget _buildReadOnlyField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF0F1E4A),
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F2F6), // Isian abu pudar presisi gambar
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(
      {required TextEditingController controller,
      required String hintText,
      TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
          fontSize: 15, color: Color(0xFF0F1E4A), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFFBFBFD),
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

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String hintText,
    int minLines = 2, // Default awal 2 baris, bisa disesuaikan saat dipanggil
    int? maxLines, // Kosongkan agar bisa memanjang otomatis sesuai ketikan
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType
          .multiline, // Mengoptimalkan keyboard HP untuk teks paragraf banyak baris
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
          fontSize: 15, color: Color(0xFF0F1E4A), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: const Color(0xFFFBFBFD),
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

  Widget _buildDropdownInputField(
      {required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
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

// REUSABLE HELPER: Membuat Kotak Unggah Berkas dengan Parameter isUploaded yang Valid
  Widget _buildUploadBox(
      {required String label,
      required bool isUploaded,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFE8F8F5) : const Color(0xFFFBFBFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded
                ? const Color(0xFF2ECC71)
                : const Color(0xFF7A869A).withAlpha((0.4 * 255).round()),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(isUploaded ? Icons.check_circle_rounded : Icons.upload_rounded,
                color: isUploaded
                    ? const Color(0xFF2ECC71)
                    : const Color(0xFF001F82),
                size: 26),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: isUploaded
                        ? const Color(0xFF2ECC71)
                        : Colors.grey.shade500,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat diagram alur persetujuan cuti sakit
  Widget _buildSakitTimelineTile({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Garis & Lingkaran Ikon Bulat Tegas
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color:
                    statusColor, // Warna background penuh sesuai gambar referensi Anda
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon,
                  color: Colors.white,
                  size: 18), // Warna icon putih di dalam lingkaran
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: const Color(
                    0xFFCBD5E1), // Jembatan garis vertikal abu-abu halus
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Keterangan Jabatan & Waktu Aksi
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12), // Jarak renggang antar tahapan alur
            ],
          ),
        ),
      ],
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
      margin: const EdgeInsets.symmetric(horizontal: 0),
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
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildAttendanceRow({
    required String dayDate,
    required String statusText,
    required String image_url,
  }) {
    return Column(
      children: <Widget>[
        Divider(height: 5.0),
        ListTile(
          title: Text(
            dayDate,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
          ),
          subtitle: Text(
            statusText,
            style: TextStyle(fontSize: 12.0),
          ),
          trailing: IconButton(
              icon: const Icon(Icons.image),
              onPressed: () {
                widget.onIndexChanged(13);
                widget.imageurl(UserSession.url_api_image + image_url);
                widget.DataHistory(dataabsen);
                // showDialog(
                //   context: context,
                //   builder: (context) => Dialog(
                //     backgroundColor: Colors
                //         .transparent, // Membuat latar belakang modal tembus pandang
                //     insetPadding: const EdgeInsets.all(
                //         20), // Jarak modal dari tepi layar HP
                //     child: Column(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         // Tombol Close di Atas Kanan Gambar
                //         Align(
                //           alignment: Alignment.centerRight,
                //           child: IconButton(
                //             icon: const Icon(Icons.close,
                //                 color: Colors.white, size: 30),
                //             onPressed: () => Navigator.pop(context),
                //           ),
                //         ),
                //         const SizedBox(height: 10),

                //         // Wadah Gambar Ukuran Besar
                //         ClipRRect(
                //           borderRadius: BorderRadius.circular(16),
                //           child: Image.network(
                //             UserSession.url_api_image + image_url,
                //             width: MediaQuery.of(context).size.width *
                //                 0.85, // Lebar gambar 85% layar
                //             fit: BoxFit.contain,
                //             errorBuilder: (context, error, stackTrace) {
                //               return Container(
                //                 padding: const EdgeInsets.all(20),
                //                 // color: Colors.white,
                //                 child: const Icon(
                //                   Icons.image_not_supported_outlined,
                //                   color: Colors.black,
                //                   size: 100,
                //                 ),
                //               );
                //             },
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              }),
          //onTap: () => _navigateToNote(context, items[position]),
        ),
      ],
    );
  }
}
