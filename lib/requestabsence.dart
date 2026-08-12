import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'app_colors.dart';
import 'user_session.dart';

import 'package:geolocator/geolocator.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:intl/intl.dart';

class RequestAbsencePage extends StatefulWidget {
  final List<dynamic> HistoryData;
  final List<dynamic> HistoryDataApproval;
  final ValueChanged<List<dynamic>> DataHistory;
  final ValueChanged<List<dynamic>> DataApprovalHistory;
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<String> imageurl;
  const RequestAbsencePage({
    super.key,
    required this.HistoryData,
    required this.HistoryDataApproval,
    required this.DataHistory,
    required this.DataApprovalHistory,
    required this.onIndexChanged,
    required this.imageurl,
  });

  @override
  State<RequestAbsencePage> createState() => _RequestAbsencePageState();
}

class _RequestAbsencePageState extends State<RequestAbsencePage> {
  // Controller untuk menangani isi teks dinamis formulir
  final _subjekController = TextEditingController(text: '');
  final _tanggalawalController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _tanggalakhirController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _nomorKontakController =
      TextEditingController(text: UserSession.employee_phone);
  final _alamatKontakController = TextEditingController(text: '');

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  // Variabel untuk menyimpan file dokumen yang diunggah
  File? _dokumenPendukung;
  // File? _suratKeterangan;
  // File? _lampiranLain;

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
  List<dynamic> dataabsenapproval = [];

