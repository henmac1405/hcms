import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'user_session.dart';
import 'package:hcms/database/function_helper.dart';

// Variabel global untuk menyimpan daftar kamera
List<CameraDescription> cameras = [];

class FaceDetectorCameraScreen extends StatefulWidget {
  final String modeAbsen; // Menyimpan info apakah "IN" atau "OUT"
  final String url_api;
  final String token;
  final String type;
  final String apikey;
  final String employee_id;
  final String employee_personalid;
  final String employee_name;
  final String latitude;
  final String longitude;
  final String date_yesterday;
  const FaceDetectorCameraScreen({
    super.key,
    required this.modeAbsen,
    required this.url_api,
    required this.token,
    required this.type,
    required this.apikey,
    required this.employee_id,
    required this.employee_personalid,
    required this.employee_name,
    required this.latitude,
    required this.longitude,
    required this.date_yesterday,
  });

  @override
  State<FaceDetectorCameraScreen> createState() =>
      _FaceDetectorCameraScreenState();
}

class _FaceDetectorCameraScreenState extends State<FaceDetectorCameraScreen> {
  HelperFunction fh = new HelperFunction();
  CameraController? _cameraController;
  late FaceDetector _faceDetector;
  bool _isProcessing = false;
  String _statusText = "Mencari wajah...";
  int _faceCount = 0;
  bool _facefounded = false;
  Color absencolorblue = Colors.blue;
  Color absencolor = Colors.grey;
  bool _isUploading = false;
  File? _capturedImage;

  String strlatitude = "";
  String strlongitude = "";
  Position? _currentPosition;

  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormatnew = DateFormat("HH:mm:ss");
  var imageFormat = DateFormat("yyyyMMddHHmmss");
  DateTime now = DateTime.now();
  var absenceFormat = DateFormat("dd-MM-yyyy");
  var hourFormat = DateFormat("HH:mm");
  String absence_date = "";
  String absence_time = "";
  String absence_image = "";
  String uploadimage_name = "";
  String absence_description = "ONLINE - Absence From Mobile Application";
  String absence_dateend = "";

  @override
  void initState() {
    super.initState();
    _initFaceDetector();
    _initCamera();
    strlatitude = widget.latitude;
    strlongitude = widget.longitude;
  }

