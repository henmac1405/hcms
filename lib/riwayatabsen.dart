import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'package:intl/intl.dart';
import 'user_session.dart';
import 'package:hcms/database/function_helper.dart';
// import 'riwayatdialogfullimage.dart';

class RiwayatAbsenPage extends StatefulWidget {
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
  const RiwayatAbsenPage({
    Key? key,
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
  }) : super(key: key);

  @override
  State<RiwayatAbsenPage> createState() => _RiwayatAbsenPageState();
}

class _RiwayatAbsenPageState extends State<RiwayatAbsenPage> {
  HelperFunction fh = HelperFunction();
  bool isLoading = false;
  String _tglFilter = "";
  final _tglFilterController =
      TextEditingController(text: _getFormattedTodayStatic());
  var dateFormat = DateFormat("yyyy-MM-dd");
  DateTime now = DateTime.now();
  List<dynamic> dataabsen = [];

  @override
  void initState() {
    dataabsen = widget.absenceHistoryData;
    _tglFilter = dateFormat.format(now);
    // _absen_history_bydate();
    super.initState();
  }

  void _showFullImageDialog({
    required BuildContext context,
    required String titleLabel,
    required String dayDate,
    required String timeLabel,
    required String statusLabel,
    required Color statusColor,
    required Color statusBgColor,
    required String imageurl,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          backgroundColor:
              const Color(0xFF0F1E4A), // Latar belakang gelap Navy pekat
          child: SafeArea(
            child: Column(
              children: [
                // ==================== HEADER PREVIEW ====================
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$titleLabel - $timeLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayDate,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      // Tombol Tutup (X) bulat minimalis
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // ==================== AREA FOTO UKURAN PENUH (DARI NETWORK) ====================
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xFF0A1E46), // Background dasar gelap
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                          5), // Memastikan gambar mengikuti lengkungan container
                      child: Image.network(
                        // URL contoh gambar absensi dari internet. Silakan ganti string url ini dengan variabel data API Anda.
                        imageurl,
                        fit: BoxFit.fill, // Gambar memenuhi seluruh area kotak

                        // 1. LOADING INDICATOR: Efek saat gambar sedang diunduh
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  AppColors.accent), // Loading berwarna Orange
                            ),
                          );
                        },

