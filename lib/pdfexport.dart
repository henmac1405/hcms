import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'user_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfParamScreen extends StatefulWidget {
  final ValueChanged<int> onIndexChanged;
  final String leave_date;
  final String leave_datestart;
  final String leave_dateend;
  final String leave_qty;
  final String leave_descr;
  final String leave_nokontak;
  final String leave_alamatkontak;
  final String leave_type;
  final String jatahCuti;
  final String sisaCuti;
  const PdfParamScreen({
    Key? key,
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
  }) : super(key: key);
  @override
  State<PdfParamScreen> createState() => _PdfParamScreen();
}

class _PdfParamScreen extends State<PdfParamScreen> {
  static Future<Uint8List> generateFormCuti({
    required String namaLengkap,
    required String nik,
    required String jabatan,
    required String departemen,
    required String lokasiKerja,
    required String
        jenisCuti, // 'Pengganti Hari', 'Cuti Tahunan', atau 'Cuti Khusus'
    required String tanggalMulai,
    required String tanggalSelesai,
    required String detailCutiKhusus, // misal: 'a. Pernikahan Karyawan'
    required String jatahCuti,
    required String jumlahCuti,
    required String sisaCuti,
    required String catatanKeperluan,
    required String alamatCuti,
    required String nomorTelepon,
    required String tanggalPengajuan,
  }) async {
    final pdf = pw.Document();
    // 1. Ambil data gambar asset dan ubah ke format MemoryImage PDF
    final ByteData imageByte = await rootBundle.load('assets/logote.png');
    final Uint8List imageBytes = imageByte.buffer.asUint8List();
    final pw.MemoryImage logoImage = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // 1. HEADER DOKUMEN
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.SizedBox(
                  height: 50.0,
                  child: pw.Image(
                    logoImage,
                    fit: pw.BoxFit
                        .contain, // Gunakan pw.BoxFit, bukan BoxFit biasa
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Center(
                child: pw.Text(
                  'FORM PERMOHONAN KETIDAKHADIRAN',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      decoration: pw.TextDecoration.underline),
                ),
              ),
              pw.SizedBox(height: 20),

              // 2. DATA DIRI KARYAWAN
              _buildSectionHeader('DATA DIRI KARYAWAN'),
              _buildDataRow('Nama Lengkap', namaLengkap),
              _buildDataRow('Nomor Induk Karyawan', nik),
              _buildDataRow('Jabatan', jabatan),
              _buildDataRow('Department/ Divisi', departemen),
              _buildDataRow('Lokasi Kerja', lokasiKerja),
              pw.SizedBox(height: 15),

              // 3. PERMOHONAN KETIDAKHADIRAN
              _buildSectionHeader('PERMOHONAN KETIDAK HADIRAN'),
              _buildCheckRow('Pengganti Hari', jenisCuti == 'Pengganti Hari',
                  tanggalMulai, tanggalSelesai),
              _buildCheckRow('Cuti Tahunan', jenisCuti == '2', tanggalMulai,
                  tanggalSelesai),

              pw.Row(
                children: [
                  _buildCheckBox(jenisCuti != '2'),
                  pw.SizedBox(width: 8),
                  pw.Text('Cuti Khusus',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 22),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildSubCutiRow('a. Pernikahan Karyawan (3 hari)',
                        jenisCuti == '3', tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow('b. Pernikahan Anak (2 hari)',
                        jenisCuti == '4', tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow('c. Khitanan/ Baptis anak (2 hari)',
                        jenisCuti == '5', tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow('d. Istri melahirkan/ gugur (2 hari)',
                        jenisCuti == '6', tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow(
                        'e. Suami/Istri/Ortu/Mertua/Anak/Menantu Meninggal (2 hari)',
                        jenisCuti == '7',
                        tanggalMulai,
                        tanggalSelesai),
                    _buildSubCutiRow(
                        'f. Anggota keluarga dalam satu rumah Meninggal (1 hari)',
                        jenisCuti == '8',
                        tanggalMulai,
                        tanggalSelesai),
                    _buildSubCutiRow('g. Ibadah haji/ Ibadah', jenisCuti == '9',
                        tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow('h. Karyawan Melahirkan (3 bulan)',
                        jenisCuti == '10', tanggalMulai, tanggalSelesai),
                    _buildSubCutiRow('i. Karyawan Keguguran (1,5 bulan)',
                        jenisCuti == '11', tanggalMulai, tanggalSelesai),
                  ],
                ),
              ),
              pw.SizedBox(height: 15),

              // 4. INFORMASI CUTI & CATATAN KEPERLUAN (SIDE BY SIDE)
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Informasi Cuti',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          _buildInfoCutiRow('Jatah Cuti', '$jatahCuti Hari'),
                          _buildInfoCutiRow('Jumlah Cuti', '$jumlahCuti Hari'),
                          _buildInfoCutiRow('Sisa Cuti', '$sisaCuti Hari'),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Container(
                      height: 66,
                      padding: const pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black)),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Catatan Keperluan:',
                              style:
                                  pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.SizedBox(height: 4),
                          pw.Text(catatanKeperluan),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // ALAMAT DAN KONTAK
              pw.Container(
                decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.black)),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('Alamat selama Cuti : $alamatCuti',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                            'Nomor yang dapat dihubungi : $nomorTelepon',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Text(
                  'Permohonan Ketidakhadiran ini diajukan pada tanggal: $tanggalPengajuan'),
              pw.SizedBox(height: 15),

              // 5. KOLOM TANDA TANGAN (SIGNATURE BLOCK)
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignColumn('Diajukan oleh,', 'Karyawan', namaLengkap),
                  _buildSignColumn('Disetujui oleh,', 'Atasan langsung', ''),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildStatusBox('Disetujui'),
                      _buildStatusBox('Tidak disetujui'),
                      _buildStatusBox('Ditunda s/d .......................'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 15),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildSignColumn(
                      'Disetujui oleh,', 'Direksi/Kepala Department', ''),
                  _buildSignColumn('Diketahui oleh,', 'HRD', ''),
                  pw.SizedBox(width: 120), // Spacer penyeimbang layout
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // --- WIDGET BUILDER HELPER UNTUK PDF ---
  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      decoration: const pw.BoxDecoration(color: PdfColors.grey300),
      child: pw.Text(title,
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
    );
  }

  static pw.Widget _buildDataRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 150,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
          pw.Text(': ', style: const pw.TextStyle(fontSize: 10)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildCheckBox(bool isChecked) {
    return pw.Container(
      width: 12,
      height: 12,
      decoration:
          pw.BoxDecoration(border: pw.Border.all(color: PdfColors.black)),
      child: isChecked
          ? pw.Center(
              child: pw.Text('X',
                  style: pw.TextStyle(
                      fontSize: 8, fontWeight: pw.FontWeight.bold)))
          : null,
    );
  }

  static pw.Widget _buildCheckRow(
      String label, bool isChecked, String from, String to) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          _buildCheckBox(isChecked),
          pw.SizedBox(width: 8),
          pw.SizedBox(
              width: 120,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 10))),
          pw.Text(': Tanggal Pengajuan ',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text(isChecked ? from : '....................',
              style: const pw.TextStyle(fontSize: 10)),
          pw.Text('  s/d  ', style: const pw.TextStyle(fontSize: 10)),
          pw.Text(isChecked ? to : '....................',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  static pw.Widget _buildSubCutiRow(
      String label, bool isChecked, String from, String to) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        children: [
          pw.SizedBox(
              width: 300,
              child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
          pw.Text(isChecked ? from : '....................',
              style: const pw.TextStyle(fontSize: 9)),
          pw.Text('  s/d  ', style: const pw.TextStyle(fontSize: 9)),
          pw.Text(isChecked ? to : '....................',
              style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildInfoCutiRow(String label, String value) {
    return pw.Row(
      children: [
        pw.SizedBox(
            width: 80,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 9))),
        pw.Text(': $value', style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static pw.Widget _buildStatusBox(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          _buildCheckBox(false),
          pw.SizedBox(width: 6),
          pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
        ],
      ),
    );
  }

  static pw.Widget _buildSignColumn(String header, String role, String name) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(header, style: const pw.TextStyle(fontSize: 10)),
        pw.SizedBox(height: 35),
        pw.Text('Nama: $name',
            style: pw.TextStyle(
                fontSize: 10, decoration: pw.TextDecoration.underline)),
        pw.Text('Tgl  :', style: const pw.TextStyle(fontSize: 10)),
        pw.Text(role,
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ],
    );
  }

  Future<void> _shareFormCutiToWhatsApp(Uint8List pdfBytes, String namaKaryawan,
      String tglmulai, String tglakhir) async {
    try {
      // 1. Dapatkan direktori folder sementara di HP
      final tempDir = await getTemporaryDirectory();

      // 2. Buat file fisik PDF sementara dengan nama yang dinamis
      final String fileName =
          'Form_Cuti_${namaKaryawan.replaceAll(' ', '_')}_${tglmulai.replaceAll(' ', '_')}_${tglakhir.replaceAll(' ', '_')}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');

      // 3. Tulis data bytes generator ke dalam file tersebut
      await tempFile.writeAsBytes(pdfBytes);

      // 4. Buka Share Sheet Sistem (Pengguna tinggal pilih icon WhatsApp)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text:
            'Halo, berikut saya lampirkan Form Permohonan Cuti atas nama $namaKaryawan.',
        subject: 'Form Permohonan Cuti - $namaKaryawan',
      );
    } catch (e) {
      debugPrint("Gagal membagikan form cuti: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE0E0E0), // Warna latar abu-abu luar kertas
      body: SafeArea(
        child: Stack(
          children: [
            // 1. KERTAS PDF DI POSISI TENGAH (KEMBALI KE UKURAN SEMULA)
            Center(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: InteractiveViewer(
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: IgnorePointer(
                        ignoring: false,
                        child: PdfPreview(
                          build: (format) => generateFormCuti(
                            namaLengkap: UserSession.employee_name,
                            nik: UserSession.employee_personalid,
                            jabatan: UserSession.position_name,
                            departemen: UserSession.department_name,
                            lokasiKerja: UserSession.office_name,
                            jenisCuti: widget.leave_type,
                            tanggalMulai: widget.leave_datestart,
                            tanggalSelesai: widget.leave_dateend,
                            detailCutiKhusus: "",
                            jatahCuti: widget.jatahCuti,
                            jumlahCuti: widget.leave_qty,
                            sisaCuti: widget.sisaCuti,
                            catatanKeperluan: widget.leave_descr,
                            alamatCuti: widget.leave_alamatkontak,
                            nomorTelepon: widget.leave_nokontak,
                            tanggalPengajuan: widget.leave_date,
                          ),
                          allowPrinting: false,
                          allowSharing: false,
                          canChangePageFormat: false,
                          initialPageFormat: PdfPageFormat.a4,
                          actions: const [],
                          dynamicLayout: false,
                          useActions: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. TOMBOL CLOSE PINDAH KE POJOK KANAN BAWAH
            Positioned(
              bottom: 24, // Jarak dari bawah layar
              right: 24, // Jarak dari kanan layar
              child: CircleAvatar(
                radius:
                    26, // Ukuran tombol sedikit lebih besar agar nyaman ditekan
                backgroundColor: Colors.black
                    .withOpacity(0.65), // Latar belakang lebih kontras
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 26),
                  onPressed: () {
                    // Navigator.of(context).pop();
                    widget.onIndexChanged(6);
                  },
                ),
              ),
            ),
            // 2. TOMBOL SHARE
            Positioned(
              bottom: 24, // Jarak dari bawah layar
              right: 284, // Jarak dari kanan layar
              child: CircleAvatar(
                radius:
                    26, // Ukuran tombol sedikit lebih besar agar nyaman ditekan
                backgroundColor: Colors.black
                    .withOpacity(0.65), // Latar belakang lebih kontras
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 26),
                  onPressed: () async {
                    // 1. Tampilkan loading spinner agar pengguna tahu PDF sedang diproses
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    );

                    try {
                      // 2. Panggil fungsi generator statis Anda untuk mendapatkan Uint8List bytes
                      // Catatan: Ganti 'NamaClassGenerator' sesuai dengan nama class tempat fungsi Anda berada
                      // Ambil nilainya dari variabel screen/widget Anda (contoh: widget.namaLengkap)
                      final Uint8List pdfBytes = await generateFormCuti(
                        namaLengkap: UserSession.employee_name,
                        nik: UserSession.employee_personalid,
                        jabatan: UserSession.position_name,
                        departemen: UserSession.department_name,
                        lokasiKerja: UserSession.office_name,
                        jenisCuti: widget.leave_type,
                        tanggalMulai: widget.leave_datestart,
                        tanggalSelesai: widget.leave_dateend,
                        detailCutiKhusus: "",
                        jatahCuti: widget.jatahCuti,
                        jumlahCuti: widget.leave_qty,
                        sisaCuti: widget.sisaCuti,
                        catatanKeperluan: widget.leave_descr,
                        alamatCuti: widget.leave_alamatkontak,
                        nomorTelepon: widget.leave_nokontak,
                        tanggalPengajuan: widget.leave_date,
                      );

                      // 3. Tutup dialog loading setelah proses generate selesai
                      if (context.mounted) Navigator.pop(context);

                      // 4. Kirim bytes ke fungsi share_plus eksternal yang telah dibuat sebelumnya
                      // Fungsi _shareFormCutiToWhatsApp menerima (Uint8List bytes, String namaKaryawan)
                      await _shareFormCutiToWhatsApp(
                          pdfBytes,
                          UserSession.employee_name,
                          widget.leave_datestart,
                          widget.leave_dateend);
                    } catch (e) {
                      // Tutup loading jika terjadi error saat memproses dokumen
                      if (context.mounted) Navigator.pop(context);
                      debugPrint("Gagal memproses share PDF: $e");
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
