import 'package:flutter/material.dart';

class DialogFullImagePage extends StatefulWidget {
  final List<dynamic> absenceHistoryData;
  final ValueChanged<List<dynamic>> absenceData;
  final ValueChanged<int> onIndexChanged;
  final String titleLabel;
  final String dayDate;
  final String timeLabel;
  final String statusLabel;
  final Color statusColor;
  final Color statusBgColor;
  final String imageurl;
  final int noindex;

  const DialogFullImagePage({
    super.key,
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
    required this.noindex,
  });

  @override
  State<DialogFullImagePage> createState() => _DialogFullImagePageState();
}

class _DialogFullImagePageState extends State<DialogFullImagePage> {
  // Anda bisa mendefinisikan state lokal di sini jika dibutuhkan nantinya
  late String _timestampUrl;
  List<dynamic> dataabsen = [];

  @override
  void initState() {
    super.initState();
    dataabsen = widget.absenceHistoryData;
    // Mengunci timestamp saat halaman pertama kali dibuka agar tidak reload terus-menerus saat setstate
    _timestampUrl =
        "${widget.imageurl}?t=${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: const Color(0xFF0F1E4A),
      child: SafeArea(
        child: Column(
          children: [
            // ==================== HEADER PREVIEW ====================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.titleLabel} - ${widget.timeLabel}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.dayDate,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Tombol Tutup (X) bulat minimalis
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 28),
                    onPressed: () {
                      // SEKARANG SUDAH VALID: Menggunakan kata kunci widget.
                      widget.onIndexChanged(widget.noindex);
                      widget.absenceData(dataabsen);
                      print(dataabsen);
                      // Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            // ==================== AREA FOTO UKURAN PENUH ====================
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF0A1E46),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    _timestampUrl,
                    fit: BoxFit.contain,
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
                              Colors.orange),
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error,
                        StackTrace? stackTrace) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0A1E46), Color(0xFF6A1B9A)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.signal_wifi_connected_no_internet_4_rounded,
                              color: Colors.redAccent,
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
                          color: widget.statusBgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.statusLabel,
                          style: TextStyle(
                            color: widget.statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
  }
}