                        // 2. ERROR PLACEHOLDER: Tampilan cadangan jika internet mati atau URL rusak
                        errorBuilder: (BuildContext context, Object error,
                            StackTrace? stackTrace) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF0A1E46),
                                  AppColors.secondary
                                ], // Kembali ke gradasi Navy - Plum
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons
                                      .signal_wifi_connected_no_internet_4_rounded,
                                  color: AppColors
                                      .alert, // Icon error berwarna merah
                                  size: 48,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Gagal memuat foto absensi',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ==================== FOOTER DETAIL STATUS ====================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Status Kehadiran',
                            style: TextStyle(
                              color: Color(0xFF0F1E4A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusBgColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Waktu Tercatat',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 14),
                          ),
                          Text(
                            '$timeLabel WIB',
                            style: const TextStyle(
                              color: Color(0xFF0F1E4A),
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  // Fungsi untuk memunculkan kalender (Date Picker)
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
            UserSession.database_name,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF4F6FA), // Latar belakang abu-abu muda bersih

      // ==================== APP BAR ====================
      // appBar: AppBar(
      //   backgroundColor: AppColors.primary, // Navy (#001668)
      //   elevation: 0,
      //   automaticallyImplyLeading: false,
      //   title: const Row(
      //     children: [
      //       Text(
      //         'Riwayat Absen',
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
                          'RIWAYAT ABSEN',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 15),
                  // ==================== BANNER INFORMASI ATAS ====================
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                          0xFFEFF3FF), // Background biru muda pudar halus
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: const Color(0xFFD2DFFF), width: 1),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Color(0xFF001F82),
                          size: 18,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Menampilkan 5 hari terakhir, data terbaru di atas. Ketuk foto untuk pratinjau ukuran penuh.',
                            style: TextStyle(
                              color: Color(0xFF5A6A85),
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Tanggal

                  // Field Tanggal Kembali
                  // _buildFormLabel('Tanggal'),

                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              _selectDate(context, _tglFilterController),
                          child: AbsorbPointer(
                            // Memastikan keyboard bawaan HP tidak ikut muncul
                            child: _buildDropdownInputField(
                              controller: _tglFilterController,
                              hintText: 'Pilih Tanggal',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
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
                      ),
                    ],
                  ),

                  // ==================== LIST DATA RIWAYAT (MAXIMAL 7 DATA - TANPA DUPLIKAT TANGGAL) ====================

                  // ==================== LIST DATA RIWAYAT (MAXIMAL 5 DATA - TANPA DUPLIKAT TANGGAL) ====================
                  if (dataabsen.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 16),
                            Text(
                              'tidak ada data riwayat absensi...',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 15),
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
                              padding: EdgeInsets.symmetric(vertical: 40),
                              child: Text(
                                'Tidak ada data absensi valid.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        ];
                      }

                      // 3. Render list item menggunakan map secara langsung (mengembalikan List<Widget> untuk Column)
                      return uniqueHistory.take(5).map((item) {
                        // Format Tanggal ke "dd MMM yyyy"
                        String rawDate = item['absence_date'] ?? '';
                        String formattedDate = '-';
                        if (rawDate.isNotEmpty) {
                          try {
                            DateTime parsedDate = DateTime.parse(rawDate);
                            formattedDate = DateFormat('dd MMM yyyy', 'id_ID')
                                .format(parsedDate);
                          } catch (e) {
                            formattedDate = rawDate;
                          }
                        }

                        // Logika Kode Absensi (H = Hadir, HL = Terlambat)
                        final String absenceCode = item['absence_code'] ?? '';
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
                            checkInTime: item['absence_oin'] ?? '--.--',
                            checkOutTime: item['absence_oout'] ?? '--.--',
                            imageurl_in: UserSession.url_api_image +
                                (item['absence_imagein'] ?? ''),
                            imageurl_out: UserSession.url_api_image +
                                (item['absence_imageout'] ?? ''),
                            imageurl_in_dev: UserSession.url_api_image_dev +
                                (item['absence_imagein'] ?? ''),
                            imageurl_out_dev: UserSession.url_api_image_dev +
                                (item['absence_imageout'] ?? ''),
                          ),
                        );
                      }).toList();
                    }(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== REUSABLE HELPER CARD WIDGET ====================
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
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return DialogFullImagePage(
                    //         titleLabel: 'Masuk',
                    //         dayDate: dayDate,
                    //         timeLabel: checkInTime,
                    //         statusLabel: statusLabel,
                    //         statusColor: statusColor,
                    //         statusBgColor: statusBgColor,
                    //         imageurl: imageurl_in);
                    //   },
                    // );

                    // _showFullImageDialog(
                    //     context: context,
                    //     titleLabel: 'Masuk',
                    //     dayDate: dayDate,
                    //     timeLabel: checkInTime,
                    //     statusLabel: statusLabel,
                    //     statusColor: statusColor,
                    //     statusBgColor: statusBgColor,
                    //     imageurl: imageurl_in);
                  },
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
                    // showDialog(
                    //   context: context,
                    //   builder: (BuildContext context) {
                    //     return DialogFullImagePage(
                    //         titleLabel: 'Keluar',
                    //         dayDate: dayDate,
                    //         timeLabel: checkOutTime,
                    //         statusLabel: statusLabel,
                    //         statusColor: statusColor,
                    //         statusBgColor: statusBgColor,
                    //         imageurl: imageurl_out);
                    //   },
                    // );
                    // _showFullImageDialog(
                    //     context: context,
                    //     titleLabel: 'Keluar',
                    //     dayDate: dayDate,
                    //     timeLabel: checkOutTime,
                    //     statusLabel: statusLabel,
                    //     statusColor: statusColor,
                    //     statusBgColor: statusBgColor,
                    //     imageurl: imageurl_out);
                  },
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

  // HELPER: Label teks form
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

  // HELPER: Input Field Aktif dengan Ikon Panah Dropdown Sesuai Gambar
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
}
