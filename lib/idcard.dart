import 'package:flutter/material.dart';
import 'user_session.dart';

class IdCardPage extends StatelessWidget {
  final String namaKaryawan;
  final String jabatanKaryawan;
  final String fotoUrl;

  const IdCardPage({
    Key? key,
    required this.namaKaryawan,
    required this.jabatanKaryawan,
    required this.fotoUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFE0E0E0), // Latar belakang abu-abu di luar ID Card
      // appBar: AppBar(
      //   title: const Text('ID Card Karyawan'),
      //   backgroundColor: const Color(0xFF0052D4),
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      // ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Mengatur ukuran proporsional ID Card mengikuti aspek rasio gambar template Anda (1:1.66)
            double cardWidth = 330;
            double cardHeight = 550;

            return Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
                // 1. GAMBAR TEMPLATE BARU SEBAGAI BACKGROUND UTAMA
                image: DecorationImage(
                  image: AssetImage(
                    "assets/${UserSession.image_idcard}",
                  ), // Pastikan file gambar ini sudah didaftarkan di pubspec.yaml
                  fit: BoxFit.fill,
                ),
              ),
              child: Stack(
                children: [
                  // 2. FOTO KARYAWAN (Ditempatkan pas di dalam kotak putih atas)
                  Positioned(
                    top: cardHeight *
                        0.21, // Mulai tepat di bawah logo Trans Entertainment
                    left: cardWidth * 0.20,
                    right: cardWidth * 0.20,
                    bottom: cardHeight *
                        0.31, // Berhenti sebelum batas melengkung putih bawah
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          "${UserSession.profile_image_url}?t=${DateTime.now().millisecondsSinceEpoch}",
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // 3. NAMA KARYAWAN (Diposisikan tepat di atas garis hitam tipis template)
                  Positioned(
                    bottom: cardHeight * 0.20,
                    left: cardWidth * 0.08,
                    right: cardWidth * 0.08,
                    child: Text(
                      UserSession.employee_name.toUpperCase(),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.blue, // Warna biru dongker gelap kontras
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // 4. JABATAN KARYAWAN (Diposisikan di bawah garis hitam tipis template)
                  Positioned(
                    bottom: cardHeight * 0.12,
                    left: cardWidth * 0.08,
                    right: cardWidth * 0.08,
                    child: Text(
                      UserSession.position_name,
                      // "PURCHASING",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),

                  // NIK.
                  Positioned(
                    bottom: cardHeight * 0.07,
                    left: cardWidth * 0.08,
                    right: cardWidth * 0.08,
                    child: Text(
                      UserSession.employee_personalid,
                      // "PURCHASING",
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
