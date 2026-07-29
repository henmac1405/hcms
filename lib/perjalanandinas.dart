import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'user_session.dart';

class PerjalananDinasPage extends StatefulWidget {
  const PerjalananDinasPage({super.key});

  @override
  State<PerjalananDinasPage> createState() => _PerjalananDinasPageState();
}

class _PerjalananDinasPageState extends State<PerjalananDinasPage> {
  // Controller untuk field dinamis
  final _subjekController = TextEditingController(text: '');
  final _allowanceController = TextEditingController(text: '0');
  final _tujuanController = TextEditingController(text: '');
  final _tglBerangkatController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _tglKembaliController =
      TextEditingController(text: _getFormattedTodayStatic());

  // State untuk Akomodasi
  bool _isHotelSelected = true;
  bool _isBoardingHouseSelected = false;
  bool isLoading = false;
  // State untuk Transportasi (Hanya satu yang bisa dipilih / Radio Style)
  String _selectedTransport = 'Pesawat';

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day-$month-${now.year}";
  }

  @override
  void dispose() {
    _subjekController.dispose();
    _allowanceController.dispose();
    _tujuanController.dispose();
    _tglBerangkatController.dispose();
    _tglKembaliController.dispose();
    super.dispose();
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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF4F6FA),

        // ==================== APP BAR ====================
        // appBar: AppBar(
        //   backgroundColor: AppColors.primary, // Navy (#001668)
        //   elevation: 0,
        //   automaticallyImplyLeading: false,
        //   centerTitle: true,
        //   title: const Text(
        //     'Perjalanan Dinas',
        //     style: TextStyle(
        //         color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
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
                            'PERJALANAN DINAS',
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==================== CARD 1: DETAIL PERJALANAN DINAS ====================
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
                          Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.business_center,
                                    color: Colors.white, size: 11),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Detail Perjalanan Dinas',
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
                              hintText: 'Masukkan subjek',
                              maxLines: 2),
                          const SizedBox(height: 16),

                          // Input Allowance
                          _buildFormLabel('Allowance (IDR)'),
                          _buildInputField(
                              controller: _allowanceController,
                              hintText: '0',
                              keyboardType: TextInputType.number),
                          const SizedBox(height: 16),

                          // SECTION: AKOMODASI (Checkbox)
                          _buildFormLabel('Akomodasi'),
                          _buildCheckboxTile(
                            label: 'Hotel',
                            isSelected: _isHotelSelected,
                            onTap: () => setState(
                                () => _isHotelSelected = !_isHotelSelected),
                          ),
                          const SizedBox(height: 8),
                          _buildCheckboxTile(
                            label: 'Boarding House',
                            isSelected: _isBoardingHouseSelected,
                            onTap: () => setState(() =>
                                _isBoardingHouseSelected =
                                    !_isBoardingHouseSelected),
                          ),
                          const SizedBox(height: 16),

                          // SECTION: TRANSPORTASI (List Item)
                          _buildFormLabel('Transportasi'),
                          _buildTransportRow(
                              icon: Icons.flight_takeoff_rounded,
                              name: 'Pesawat'),
                          const SizedBox(height: 12),
                          _buildTransportRow(
                              icon: Icons.train_rounded, name: 'Kereta'),
                          const SizedBox(height: 12),
                          _buildTransportRow(
                              icon: Icons.directions_bus_rounded, name: 'Bus'),
                          const SizedBox(height: 12),
                          _buildTransportRow(
                              icon: Icons.directions_car_rounded,
                              name: 'Mobil'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==================== CARD 2: TUJUAN ====================
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
                                decoration: BoxDecoration(
                                    color: AppColors.accent,
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Icon(Icons.calendar_month,
                                    color: Colors.white, size: 11),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Tujuan',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildFormLabel('Kota Tujuan'),
                          _buildInputField(
                              controller: _tujuanController,
                              hintText: 'Masukkan kota tujuan'),
                          const SizedBox(height: 16),

                          // Field Tanggal Berangkat
                          _buildFormLabel('Tgl Berangkat'),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, _tglBerangkatController),
                            child: AbsorbPointer(
                              // Memastikan keyboard bawaan HP tidak ikut muncul
                              child: _buildDropdownInputField(
                                controller: _tglBerangkatController,
                                hintText: 'Pilih tanggal berangkat',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Field Tanggal Kembali
                          _buildFormLabel('Tgl Kembali'),
                          GestureDetector(
                            onTap: () =>
                                _selectDate(context, _tglKembaliController),
                            child: AbsorbPointer(
                              // Memastikan keyboard bawaan HP tidak ikut muncul
                              child: _buildDropdownInputField(
                                controller: _tglKembaliController,
                                hintText: 'Pilih tanggal kembali',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ==================== CARD 3: ALUR PERSETUJUAN ====================
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
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.accent, size: 20),
                              const SizedBox(width: 10),
                              const Text(
                                'Alur Persetujuan',
                                style: TextStyle(
                                    color: Color(0xFF0F1E4A),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Stepper 1: Atasan Langsung (Selesai/Disetujui - Hijau)
                          _buildTimelineTile(
                            title: 'Atasan Langsung',
                            subtitle: 'Disetujui · 1 Jul 2026, 10.12',
                            statusIcon: Icons.check_circle,
                            statusColor: const Color(0xFF2ECC71),
                            isFirst: true,
                          ),

                          // Stepper 2: Human Resources (Sedang Berjalan - Orange)
                          _buildTimelineTile(
                            title: 'Human Resources',
                            subtitle: 'Menunggu persetujuan',
                            statusIcon: Icons.access_time_filled_rounded,
                            statusColor: AppColors.accent,
                          ),
                          _buildTimelineTile(
                            title: 'Board of Directors',
                            subtitle: 'Menunggu tahap sebelumnya',
                            statusIcon: Icons.access_time_filled_rounded,
                            statusColor: const Color(0xFF94A3B8),
                            isLast: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ==================== TOMBOL UTAMA AJUKAN ====================
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Masukkan aksi submit form pengajuan di sini
                        },
                        icon: const Icon(Icons.check_circle,
                            color: Colors.white, size: 20),
                        label: const Text(
                          'Ajukan Perjalanan Dinas',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent, // Orange Accent
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // ==================== KELOMPOK MENU: RIWAYAT KEHADIRAN ====================
                    // ==================== KELOMPOK MENU: RIWAYAT KEHADIRAN ====================
                    _buildSectionCard(
                      title: 'Riwayat Perjalanan Dinas',
                      iconTitle: Icons.history_toggle_off_rounded,
                      iconColor: AppColors.accent,
                      showSeeAll: true,
                      child: Column(
                        children: [
                          // KONDISI 1: JIKA DATA MASIH LOADING / KOSONG (Hapus kata 'const' di depan Padding)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0),
                            child: Center(
                              child: Column(
                                children: [
                                  // Langsung isi dengan teks string mentah agar tidak memicu error missing variable
                                  _buildAttendanceRow(
                                    dayDate: '10 Juli 2026',
                                    statusText: 'Opening Fozenland Sampit',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAttendanceRow(
                                    dayDate: '5 Juli 2026',
                                    statusText: 'Opening Frozenland Kupang',
                                  ),
                                  const SizedBox(height: 10),
                                  _buildAttendanceRow(
                                    dayDate: '1 Juli 2026',
                                    statusText: 'Opening Frozenland Padang',
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  // HELPER: Input Field Aktif Standar
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

  // HELPER: Custom Checkbox
  Widget _buildCheckboxTile(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            isSelected
                ? Icons.check_box_rounded
                : Icons.check_box_outline_blank_rounded,
            color: isSelected ? const Color(0xFF001F82) : Colors.grey.shade400,
            size: 24,
          ),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // HELPER: Baris Pilihan Transportasi
  Widget _buildTransportRow({required IconData icon, required String name}) {
    final bool isCurrentSelected = _selectedTransport == name;
    return InkWell(
      onTap: () => setState(() => _selectedTransport = name),
      borderRadius: BorderRadius.circular(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCurrentSelected
                      ? const Color(0xFF001F82)
                      : const Color(0xFF7A869A).withAlpha((0.6 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Text(name,
                  style: const TextStyle(
                      color: Color(0xFF0F1E4A),
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          Icon(
            isCurrentSelected
                ? Icons.check_circle_rounded
                : Icons.radio_button_off_rounded,
            color: isCurrentSelected
                ? const Color(0xFF001F82)
                : Colors.grey.shade300,
            size: 24,
          ),
        ],
      ),
    );
  }

  // HELPER: Custom Stepper Timeline Vertikal untuk Alur Persetujuan
  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Komponen Grafis Garis & Lingkaran Timeline
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
                color: const Color(
                    0xFFCBD5E1), // Garis vertikal abu-abu halus pembungkus alur
              ),
          ],
        ),
        const SizedBox(width: 16),
        // Komponen Teks Keterangan Progres
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
      padding: const EdgeInsets.all(15),
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
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
          trailing: IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          //onTap: () => _navigateToNote(context, items[position]),
        ),
      ],
    );
  }
}
