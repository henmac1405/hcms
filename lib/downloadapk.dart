import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'app_colors.dart';
import 'package:hcms/database/function_helper.dart';

class DownloadAPKPage extends StatefulWidget {
  final String url_api;
  final String apikey;
  final String token;
  const DownloadAPKPage({
    super.key,
    required this.url_api,
    required this.apikey,
    required this.token,
  });

  @override
  State<DownloadAPKPage> createState() => _DownloadAPKPageState();
}

class _DownloadAPKPageState extends State<DownloadAPKPage>
    with SingleTickerProviderStateMixin {
  String _url = "";
  HelperFunction fh = new HelperFunction();

  bool _isDownloading = false;
  bool _isCompleted = false;
  double _progress = 0.0;
  String _statusMessage = "Siap untuk mengunduh pembaruan APK : ";
  String _localPath = "";
  String _version_id = "";
  bool isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    getmastersetting();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _isCompleted = false;
      _progress = 0.0;
      _statusMessage = "Menghubungkan ke server...";
    });

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      _localPath = "${directory!.path}/absence-te-hcm.apk";

      Dio dio = Dio();
      await dio.download(
        _url,
        _localPath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _progress = received / total;
              _statusMessage =
                  "Mengunduh: ${(_progress * 100).toStringAsFixed(0)}%";
            });
          }
        },
      );

      setState(() {
        _isDownloading = false;
        _isCompleted = true;
        _statusMessage = "Unduhan Selesai! Siap Pasang.";
      });

      _openAPK();
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = "Gagal mengunduh: Pastikan internet Anda stabil.";
      });
    }
  }

  Future<void> _openAPK() async {
    if (_localPath.isNotEmpty) {
      final result = await OpenFilex.open(_localPath);
      if (result.type != ResultType.done) {
        setState(() {
          _statusMessage = "Gagal membuka file. Buka manual di File Manajer.";
        });
      }
    }
  }

  void getmastersetting() {
    setState(() {
      isLoading = true;
    });
    fh.Setting("APK_download_url", widget.apikey, widget.token, "setting/show",
            widget.url_api)
        .then((resultversion) {
      if (resultversion.isNotEmpty) {
        resultversion.forEach((value) {
          setState(() {
            _url = value['setting_value'] ?? "";
            _statusMessage = _statusMessage + "\n" + _url;
          });
        });
        fh.Setting("apk_version", widget.apikey, widget.token, "setting/show",
                widget.url_api)
            .then((resultversion) {
          setState(() {
            isLoading = false;
          });
          if (resultversion.isNotEmpty) {
            resultversion.forEach((value) {
              setState(() {
                _version_id = value['setting_value'] ?? "";
              });
            });
          } else {
            _version_id = "XXX";
          }
        });
      } else {
        _url = "";
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Estetik
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  Color(0xff203a43),
                  Color(0xff2c5364)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Konten Utama (Berada di tengah)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withAlpha(50)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        height: 80.0,
                        child: Image.asset("assets/logote.png",
                            fit: BoxFit.contain),
                      ),
                    ),
                    isLoading
                        ? const Center(
                            child: LinearProgressIndicator(),
                          )
                        : Container(),
                    const SizedBox(height: 24),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _isCompleted ? Colors.white : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isCompleted
                            ? Icons.check_circle_outline
                            : Icons.system_update_alt_rounded,
                        size: 64,
                        color:
                            _isCompleted ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Pembaruan Aplikasi HCM versi " + _version_id,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_isDownloading) ...[
                      SizedBox(
                        height: 12,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white.withAlpha(30),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.blueAccent),
                          ),
                        ),
                      ),
                    ] else if (_isCompleted) ...[
                      ElevatedButton.icon(
                        onPressed: _openAPK,
                        icon: const Icon(Icons.install_mobile),
                        label: const Text("Pasang APK Sekarang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ] else ...[
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: _startDownload,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 18),
                            elevation: 8,
                            shadowColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.file_download_outlined),
                              SizedBox(width: 8),
                              Text("Unduh Sekarang",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Tombol Tutup di Pojok Kanan Atas (Aman dari Notches/Status Bar)
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipOval(
                  child: Material(
                    color: Colors.white.withAlpha(30), // Efek transparan senada
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      tooltip: "Tutup",
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
