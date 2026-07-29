import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'user_session.dart';

// import 'package:geolocator/geolocator.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:intl/intl.dart';

class CutiPage extends StatefulWidget {
  final ValueChanged<int> onIndexChanged;
  final ValueChanged<String> leave_date;
  final ValueChanged<String> leave_datestart;
  final ValueChanged<String> leave_dateend;
  final ValueChanged<String> leave_qty;
  final ValueChanged<String> leave_descr;
  final ValueChanged<String> leave_nokontak;
  final ValueChanged<String> leave_alamatkontak;
  final ValueChanged<String> leave_type;
  final ValueChanged<String> jatahCuti;
  final ValueChanged<String> sisaCuti;
  const CutiPage({
    super.key,
    required this.onIndexChanged,
    required this.leave_date,
    required this.leave_datestart,
    required this.leave_dateend,
    required this.leave_qty,
    required this.leave_descr,
    required this.leave_nokontak,
    required this.leave_alamatkontak,
    required this.leave_type,
    required this.jatahCuti,
    required this.sisaCuti,
  });

  @override
  State<CutiPage> createState() => _CutiPageState();
}

class _CutiPageState extends State<CutiPage> {
  // Controller untuk menangani input teks dinamis
  final _subjekController = TextEditingController(text: '');
  final _tanggalawalController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _tanggalakhirController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _nomorKontakController =
      TextEditingController(text: UserSession.employee_phone);
  final _alamatKontakController = TextEditingController(text: '');

  // State untuk melacak Jenis Cuti yang dipilih (Default: Cuti Tahunan)
  String _selectedJenisCuti = 'Cuti Tahunan';
  String _selectedJenisCutiID = '2';
  int _selectedJatahCuti = 0;

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  String strlatitude = "";
  String strlongitude = "";
  // Position? _currentPosition;
  HelperFunction fh = HelperFunction();
  String date_from = "";
  String date_to = "";
  var imageFormat = DateFormat("yyyyMMddHHmmss");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var yearFormat = DateFormat("yyyy");
  DateTime now = DateTime.now();
  String _year = "";
  String uploadimage_name = "";
  String file_image_name = "";
  bool isLoading = false;