  String _selectedJenisIzinID = "Personal";
  String _selectedJenisIzinName = "Personal";
  String strError = "";
  String noimagename = "";
  // Fungsi inti untuk memicu pengambilan gambar berdasarkan sumber yang dipilih
  Future<void> _pickDocument(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'pendukung') {
            _dokumenPendukung = File(pickedFile.path);
          }
          // else if (type == 'keterangan') {
          //   _suratKeterangan = File(pickedFile.path);
          // } else if (type == 'lain') {
          //   _lampiranLain = File(pickedFile.path);
          // }
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil file: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.HistoryData.isEmpty) {
      _absen_history();
      _absenapproval_history();
    } else {
      dataabsen = widget.HistoryData;
      dataabsenapproval = widget.HistoryDataApproval;
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
        .requestabsen_history(
            UserSession.database_name,
            UserSession.employee_personalid,
            UserSession.apikey,
            UserSession.token,
            "requestabsen/showrequestabsen",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      print("_absen_history : ");
      print(hasils);
      if (hasils.length > 0) {
        setState(() {
          dataabsen = hasils;
        });
      }
    });
  }

  void _absenapproval_history() {
    setState(() {
      isLoading = true;
    });
    fh
        .requestabsen_history(
            UserSession.database_name,
            UserSession.employee_personalid,
            UserSession.apikey,
            UserSession.token,
            "requestabsen/showrequestabsenapproval",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      print("_absenapproval_history : ");
      print(hasils);
      if (hasils.length > 0) {
        setState(() {
          dataabsenapproval = hasils;
        });
      }
    });
  }

  // Fungsi untuk memunculkan selektor kalender (Date Picker) bawaan
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
      // if (UserSession.debug == "on") {
      insertdata(imageFile);
      // } else {
      //   _showDialog("Data Production...!!!!");
      // }
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
    int iDateFrom = 0;
    int iDateTo = 0;
    try {
      // 1. Validasi & Parse Tanggal Awal
      if (_tanggalawalController.text.isNotEmpty) {
        String tanggalAsal = _tanggalawalController.text;
        DateTime parsedDateFrom = DateFormat('dd-MM-yyyy').parse(tanggalAsal);
        date_from = DateFormat('yyyy-MM-dd').format(parsedDateFrom);
        iDateFrom = parsedDateFrom.millisecondsSinceEpoch;
      } else {
        // Jika kosong, berikan fallback tanggal hari ini atau string kosong
        date_from = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
      }

      // 2. Validasi & Parse Tanggal Akhir (Pastikan menggunakan controller tanggal akhir!)
      if (_tanggalakhirController.text.isNotEmpty) {
        String tanggalAkhir = _tanggalakhirController.text;
        DateTime parsedDateTo = DateFormat('dd-MM-yyyy').parse(tanggalAkhir);
        date_to = DateFormat('yyyy-MM-dd').format(parsedDateTo);
        iDateTo = parsedDateTo.millisecondsSinceEpoch;
      } else {
        // Jika kosong, berikan fallback tanggal hari ini atau string kosong
        date_to = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
      }

      if (iDateFrom > iDateTo) {
        _showDialog("Tanggal awal tidak boleh melebihi tanggal akhir!");
        setState(() {
          isLoading = false;
        });
        return;
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
    if (noimagename == "noimage") {
      file_image_name = "noimage.jpg";
      uploadimage_name = "noimage";
    } else {
      file_image_name =
          UserSession.employee_id + "_" + imageFormat.format(now) + ".jpg";
      uploadimage_name =
          UserSession.employee_id + "_" + imageFormat.format(now);
    }
    print("insertdata2");
    fh
        .requestabsen_insert(
            imageFile,
            UserSession.database_name,
            UserSession.employee_personalid,
            UserSession.employee_name,
            _subjekController.text,
            date_from,
            date_to,
            strlatitude,
            strlongitude,
            UserSession.employee_name,
            file_image_name,
            uploadimage_name,
            UserSession.apikey,
            UserSession.token,
            "requestabsen/requestinsert",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
        strError = hasils;
      });
      if (hasils.substring(0, 6) == "sukses") {
        _absen_history();
        setState(() {
          _dokumenPendukung = null;
          _tanggalawalController.text = _getFormattedTodayStatic();
          _tanggalakhirController.text = _getFormattedTodayStatic();
          _subjekController.text = "";
          noimagename = "";
        });
        _showDialog(hasils.replaceAll("sukses_", ""));
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

  Future<File?> noimage() async {
    try {
      // 1. Membaca data binary/bytes dari folder assets aplikasi
      final ByteData byteData = await rootBundle.load('assets/noimage.png');
      final Uint8List bytes = byteData.buffer.asUint8List();

      // 2. Mendapatkan akses ke folder penyimpanan sementara milik aplikasi di HP
      final Directory tempDir = await getTemporaryDirectory();

      // 3. Membuat file fisik baru dan menuliskan bytes gambar ke dalamnya
      final File tempFile = File('${tempDir.path}/fallback_noimage.png');
      await tempFile.writeAsBytes(bytes);

      // 4. Memasukkan file tersebut ke dalam variabel _dokumenPendukung
      setState(() {
        _dokumenPendukung =
            tempFile; // Langsung masukkan tempFile karena tipenya sudah File
        noimagename = "noimage";
      });

      print("Dokumen kosong, otomatis menggunakan fallback dari asset.");

      // 5. Kembalikan objek tempFile yang berhasil dibuat
      return tempFile;
    } catch (e) {
      print("Gagal mengambil gambar dari asset: $e");
      return null; // Kembalikan null jika proses gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA), // Latar belakang abu-abu muda bersih

      // ==================== APP BAR UTAMA ====================
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary, // Navy (#001668)
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     children: [
      //       const Text(
      //         'Pengajuan Izin',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 20,
      //         ),
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
                          'PANGAJUAN ABSENSI',
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

                  // ==================== CARD 2: DETAIL PENGAJUAN IZIN (EDITABLE) ====================
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
                        // Header Section Detail Pengajuan Izin
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
                              'Detail Pengajuan Absensi',
                              style: TextStyle(
                                color: Color(0xFF0F1E4A),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Input Subjek
                        _buildFormLabel('Subjek'),
                        _buildTextAreaField(
                          controller: _subjekController,
                          hintText: 'Masukkan alasan Pengajuan',
                        ),
                        const SizedBox(height: 16),

                        // Input Tanggal Izin (Kalender Terintegrasi)
                        _buildFormLabel('Tanggal Awal'),
                        GestureDetector(
                          onTap: () =>
                              _selectDate(context, _tanggalawalController),
                          child: AbsorbPointer(
                            child: _buildDropdownInputField(
                              controller: _tanggalawalController,
                              hintText: 'Pilih tanggal Awal',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Input Tanggal Izin (Kalender Terintegrasi)
                        _buildFormLabel('Tanggal Akhir'),
                        GestureDetector(
                          onTap: () =>
                              _selectDate(context, _tanggalakhirController),
                          child: AbsorbPointer(
                            child: _buildDropdownInputField(
                              controller: _tanggalakhirController,
                              hintText: 'Pilih tanggal akhir',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // const SizedBox(height: 16),
                        // _buildFormLabel('Nomor Kontak'),
                        // _buildInputField(
                        //   controller: _nomorKontakController,
                        //   hintText: 'Masukkan nomor kontak aktif',
                        //   keyboardType: TextInputType.phone,
                        // ),
                        // const SizedBox(height: 16),
                        // // Input Nomor Kontak (Tambahan Baru Sesuai Gambar)
                        // _buildFormLabel('Alamat Kontak'),
                        // _buildTextAreaField(
                        //     controller: _alamatKontakController,
                        //     hintText: 'Masukkan Alamat kontak aktif',
                        //     maxLines: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ==================== CARD 3: DOKUMEN PENDUKUNG ====================
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
                            Text(
                              '(opsional)',
                              style: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // 1. Unggah Dokumen Pendukung
                        _buildUploadBox(
                          label: _dokumenPendukung != null
                              ? 'Berhasil Diunggah (Ketuk untuk ubah)'
                              : 'Unggah Dokumen Pendukung',
                          isUploaded: _dokumenPendukung != null,
                          onTap: () =>
                              _showSourceSelectionPopup(context, 'pendukung'),
                        ),
                        const SizedBox(height: 16),

                        // // 2. Unggah Surat Keterangan
                        // _buildUploadBox(
                        //   label: _suratKeterangan != null
                        //       ? 'Berhasil Diunggah (Ketuk untuk ubah)'
                        //       : 'Unggah Surat Keterangan',
                        //   isUploaded: _suratKeterangan != null,
                        //   onTap: () =>
                        //       _showSourceSelectionPopup(context, 'keterangan'),
                        // ),
                        // const SizedBox(height: 16),

                        // // 3. Unggah Lampiran Lain
                        // _buildUploadBox(
                        //   label: _lampiranLain != null
                        //       ? 'Berhasil Diunggah (Ketuk untuk ubah)'
                        //       : 'Unggah Lampiran Lain',
                        //   isUploaded: _lampiranLain != null,
                        //   onTap: () => _showSourceSelectionPopup(context, 'lain'),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Text(
                  //   strError,
                  //   style: TextStyle(
                  //     color: Color(0xFF0F1E4A),
                  //     fontSize: 18,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),

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
                  //       const Row(
                  //         children: [
                  //           Icon(Icons.check_circle_rounded,
                  //               color: AppColors.accent, size: 20),
                  //           const SizedBox(width: 10),
                  //           Text(
                  //             'Alur Persetujuan',
                  //             style: TextStyle(
                  //                 color: Color(0xFF0F1E4A),
                  //                 fontSize: 18,
                  //                 fontWeight: FontWeight.bold),
                  //           ),
                  //         ],
                  //       ),
                  //       const SizedBox(height: 24),

                  //       // Stepper 1: Atasan Langsung (Menunggu Persetujuan - Orange)
                  //       _buildIzinTimelineTile(
                  //         title: 'Atasan Langsung',
                  //         subtitle: 'Burhanuddin',
                  //         statusIcon: Icons.access_time_filled_rounded,
                  //         statusColor: AppColors.accent,
                  //       ),

                  //       // Stepper 2: Human Resources (Belum Mulai - Abu-abu)
                  //       _buildIzinTimelineTile(
                  //         title: 'Human Resources',
                  //         subtitle: 'Human Resources',
                  //         statusIcon: Icons.access_time_filled_rounded,
                  //         statusColor: const Color(0xFF94A3B8),
                  //         isLast: true,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // const SizedBox(height: 24),
                  // ==================== TOMBOL UTAMA: AJUKAN IZIN ====================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        print("_tanggalawal : " + _tanggalawalController.text);
                        print(
                            "_tanggalakhir : " + _tanggalakhirController.text);
                        // Masukkan logika integrasi kirim form izin ke backend API

                        // 1. String asal format Indonesia
                        // String tanggalAsal = _tanggalawalController.text;
                        // DateTime parsedDate =
                        //     DateFormat('dd-MM-yyyy').parse(tanggalAsal);
                        // String tanggalHasil =
                        //     DateFormat('yyyy-MM-dd').format(parsedDate);

                        // print(tanggalHasil);
                        if (_subjekController.text == "") {
                          _showDialog("Subjek Pengajuan Belum Diisi");
                        } else {
                          _showDialogReq(
                              "Anda mengajukan Absensi mulai tanggal ${_tanggalawalController.text} s/d ${_tanggalakhirController.text}, \n\n Apakah pengajuan anda sudah benar?");
                        }
                      },
                      icon: const Icon(Icons.check_circle,
                          color: Colors.white, size: 20),
                      label: const Text(
                        'Ajukan Absensi',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            AppColors.accent, // Orange Accent (#fd8a02)
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  // ==================== KELOMPOK MENU: RIWAYAT ====================
                  _buildSectionCard(
                    title: 'Riwayat Pengajuan Absensi',
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

                            // 2. Ambil maksimal 5 data unik teratas dan petakan ke widget Row
                            return dataabsen.map((item) {
                              String rawDateStart =
                                  item['requestabsence_datestart'] ?? '';
                              String rawDateEnd =
                                  item['requestabsence_dateend'] ?? '';
                              String statusText =
                                  item['requestabsence_subject'] ?? '';
                              String formattedDateStart = '-';
                              String formattedDateEnd = '-';
                              String image_url =
                                  item['requestabsence_file'] ?? '';
                              int isapproved =
                                  item['requestabsence_approved'] ?? 0;

                              if (isapproved == 1) {
                                statusText = statusText + "   (Disetujui)";
                              } else {
                                statusText = statusText + "   (Pengajuan)";
                              }

                              print("rawDate2 $rawDateStart");

                              if (rawDateStart.isNotEmpty) {
                                try {
                                  DateTime parsedDate =
                                      DateTime.parse(rawDateStart);
                                  formattedDateStart =
                                      DateFormat('dd MMM yyyy', 'id_ID')
                                          .format(parsedDate);
                                } catch (e) {
                                  formattedDateStart = rawDateStart;
                                }
                              }

                              if (rawDateEnd.isNotEmpty) {
                                try {
                                  DateTime parsedDate =
                                      DateTime.parse(rawDateEnd);
                                  formattedDateEnd =
                                      DateFormat('dd MMM yyyy', 'id_ID')
                                          .format(parsedDate);
                                } catch (e) {
                                  formattedDateEnd = rawDateEnd;
                                }
                              }

                              // Tampilkan Baris Widget per Item Data
                              return Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 0, left: 0, right: 0),
                                child: _buildAttendanceRow(
                                  id: item['requestabsence_id'] ?? '',
                                  dayDate: formattedDateStart +
                                      " - " +
                                      formattedDateEnd,
                                  statusText: statusText,
                                  image_url: image_url,
                                  iconTitle: isapproved == 1
                                      ? Icons.check_circle
                                      : Icons.history_toggle_off_rounded,
                                  iconColor: isapproved == 1
                                      ? Colors.green
                                      : AppColors.accent,
                                ),
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

  // ==================== REUSABLE HELPER METODE WIDGET ====================
  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0F1E4A),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
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
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
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

  Widget _buildDropdownInputField({
    required TextEditingController controller,
    required String hintText,
  }) {
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
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

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
            color: const Color(
                0xFFF0F2F6), // Isian abu pudar presisi sesuai gambar
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

  // REUSABLE HELPER: Membuat Kotak Unggah Dokumen
  // REUSABLE HELPER: Membuat Kotak Unggah Berkas dengan Status Dinamis
  Widget _buildUploadBox({
    required String label,
    required bool isUploaded, // TAMBAHKAN PARAMETER INI
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          // Berubah menjadi warna hijau pudar jika berkas sudah sukses terisi
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
            // Ikon berubah menjadi tanda centang jika sukses terunggah
            Icon(
              isUploaded ? Icons.check_circle_rounded : Icons.upload_rounded,
              color: isUploaded
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFF001F82),
              size: 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color:
                    isUploaded ? const Color(0xFF2ECC71) : Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE HELPER: Membuat Baris Timeline Alur Persetujuan Vertikal
  Widget _buildIzinTimelineTile({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration:
                  BoxDecoration(color: statusColor, shape: BoxShape.circle),
              child: Icon(statusIcon, color: Colors.white, size: 18),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        const SizedBox(width: 16),
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
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  // Fungsi Pembantu: Memunculkan Bottom Sheet Opsi Kamera/Galeri yang Melayang
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
                            const SizedBox(height: 8),
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
                            const SizedBox(height: 8),
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

  _showDialogReq(String keterangan) async {
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
            onPressed: () async {
              Navigator.pop(context);
              if (_dokumenPendukung != null) {
                setState(() {
                  isLoading = true;
                });

                File? compressedFile = await _compressImage(_dokumenPendukung!);
                _getCurrentLocation(compressedFile!);
              } else {
                setState(() {
                  isLoading = true;
                });
                File? noimageFile = await noimage();
                _getCurrentLocation(noimageFile!);
                // _showDialog("Dokumen Pendukung belum dipilih");
              }
            },
            child: new Text("OK"),
          )),
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
    required String id,
    required String dayDate,
    required String statusText,
    required String image_url,
    required IconData iconTitle,
    required Color iconColor,
    // Tetap sediakan default parameter jika data array kosong
    String managerRole = "",
    String approvalStatus = "",
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
            top: 10,
            left: 5,
            bottom: 10,
            right: 10), // Menambahkan padding bawah & kanan agar seimbang
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BARIS 1: Info Utama Absensi & Tombol Gambar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Status Kiri
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: CircleAvatar(
                    radius: 11,
                    backgroundColor: iconColor,
                    child: Icon(iconTitle, size: 12, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12.0),

                // Teks Judul & Tanggal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        statusText,
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        dayDate,
                        style: TextStyle(
                            fontSize: 12.0, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),

                // Tombol Gambar Kanan
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.image, color: Colors.black, size: 22),
                  onPressed: () {
                    print(UserSession.url_api_image + image_url);
                    widget.onIndexChanged(13);
                    widget.imageurl(UserSession.url_api_image + image_url);
                    widget.DataHistory(dataabsen);
                    widget.DataApprovalHistory(dataabsenapproval);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12.0),

            // BARIS 2: Melakukan perulangan data approval secara dinamis
            // Menggunakan operator spread (...) untuk memasukkan list widget ke dalam children
            ...dataabsenapproval
                .where((item) =>
                    item['requestabsence_id'].toString() ==
                    id.toString()) // Baris Filter Data
                .map((item) {
              // Ambil nama langsung ke variabel lokal baru di dalam map
              final dynamicName =
                  item['requestabsenceapproval_name'] ?? 'TIDAK DIKETAHUI';
              final dynamicRole =
                  item['requestabsenceapproval_position'] ?? managerRole;
              // final dynamicStatus =
              //     item['requestabsenceapproval_iscommited'] ?? approvalStatus;
              if (item['requestabsenceapproval_iscommited'] == 1) {
                approvalStatus = "Disetujui";
              } else {
                approvalStatus = "Dalam Pengajuan";
              }
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12.0),
                margin: const EdgeInsets.only(
                    bottom:
                        8.0), // Jarak antar kotak approval jika manajer lebih dari satu
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Info Nama & Jabatan Manajer
                    Expanded(
                      // Ditambahkan Expanded agar teks nama yang panjang tidak meluap (overflow)
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dynamicName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            dynamicRole,
                            style: TextStyle(
                              fontSize: 10.0,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(6.0),
                      ),
                      child: Text(
                        approvalStatus,
                        style: TextStyle(
                          color: approvalStatus == "Disetujui"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioJenisCutiTile(String label, String id, int jumlah) {
    final bool isSelected = _selectedJenisIzinName == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedJenisIzinID = id;
          _selectedJenisIzinName = label;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              color:
                  isSelected ? const Color(0xFF001F82) : Colors.grey.shade400,
              size: 24,
            ),
            const SizedBox(width: 12),
            // MEMBUNGKUS TEXT DENGAN EXPANDED AGAR OTOMATIS TURUN BARIS
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
