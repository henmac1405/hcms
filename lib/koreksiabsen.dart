import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'user_session.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class KoreksiAbsenPage extends StatefulWidget {
  const KoreksiAbsenPage({super.key});

  @override
  State<KoreksiAbsenPage> createState() => _KoreksiAbsenPageState();
}

class _KoreksiAbsenPageState extends State<KoreksiAbsenPage> {
  // Controller untuk menangani isian input teks dinamis
  final _subjekController = TextEditingController(text: '');
  final _tanggalKoreksiController =
      TextEditingController(text: _getFormattedTodayStatic());
  final _deskripsiController = TextEditingController();

  // State untuk melacak pilihan Jenis Koreksi (Checkbox style)
  bool _isCheckInKoreksi = true;
  bool _isCheckOutKoreksi = false;

  // Variabel state untuk menyimpan file dokumen yang diunggah
  File? _lampiranUtama;
  File? _buktiFoto;
  File? _dokumenLain;

  final ImagePicker _imagePicker = ImagePicker();

  static String _getFormattedTodayStatic() {
    final DateTime now = DateTime.now();
    String day = now.day.toString().padLeft(2, '0');
    String month = now.month.toString().padLeft(2, '0');
    return "$day/$month/${now.year}";
  }

  // Fungsi inti untuk memproses pengambilan gambar dari Kamera/Galeri
  Future<void> _pickDocument(ImageSource source, String type) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80, // Kompres kualitas gambar ke 80%
      );

      if (pickedFile != null) {
        setState(() {
          if (type == 'lampiran') {
            _lampiranUtama = File(pickedFile.path);
          } else if (type == 'bukti') {
            _buktiFoto = File(pickedFile.path);
          } else if (type == 'lain') {
            _dokumenLain = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil berkas: $e");
    }
  }

  // Jendela Opsi Pilihan Kamera/Galeri yang Melayang
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

  @override
  void dispose() {
    _subjekController.dispose();
    _tanggalKoreksiController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan Date Picker Kalender bawaan Flutter
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          DateTime(2026, 6, 30), // Diselaraskan dengan tanggal pada gambar Anda
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
        _tanggalKoreksiController.text = "$day/$month/$year";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            SizedBox(width: 12),
            Text(
              'Koreksi Absensi',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
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
                    const SizedBox(height: 16),

                    // Field Saldo PH sesuai gambar referensi Anda
                    _buildReadOnlyField(
                      label: 'Saldo PH',
                      value: '3 hari',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== CARD 2: DETAIL KOREKSI (DIPERBARUI) ====================
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
                    // Header Section Detail Koreksi
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        const Text(
                          'Detail Koreksi',
                          style: TextStyle(
                              color: Color(0xFF0F1E4A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 1. Subjek
                    _buildFormLabel('Subjek'),
                    _buildInputField(
                        controller: _subjekController,
                        hintText: 'Masukkan subjek alasan'),
                    const SizedBox(height: 16),

                    // 2. Tanggal (Kalender Klik)
                    _buildFormLabel('Tanggal'),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: _buildDropdownInputField(
                            controller: _tanggalKoreksiController,
                            hintText: 'Pilih tanggal'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Jenis Koreksi (Checkbox Row List)
                    _buildFormLabel('Jenis Koreksi'),
                    _buildCheckboxJenisKoreksi(
                      label: 'Koreksi Check-In',
                      isSelected: _isCheckInKoreksi,
                      onTap: () => setState(
                          () => _isCheckInKoreksi = !_isCheckInKoreksi),
                    ),
                    _buildCheckboxJenisKoreksi(
                      label: 'Koreksi Check-Out',
                      isSelected: _isCheckOutKoreksi,
                      onTap: () => setState(
                          () => _isCheckOutKoreksi = !_isCheckOutKoreksi),
                    ),
                    const SizedBox(height: 16),

                    // 4. Lampiran Gambar (Upload Box Dashed Border)
                    _buildFormLabel('Lampiran Gambar'),
                    _buildUploadBox(
                      label: _lampiranUtama != null
                          ? 'Foto Lampiran Terunggah (Ketuk untuk ubah)'
                          : 'Unggah Bukti / Foto',
                      isUploaded: _lampiranUtama != null,
                      onTap: () =>
                          _showSourceSelectionPopup(context, 'lampiran'),
                      isCameraStyle: true,
                    ),
                    const SizedBox(height: 16),

                    // 5. Deskripsi (Multi-line Input Field)
                    _buildFormLabel('Deskripsi'),
                    _buildMultiLineInputField(
                      controller: _deskripsiController,
                      hintText: 'Jelaskan detail kejadian secara lengkap...',
                    ),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Icon(Icons.description,
                              color: Colors.white, size: 11),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Dokumen Pendukung',
                          style: TextStyle(
                              color: Color(0xFF0F1E4A),
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24), // Kotak Unggah Foto Bukti
                    _buildUploadBox(
                      label: _buktiFoto != null
                          ? 'Foto Bukti Terunggah (Ketuk untuk ubah)'
                          : 'Unggah Foto Bukti',
                      isUploaded: _buktiFoto != null,
                      onTap: () => _showSourceSelectionPopup(context, 'bukti'),
                    ),
                    const SizedBox(height: 16), // Kotak Unggah Dokumen Lainnya
                    _buildUploadBox(
                      label: _dokumenLain != null
                          ? 'Dokumen Lain Terunggah (Ketuk untuk ubah)'
                          : 'Unggah Dokumen Lainnya',
                      isUploaded: _dokumenLain != null,
                      onTap: () => _showSourceSelectionPopup(context, 'lain'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================== CARD 4: ALUR PERSETUJUAN ====================
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
                    // Header Alur Persetujuan Centang Oranye
                    const Row(
                      children: [
                        Icon(Icons.check_circle_rounded,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Alur Persetujuan',
                          style: TextStyle(
                            color: Color(0xFF0F1E4A),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stepper 1: Atasan Langsung (Menunggu Persetujuan - Orange)
                    _buildKoreksiTimelineTile(
                      title: 'Atasan Langsung',
                      subtitle: 'Menunggu persetujuan',
                      statusIcon: Icons.access_time_filled_rounded,
                      statusColor: AppColors.accent,
                    ),

                    // Stepper 2: Human Resources (Belum Mulai - Abu-abu)
                    _buildKoreksiTimelineTile(
                      title: 'Human Resources',
                      subtitle: 'Dapat melihat lampiran gambar',
                      statusIcon: Icons.access_time_filled_rounded,
                      statusColor: const Color(0xFF94A3B8),
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ==================== TOMBOL UTAMA: AJUKAN KOREKSI ====================
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Masukkan logika integrasi kirim form koreksi absen ke backend API
                  },
                  icon: const Icon(Icons.check_circle,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Ajukan Koreksi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        AppColors.accent, // Orange Accent (#fd8a02)
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HELPER METODE WIDGET INTERFACES ====================
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

  Widget _buildInputField(
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

  // REUSABLE HELPER: Komponen Seleksi Checkbox Jenis Koreksi Sesuai Gambar
  Widget _buildCheckboxJenisKoreksi(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
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
            Text(
              label,
              style: const TextStyle(
                  color: Color(0xFF0F1E4A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // REUSABLE HELPER: Kotak Box Unggah Bukti dengan Ikon Kamera Biru Tua Tengah
  Widget _buildUploadAttachmentBox(
      {required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFBFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7A869A).withAlpha((0.4 * 255).round()),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.camera_alt_rounded,
              color: Color(0xFF001F82), // Navy Blue dominan sesuai gambar
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

// REUSABLE HELPER: Input Teks Deskripsi Area Multi-Baris (Tinggi Fleksibel)
  Widget _buildMultiLineInputField(
      {required TextEditingController controller, required String hintText}) {
    return TextField(
      controller: controller,
      maxLines: 4, // Membuat input meluas ke bawah menampung deskripsi panjang
      style: const TextStyle(
          fontSize: 15, color: Color(0xFF0F1E4A), fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
            fontWeight: FontWeight.w400),
        contentPadding: const EdgeInsets.all(16),
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

  // REUSABLE HELPER: Membuat Kotak Unggah Berkas Dinamis dengan Parameter Valid
  Widget _buildUploadBox({
    required String label,
    required bool isUploaded,
    required VoidCallback onTap,
    bool isCameraStyle =
        false, // Menambahkan opsi tipe icon kamera khusus lampiran utama
  }) {
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
            Icon(
              isUploaded
                  ? Icons.check_circle_rounded
                  : (isCameraStyle
                      ? Icons.camera_alt_rounded
                      : Icons.upload_rounded),
              color: isUploaded
                  ? const Color(0xFF2ECC71)
                  : const Color(0xFF001F82),
              size: 26,
            ),
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

  // REUSABLE HELPER: Membuat Baris Timeline Alur Persetujuan Vertikal
  Widget _buildKoreksiTimelineTile({
    required String title,
    required String subtitle,
    required IconData statusIcon,
    required Color statusColor,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indikator Lingkaran Solid dan Garis Hubung Vertikal
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
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
        // Keterangan Judul Jabatan & Subtitle Detail Aksi Status
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
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