  List<dynamic> datacuti = [];
  List<dynamic> leavetype = [];
  List<dynamic> leavebalance = [];
  String leave_date = "";
  int leave_qty = 1;
  int sisa_cuti = 0;
  int jatah_cuti = 0;
  int jatah_cuti_bulanan = 0;
  int jumlah_diambil = 0;
  @override
  void initState() {
    super.initState();
    leave_date = dailyFormat.format(now);
    _year = yearFormat.format(now);
    master_leavetype();
    master_leave_balance();
    cuti_history();
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
            onPressed: () {
              Navigator.pop(context);
              insertcuti();
            },
            child: new Text("OK"),
          )),
        ],
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

  void master_leavetype() {
    setState(() {
      isLoading = true;
    });
    fh
        .master_leavetype(UserSession.database_name, UserSession.apikey,
            UserSession.token, "cuti/showleavetype", UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      print(hasils);
      if (hasils.length > 0) {
        setState(() {
          leavetype = hasils;
        });
      }
    });
  }

  void master_leave_balance() {
    fh
        .master_leave_balance(
            UserSession.database_name,
            UserSession.employee_personalid,
            _year,
            UserSession.apikey,
            UserSession.token,
            "cuti/showcutibalance",
            UserSession.url_api)
        .then((hasils) async {
      print(hasils);

      leavebalance = hasils;
      if (leavebalance.length > 0) {
        leavebalance.forEach((rows) {
          setState(() {
            sisa_cuti = rows['sisa_cuti'] ?? 0;
            jatah_cuti_bulanan = rows['jatah_cuti_bulanan'] ?? 0;
            jumlah_diambil = rows['jumlah_diambil'] ?? 0;
          });
        });
      }
    });
  }

  void cuti_history() {
    setState(() {
      isLoading = true;
    });
    fh
        .cuti_history(
            UserSession.database_name,
            UserSession.employee_personalid,
            UserSession.apikey,
            UserSession.token,
            "cuti/showcuti",
            UserSession.url_api)
        .then((hasils) async {
      setState(() {
        isLoading = false;
      });
      print(hasils);
      if (hasils.length > 0) {
        setState(() {
          datacuti = hasils;
        });
      }
    });
  }

  void insertcuti() {
    print("insertcuti");
    setState(() {
      isLoading = true;
    });
    DateTime now = DateTime.now();
    try {
      // Buat variabel DateTime temporary untuk kalkulasi leave_qty
      DateTime calculationDateFrom;
      DateTime calculationDateTo;

      // 1. Validasi & Parse Tanggal Awal
      if (_tanggalawalController.text.isNotEmpty) {
        String tanggalAsal = _tanggalawalController.text;
        DateTime parsedDateFrom = DateFormat('dd-MM-yyyy').parse(tanggalAsal);
        date_from = DateFormat('yyyy-MM-dd').format(parsedDateFrom);
        calculationDateFrom = parsedDateFrom; // Simpan objek DateTime
      } else {
        date_from = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
        calculationDateFrom = now; // Fallback ke DateTime hari ini
      }

      // 2. Validasi & Parse Tanggal Akhir
      if (_tanggalakhirController.text.isNotEmpty) {
        String tanggalAkhir = _tanggalakhirController.text;
        DateTime parsedDateTo = DateFormat('dd-MM-yyyy').parse(tanggalAkhir);
        date_to = DateFormat('yyyy-MM-dd').format(parsedDateTo);
        calculationDateTo = parsedDateTo; // Simpan objek DateTime
      } else {
        date_to = DateFormat('yyyy-MM-dd', 'id_ID').format(now);
        calculationDateTo = now; // Fallback ke DateTime hari ini
      }

      // 3. Hitung selisih hari menggunakan objek DateTime
      // Catatan: Ditambah 1 jika tanggal akhir juga dihitung sebagai hari cuti (inklusif)
      leave_qty = calculationDateTo.difference(calculationDateFrom).inDays + 1;

      // Jika Anda ingin mengupdate UI, pastikan panggil setState(() {}); jika variabel di atas adalah State
    } catch (e) {
      debugPrint("Gagal memproses tanggal: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Format tanggal salah atau belum dipilih!')),
      );
    }
    if (_selectedJenisCutiID == "2") {
      jatah_cuti = jatah_cuti_bulanan;
    } else {
      jatah_cuti = _selectedJatahCuti;
      sisa_cuti = _selectedJatahCuti;
    }
    fh
        .cuti_insert(
            UserSession.database_name,
            UserSession.employee_personalid,
            leave_date,
            _selectedJenisCutiID,
            leave_qty.toString(),
            date_from,
            date_to,
            _alamatKontakController.text,
            _subjekController.text,
            UserSession.employee_name,
            UserSession.office_id,
            _nomorKontakController.text,
            sisa_cuti.toString(),
            jatah_cuti.toString(),
            UserSession.apikey,
            UserSession.token,
            "cuti/insertcuti",
            UserSession.url_api)
        .then((hasils) {
      if (hasils == "sukses") {
        // _absen_history();

        setState(() {
          isLoading = false;
        });
        _tanggalawalController.text = _getFormattedTodayStatic();
        _tanggalakhirController.text = _getFormattedTodayStatic();
        _subjekController.text = "";
        cuti_history();
        _showDialog("Pengajuan Cuti Berhasil");
      } else {
        setState(() {
          isLoading = false;
        });
        _showDialog(hasils);
        // _resetCameraStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        // ==================== APP BAR ====================
        // appBar: AppBar(
        //   backgroundColor: AppColors.primary,
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   title: const Row(
        //     children: [
        //       Text(
        //         'Pengajuan Cuti Tahunan',
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
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
                            'PENGAJUAN CUTI',
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
                                  value: UserSession.employee_dateofbirth,
                                ),
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
                              label: 'Kantor / Cabang',
                              value: UserSession.office_name),
                          const SizedBox(height: 16),
                          _buildReadOnlyField(
                              label: 'Sisa Cuti Tahunan',
                              value: sisa_cuti.toString()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==================== CARD 2: DETAIL PENGAJUAN CUTI (DIPERBARUI) ====================
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
                          // Header Section
                          const Row(
                            children: [
                              Icon(Icons.calendar_month,
                                  color: AppColors.accent, size: 20),
                              SizedBox(width: 10),
                              Text(
                                'Detail Pengajuan Cuti',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // 1. Subjek Cuti
                          _buildFormLabel('Subjek Cuti'),
                          _buildTextAreaField(
                              controller: _subjekController,
                              hintText: 'Masukkan subjek cuti',
                              maxLines: 2),
                          const SizedBox(height: 16),

                          // 2. Baris Selektor Tanggal (Tgl Mulai & Tgl Selesai)
                          _buildFormLabel('Tanggal Awal'),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, _tanggalawalController),
                            child: AbsorbPointer(
                              child: _buildDropdownInputField(
                                  controller: _tanggalawalController,
                                  hintText: 'Awal'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFormLabel('Tanggal Akhir'),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, _tanggalakhirController),
                            child: AbsorbPointer(
                              child: _buildDropdownInputField(
                                  controller: _tanggalakhirController,
                                  hintText: 'Akhir'),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 3. Jenis Cuti (Sesuai List Gambar Anda)
                          _buildFormLabel('Jenis Cuti'),

                          if (leavetype.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 32,
                                      height: 32,
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.accent),
                                        strokeWidth: 3,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Jenis Cuti tidak ditemukan',
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

                              // 3. Render list item menggunakan map secara langsung (mengembalikan List<Widget> untuk Column)
                              return leavetype.map((item) {
                                final String leavetype_id =
                                    item['leavetype_id'] ?? '';
                                final String leavetype_name =
                                    item['leavetype_descr'] ?? '';
                                final int leavetype_qty =
                                    item['leavetype_qty'] ?? 0;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: _buildRadioJenisCutiTile(
                                      leavetype_name,
                                      leavetype_id,
                                      leavetype_qty),
                                );
                              }).toList();
                            }(),

                          const SizedBox(height: 16),

                          // 4. Nomor Kontak
                          _buildFormLabel('Nomor Kontak'),
                          _buildInputField(
                            controller: _nomorKontakController,
                            hintText: 'Masukkan nomor kontak aktif',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          // 5. Alamat
                          _buildFormLabel('Alamat Kontak'),
                          _buildTextAreaField(
                              controller: _alamatKontakController,
                              hintText: 'Masukkan Alamat Kontak',
                              maxLines: 2),
                        ],
                      ),
                    ),
                    // const SizedBox(height: 20),

                    const SizedBox(height: 16),

                    // ==================== CARD 3: ALUR PERSETUJUAN ====================
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
                    //             color: AppColors.accent, // #fd8a02 - Orange
                    //             size: 20,
                    //           ),
                    //           SizedBox(width: 10),
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

                    //       // Stepper 1: Atasan Langsung (Sedang Berjalan - Orange)
                    //       _buildCutiTimelineTile(
                    //         title: 'Atasan Langsung',
                    //         subtitle: 'Menunggu persetujuan',
                    //         statusIcon: Icons.access_time_filled_rounded,
                    //         statusColor: AppColors.accent, // Orange Accent
                    //       ),

                    //       // Stepper 2: Human Resources (Belum Mulai - Abu-abu)
                    //       _buildCutiTimelineTile(
                    //         title: 'Human Resources',
                    //         subtitle: 'Menunggu tahap sebelumnya',
                    //         statusIcon: Icons.access_time_filled_rounded,
                    //         statusColor:
                    //             const Color(0xFF94A3B8), // Abu-abu teduh
                    //         isLast: true,
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 24),

                    // ==================== TOMBOL UTAMA: AJUKAN CUTI ====================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_subjekController.text == "") {
                            _showDialog("Subjek Cuti Belum Diisi");
                          } else if (_selectedJenisCutiID == "") {
                            _showDialog("Jenis Cuti belum dipilih");
                          } else if (_alamatKontakController.text == "") {
                            _showDialog("Alamat kontak belum diisi");
                          } else {
                            _showDialogReq(
                                "Anda mengajukan cuti kerja mulai tanggal ${_tanggalawalController.text} s/d ${_tanggalakhirController.text}, \n\n Apakah pengajuan anda sudah benar?");
                          }
                        },
                        icon: const Icon(Icons.check_circle,
                            color: Colors.white, size: 20),
                        label: const Text(
                          'Ajukan Cuti',
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
                      title: 'Riwayat Cuti',
                      iconTitle: Icons.history_toggle_off_rounded,
                      iconColor: AppColors.accent,
                      showSeeAll: true,
                      child: Column(
                        children: [
                          // KONDISI 1: JIKA DATA MASIH LOADING / KOSONG
                          if (datacuti.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    // SizedBox(
                                    //   width: 24,
                                    //   height: 24,
                                    //   child: CircularProgressIndicator(
                                    //     valueColor:
                                    //         AlwaysStoppedAnimation<Color>(
                                    //             AppColors.accent),
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
                              // 2. Ambil maksimal 5 data unik teratas dan petakan ke widget Row
                              return datacuti.take(5).map((item) {
                                String rawDateStart =
                                    item['leave_datestart'] ?? '';
                                String rawDateEnd = item['leave_dateend'] ?? '';
                                String statusText = item['leave_descr'] ?? '';
                                String formattedDateStart = '-';
                                String formattedDateEnd = '-';
                                String formattedDate = '-';
                                String leave_date = item['leave_date'] ?? '';
                                int leave_qty = item['leave_qty'] ?? 0;
                                String leave_descr = item['leave_descr'] ?? '';
                                String leave_nokontak =
                                    item['leave_contact'] ?? '';
                                String leave_alamatkontak =
                                    item['leave_address'] ?? '';
                                String leave_type = item['leavetype_id'] ?? '';
                                int jatahCuti = item['jatah_cuti'] ?? 0;
                                int sisaCuti = item['sisa_cuti'] ?? 0;

                                if (leave_date.isNotEmpty) {
                                  try {
                                    DateTime parsedDate =
                                        DateTime.parse(leave_date);
                                    formattedDate =
                                        DateFormat('dd MMM yyyy', 'id_ID')
                                            .format(parsedDate);
                                  } catch (e) {
                                    formattedDate = leave_date;
                                  }
                                }

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

                                print("rawDateEnd $rawDateEnd");

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
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: _buildAttendanceRow(
                                      dayDate: formattedDateStart +
                                          " - " +
                                          formattedDateEnd,
                                      statusText: statusText,
                                      leave_date: formattedDate,
                                      leave_datestart: formattedDateStart,
                                      leave_dateend: formattedDateEnd,
                                      leave_qty: leave_qty.toString(),
                                      leave_descr: leave_descr,
                                      leave_nokontak: leave_nokontak,
                                      leave_alamatkontak: leave_alamatkontak,
                                      leave_type: leave_type,
                                      jatahCuti: jatahCuti.toString(),
                                      sisaCuti: sisaCuti.toString()),
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
        ));
  }

  // ==================== HELPER WIDGETS ====================
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

  // REUSABLE HELPER: Kustomisasi Radio Button Jenis Cuti Sesuai Gambar Kotak Halus Anda
  Widget _buildRadioJenisCutiTile(String label, String id, int jumlah) {
    final bool isSelected = _selectedJenisCuti == label;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedJenisCutiID = id;
          _selectedJenisCuti = label;
          _selectedJatahCuti = jumlah;
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

  // Helper Widget untuk membuat diagram stepper vertikal alur persetujuan cuti
  Widget _buildCutiTimelineTile({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Garis & Lingkaran Ikon
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor.withAlpha((0.15 * 255).round()),
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 20),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: const Color(0xFFCBD5E1), // Garis vertikal abu-abu halus
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Keterangan Teks Progres Jabatan
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 15,
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
            ],
          ),
        ),
      ],
    );
  }

  // REUSABLE HELPER: Membuat Box Abu-abu Terkunci (Read-Only)
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    bool hasBorderHighlight = false,
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
            color: const Color(0xFFF0F2F6),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: hasBorderHighlight
                  ? const Color(0xFF0F1E4A)
                  : Colors.grey.shade200,
              width: hasBorderHighlight ? 2 : 1,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
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

  Widget _buildAttendanceRow(
      {required String dayDate,
      required String statusText,
      required String leave_date,
      required String leave_datestart,
      required String leave_dateend,
      required String leave_qty,
      required String leave_descr,
      required String leave_nokontak,
      required String leave_alamatkontak,
      required String leave_type,
      required String jatahCuti,
      required String sisaCuti}) {
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
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                print("leave_datestart : " + leave_datestart);
                print("jatahCuti : " + jatahCuti);
                widget.onIndexChanged(15);
                widget.leave_date(leave_date);
                widget.leave_datestart(leave_datestart);
                widget.leave_dateend(leave_dateend);
                widget.leave_qty(leave_qty);
                widget.leave_descr(leave_descr);
                widget.leave_nokontak(leave_nokontak);
                widget.leave_alamatkontak(leave_alamatkontak);
                widget.leave_type(leave_type);
                widget.jatahCuti(jatahCuti);
                widget.sisaCuti(sisaCuti);
              }),
          //onTap: () => _navigateToNote(context, items[position]),
        ),
      ],
    );
  }
}