  void _initFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) {
      cameras = await availableCameras();
    }

    if (cameras.isEmpty) {
      setState(() {
        _statusText = "Kamera tidak ditemukan.";
      });
      return;
    }

    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      // TAMBAHKAN BARIS INI: Mengatur grup format gambar sesuai OS perangkat
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.yuv420
          : ImageFormatGroup.bgra8888,
    );

    _cameraController!.initialize().then((_) {
      if (!mounted) return;
      _cameraController!.startImageStream((CameraImage image) {
        if (!_isProcessing) {
          _isProcessing = true;
          _processCameraImage(image);
        }
      });
      setState(() {});
    }).catchError((e) {
      print("Kamera error: $e");
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());
    final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;
    final inputImageFormat = Platform.isAndroid
        ? InputImageFormat.nv21
        : (InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.bgra8888);

    final inputMetadata = InputImageMetadata(
      size: imageSize,
      rotation: imageRotation,
      format: inputImageFormat,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage =
        InputImage.fromBytes(bytes: bytes, metadata: inputMetadata);

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      if (mounted) {
        setState(() {
          _faceCount = faces.length;
          if (faces.isEmpty) {
            _statusText = "Wajah tidak terdeteksi";
            _facefounded =
                false; // Sembunyikan tombol jika wajah hilang dari kamera
          } else {
            _statusText = "Wajah Terdeteksi! Silakan tekan tombol di bawah.";
            // _statusText = "Wajah Terdeteksi!\n Suhendra (44 tahun) \n lat : " +
            //     widget.latitude +
            //     " long : " +
            //     widget.longitude;
            _facefounded = true; // Tampilkan tombol "Proses Absen"
          }
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      _isProcessing = false;
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  _getCurrentLocation(File watermarkedFile) async {
    print('_getAddressFromLatLng2');
    setState(() {
      _statusText = "Mendapatkan Lokasi...";
    });
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
      });

      insertabsen(watermarkedFile);
    }).catchError((e) {
      print(e);
      print('_getAddressFromLatLng');
    });
  }

  void insertabsen(File watermarkedFile) {
    now = DateTime.now();
    setState(() {
      _statusText = "Menyimpan data absensi...";
    });
    absence_date = dailyFormat.format(now);
    absence_time = hourFormatnew.format(now);
    absence_image =
        UserSession.employee_id + "_" + imageFormat.format(now) + ".jpg";
    uploadimage_name = UserSession.employee_id + "_" + imageFormat.format(now);
    absence_dateend = absence_date;
    if (widget.type == "outyesterday") {
      absence_date = widget.date_yesterday;
      // absence_time = "23:59:59";
    }
    fh
        .absenceonline_insert_new(
            watermarkedFile,
            uploadimage_name,
            UserSession.database_name,
            UserSession.employee_id,
            UserSession.listcompany_id,
            UserSession.company_id,
            UserSession.office_id,
            UserSession.employee_personalid,
            UserSession.employee_fingerid,
            UserSession.employee_name,
            widget.modeAbsen,
            absence_time,
            absence_date,
            absence_image,
            absence_description,
            UserSession.employee_type,
            "",
            absence_dateend,
            strlongitude,
            strlatitude,
            UserSession.device_info,
            "ANDROID MOBILE APPS",
            widget.apikey,
            widget.token,
            "absen/insertnew",
            UserSession.url_api)
        .then((hasils) async {
      if (hasils == "sukses") {
        // _uploaddioNew(watermarkedFile);
        // fh
        //     .uploadimageabsen(
        //         watermarkedFile, uploadimage_name, "uploadgambar/upload")
        //     .then((hasilfoto) {
        //   if (hasilfoto == "sukses") {
        Navigator.pop(context, true);
        //   } else {
        //     _resetCameraStream();
        //   }
        // });
      } else {
        _showDialog(hasils);
        _resetCameraStream();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(_cameraController!)),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 80,
            left: 20,
            right: 20,
            child: Card(
              color: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign
                      .center, // Perbaikan: Menggunakan TextAlign.center ✅
                ),
              ),
            ),
          ),
          _facefounded
              ? Positioned(
                  bottom: 10,
                  left: 20,
                  right: 20,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      // Mencegah proses ganda jika tombol ditekan berkali-kali secara cepat
                      if (_isUploading) return;

                      if (_facefounded == true && _cameraController != null) {
                        setState(() {
                          _isUploading = true;
                          _statusText =
                              "Sedang mengambil foto dan mengunggah...";
                        });

                        try {
                          // 1. Hentikan aliran kamera sementara
                          await _cameraController?.stopImageStream();

                          // 2. Ambil gambar asli dari lensa kamera
                          XFile capturedFile =
                              await _cameraController!.takePicture();
                          File originalFile = File(capturedFile.path);

                          // 3. Perkecil ukuran memori gambar (Kompresi)
                          setState(() {
                            _statusText = "Mengompresi gambar...";
                          });
                          File? compressedFile =
                              await _compressImage(originalFile);
                          File fileToProcess = compressedFile ?? originalFile;

                          // 4. JALANKAN PROSES WATERMARK (Menanam teks absensi pada biner foto)
                          setState(() {
                            _statusText = "Menambahkan watermark...";
                          });
                          File watermarkedFile =
                              await _addWatermark(fileToProcess);

                          // setState(() {
                          //   _statusText = "Mengunggah data absensi...";
                          // });

                          // 5. Kirim file yang sudah dikompresi dan diberi watermark ke API Anda
                          _getCurrentLocation(watermarkedFile);
                          // _uploaddioNew(watermarkedFile);
                          // Navigator.pop(context, true);
                        } catch (e) {
                          print("Gagal memproses jepretan tombol: $e");
                          _resetCameraStream(); // Pulihkan kamera jika gagal menjepret
                        }
                      }
                    },
                    // child: Text(_isUploading
                    //     ? "Mengunggah..."
                    //     : "Proses Absen ${widget.modeAbsen}"),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 50),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  // PERBAIKAN: Menerima parameter objek File dari jepretan kamera langsung
  Future<void> _uploaddioNew(File imageFile) async {
    setState(() {
      _statusText = "mengupload Foto...";
    });
    String imageuploadname = "";
    String imagePath = imageFile.path;
    // String _url_api = "http://172.16.5.138/api-ci3/index.php/api/v1/";

    print('imagePath hasil jepretan kamera: $imagePath');
    print(UserSession.url_api + "uploadgambar/upload");

    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = (timeZoneOffset.isNegative ? '-' : '+') +
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:' +
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormatnew.format(now) +
        formattedOffset;

    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var dio = Dio();
    String fileName = imagePath.split('/').last;
    imageuploadname = widget.employee_id + "_" + imageFormat.format(now);
    print("imageuploadname : $imageuploadname");

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: MediaType("image", "jpeg"),
      ),
      "filename": imageuploadname
    });

    try {
      // 1. Eksekusi API Post di dalam blok try
      var response = await dio.post(
        UserSession.url_api + "uploadgambar/upload",
        data: formData,
        options: Options(
          headers: {
            "APIKEY": widget.apikey,
            "TIMESTAMP": strTIMESTAMP,
            "TOKEN": widget.token,
            'authorization': basicAuth
          },
        ),
        onSendProgress: (int sent, int total) {
          debugPrint("sent $sent total $total");
        },
      );

      // 2. LOGIKA JIKA SUKSES: Cetak response server dan pindah halaman
      debugPrint("Upload sukses: ${response.data}");

      if (mounted) {
        Navigator.pop(context, true); // Kembali hanya jika sukses upload
      }
    } catch (onError) {
      // 3. LOGIKA JIKA GAGAL: Menangkap semua error koneksi/server secara aman
      debugPrint("error:${onError.toString()}");

      _resetCameraStream(); // Nyalakan ulang deteksi/kamera jika API error

      // Tampilkan pesan error ke karyawan agar mereka tahu upload gagal
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengunggah foto absensi. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // 4. LOGIKA BLOK YANG PASTI BERJALAN (Sama seperti whenComplete)
      debugPrint("complete:");
      if (mounted) {
        setState(() {
          _isUploading = false; // Selalu buka kunci loading di akhir proses
        });
      }
    }
  }

  void _resetCameraStream() {
    setState(() {
      _isUploading = false;
      _statusText = "Mencoba mendeteksi wajah kembali...";
    });

    // Hidupkan ulang aliran frame kamera
    _cameraController!.startImageStream((CameraImage image) {
      if (!_isProcessing) {
        _isProcessing = true;
        _processCameraImage(image);
      }
    });
  }

  Future<File?> _compressImage(File file) async {
    // Menentukan lokasi dan nama file target kompresi (.jpg)
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

  Future<File> _addWatermark(File file) async {
    // 1. Baca byte dari file gambar asal
    final bytes = await file.readAsBytes();

    // 2. Decode biner gambar menjadi objek Image
    img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage == null) return file;
    DateTime now = DateTime.now();
    // --- WATERMARK 1: POJOK KIRI ATAS ---
    //  String timeString = DateTime.now().toLocal().toString().substring(0, 19);
    String formattedDate =
        DateFormat('EEEE, d MMMM yyyy HH:mm:ss', 'id_ID').format(now);
    String timeString = "$formattedDate";

    String watermarkTopText = "Absen Online - Android Mobile Apps \n" +
        widget.employee_personalid +
        " - " +
        widget.employee_name +
        "\n" +
        timeString +
        "\n" +
        "Lat : " +
        strlatitude +
        ", Long : " +
        strlongitude;

    // Efek bayangan hitam untuk teks atas
    img.drawString(
        originalImage,
        font: img.arial14,
        x: 32,
        y: 42,
        watermarkTopText,
        color: img.ColorRgb8(0, 0, 0));
    // Teks utama putih untuk teks atas
    img.drawString(
        originalImage,
        font: img.arial14,
        x: 30,
        y: 40,
        watermarkTopText,
        color: img.ColorRgb8(255, 255, 255));

    // --- WATERMARK 2: BAWAH TENGAH ---
    String watermarkBottomText =
        "Transentertainment     Transentertainment     Transentertainment ";

// 1. PERBAIKAN: Gunakan angka 8 (rata-rata lebar font arial14), bukan 26!
    int textWidth = watermarkBottomText.length * 8;

// 2. Kalkulasi titik tengah X yang akurat
    int centerX = (originalImage.width ~/ 2) - (textWidth ~/ 2);

// Jika hasil centerX minus karena teks terlalu panjang, paksa mulai dari margin kiri 20 piksel agar tidak hilang
    if (centerX < 0) {
      centerX = 20;
    }

// Menentukan posisi Y (Tinggi gambar dikurangi 180 piksel)
    int bottomY = originalImage.height - 30;

// 3. PERBAIKAN: Aktifkan bayangan hitam agar teks putih terlihat jelas di latar terang
    img.drawString(
        originalImage,
        font: img.arial14,
        x: centerX + 1, // Bayangan cukup geser 1 piksel untuk font kecil
        y: bottomY + 1,
        watermarkBottomText,
        color: img.ColorRgb8(0, 0, 0));

// Teks utama putih
    img.drawString(
        originalImage,
        font: img.arial14,
        x: centerX,
        y: bottomY,
        watermarkBottomText,
        color: img.ColorRgb8(255, 255, 255));

    // 3. Encode kembali objek gambar menjadi format JPG biner
    final watermarkedBytes = img.encodeJpg(originalImage, quality: 90);

    // 4. Simpan byte baru ke file target baru
    final watermarkedPath = file.path.replaceAll('.jpg', '_watermarked.jpg');
    File watermarkedFile = File(watermarkedPath);
    await watermarkedFile.writeAsBytes(watermarkedBytes);

    return watermarkedFile;
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
              _resetCameraStream();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
