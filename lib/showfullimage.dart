import 'package:flutter/material.dart';

class ShowFullImagePage extends StatelessWidget {
  final ValueChanged<int> onIndexChanged;
  final String imageUrl;
  final int noindex;

  const ShowFullImagePage({
    super.key,
    required this.onIndexChanged,
    required this.imageUrl,
    required this.noindex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Memaksa kolom berukuran sekompres mungkin
      children: [
        // 1. Tombol Close di Atas Kanan Gambar
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 30),
              onPressed: () {
                onIndexChanged(noindex);
              }),
        ),
        const SizedBox(height: 10),

        // 2. 🔑 SOLUSI UTAMA: Bungkus dengan Flexible agar tinggi gambar adaptif dan tidak memicu overflow
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              imageUrl,
              width: MediaQuery.of(context).size.width *
                  0.95, // Lebar gambar 95% layar
              fit: BoxFit
                  .contain, // 🔑 UBAH JADI CONTAIN: Menjaga rasio foto asli agar pas di dalam batas layar tanpa terpotong
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.black54,
                    size: 100,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
