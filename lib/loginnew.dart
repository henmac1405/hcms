import 'dart:convert';
import 'dart:io';
import 'dart:math';
// import 'package:hcms/download.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timer_builder/timer_builder.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'app_colors.dart'; // 1. IMPORT FILE WARNA DI SINI
import 'dart:async';
import 'homenew.dart';
import 'uploadphoto.dart';
import 'user_session.dart';
import 'downloadapk.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:hcms/models/nik.dart';
import 'package:device_info/device_info.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MenuNIK {
  final String personalid;
  final String name;

  MenuNIK(this.personalid, this.name);
}

class LoginNewPage extends StatefulWidget {
  final String url_api_part1;
  final String url_api_part2;
  final String url_api_dev_part1;
  final String url_api_image_part1;
  final String url_api_image_part2;
  final String url_api_image_dev_part1;
  final String url_image_profile_part1;
  final String url_image_profile_part2;
  final String url_image_profile_dev_part1;
  final String url_api_slide;
  final String url_api_lokal;
  final String debug;
  const LoginNewPage({
    super.key,
    required this.url_api_part1,
    required this.url_api_part2,
    required this.url_api_dev_part1,
    required this.url_api_image_part1,
    required this.url_api_image_part2,
    required this.url_api_image_dev_part1,
    required this.url_image_profile_part1,
    required this.url_image_profile_part2,
    required this.url_image_profile_dev_part1,
    required this.url_api_slide,
    required this.url_api_lokal,
    required this.debug,
  });

  @override
  State<LoginNewPage> createState() => _LoginNewPageState();
}

class _LoginNewPageState extends State<LoginNewPage> {
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();
  final _usernameController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '05031976');
  // final _passwordController = TextEditingController(text: 'transsnow');
  final TextEditingController _NIKController = TextEditingController();

  bool _obscureText = true;
  bool isLoading = false;
  // Tambahkan dua baris ini untuk kebutuhan slider
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Timer? _autoScrollTimer;
  final int _totalSlides = 3;

  List imageslidePaths = [];
  String _password = "";

  String company_id = "";
  String company_name = "";
  String company_name2 = "";
  String listcompany_id = "";
  String listcompany_remark = "";
  String NIK = "";
  String employee_id = "";
  String employee_name = "ADMIN";
  String employee_personalid = "";
  String employee_fingerid = "";
  String employee_type = "";
  String office_id = "";
  String office_name = "";
  String employee_gender = "";
  String employee_dateofbirth = "";
  String employee_dob = "";
  String divisi_name = "";
  String database_name = "transstudio";
  String device_info = "";
  String shift_id = "1";
  String department_name = "";
  String employee_phone = "";

  String employee_address1 = "";
  String employee_address2 = "";
  String employee_bpjs = "";
  String employee_entrydate = "";
  String employee_joindate = "";
  String employeetype_name = "";
  String employeeeducation_level = "";

  String url_api = "";
  String url_api_dev = "";

  String url_api_prod =
      "https://api-hcm.transentertainment.com/index.php/api/v1/";

  String url_api_root = "";
  String url_api_slide = "";
  String url_api_slide_prod =
      "https://sso.transentertainment.com/assets/upload/slides/";
  String url_api_slide_dev =
      "https://ssodev.transentertainment.com/assets/upload/slides/";
  String url_api_image = "";
  String url_image_dev =
      "https://ssodev.transentertainment.com/assets/upload/absen/";
  String url_image_prod =
      "https://sso.transentertainment.com/assets/upload/absen/";

  String url_image_profile = "";
  // "https://ssodev.transentertainment.com/assets/upload/absen/";
  String url_image_profile_prod =
      "https://sso.transentertainment.com/assets/upload/candidate/photos/";
  // "https://sso.transentertainment.com/assets/upload/absen/";
  String url_image_profile_dev =
      "https://ssodev.transentertainment.com/assets/upload/candidate/photos/";
  // "https://ssodev.transentertainment.com/assets/upload/absen/";

  String url_api_lokal = "";
  String url_image_lokal = "";
  String url_image_profile_lokal = "";
  String str_url_api_lokal = "";
  final TextEditingController _strController = TextEditingController(text: '');
  String _str = "";

  String apikey = "";
  String token = "";
  String _month = "";
  String _year = "";
  String daynow = "";
  String dayyesterday = "";
  // String _type = "";

  var newFormat = DateFormat("dd MMM yyyy");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");
  var yearFormat = DateFormat("yyyy");
  var monthFormat = DateFormat("M");
  var dayFormat = DateFormat("d");
  final dt = new DateTime.now();
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime.now();

  String projectVersion = "1.0.1";
  String _version_id = "";
  List<MenuNIK> menuNIKS = [];

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  String _brand = "";
  String _model = "";
  String debug = "on";
  bool _isSwitched = true;
  // String strdebug = "";

// 1. Deklarasikan variabel _imageFile
  File? _imageFile;
  String profile_image_url = "";

  String strTimeZone = "";
  String dayNameInd = "";
  String formattedDate = "";
  String position_name = "";
  int userlevel = 0;
  String image_idcard = "idcard_ts.png";
  String employeeeducation_name = "";
  String idCard = "";
  List<String> idCardArray = [];

  @override
  void initState() {
    super.initState();
    // 3. JALANKAN TIMER SAAT HALAMAN DIBUAT
    // _startAutoScroll();
    url_api_lokal = widget.url_api_lokal;
    debug = widget.debug;
    if (debug == "on") {
      // Develepment
      url_api = widget.url_api_dev_part1 + widget.url_api_part2;
      url_api_slide = widget.url_api_slide;
      url_api_image =
          widget.url_api_image_dev_part1 + widget.url_api_image_part2;
      url_image_profile =
          widget.url_image_profile_dev_part1 + widget.url_image_profile_part2;
    } else if (debug == "lokal") {
      //Lokal
      url_api = widget.url_api_lokal + widget.url_api_part2;
      url_api_slide = widget.url_api_slide;
      url_api_image = widget.url_api_lokal + widget.url_api_image_part2;
      url_image_profile = widget.url_api_lokal + widget.url_image_profile_part2;
    } else {
      //production
      url_api = widget.url_api_part1 + widget.url_api_part2;
      url_api_slide = widget.url_api_slide;
      url_api_image = widget.url_api_image_part1 + widget.url_api_image_part2;
      url_image_profile =
          widget.url_image_profile_part1 + widget.url_image_profile_part2;
    }

    _strController.text = url_api_lokal;
    strTimeZone = DateTime.now().timeZoneName;
    listcompany();
    listNIK();
    requestPermission();
    locatiopermision();
    initPlatformState().then((result) {
      if (_deviceData.isNotEmpty) {
        _brand = _deviceData['brand'];
        _model = _deviceData['model'];
        device_info = _brand + " - " + _model;
        print(device_info);
      }
    });
    formattedDate = DateFormat('EEEE dd MMM yyyy', 'id_ID').format(now);
    UserSession.clear();
  }

  // 2. Fungsi utama mengonversi URL Network menjadi objek File lokal
  Future<void> loadNetworkImageToOpenFile(String url) async {
    try {
      // Unduh file byte dari internet
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Dapatkan direktori temporary sistem handphone
        final tempDir = await getTemporaryDirectory();

        // Buat nama file tiruan beserta ekstensinya (.jpg / .png)
        final String fileName =
            "profile_downloaded${p.extension(url).isEmpty ? '.jpg' : p.extension(url)}";
        final file = File('${tempDir.path}/$fileName');

        // Tulis data bytes network langsung ke dalam file lokal tersebut
        await file.writeAsBytes(response.bodyBytes);

        // Masukkan file lokal baru tersebut ke dalam variabel _imageFile
        setState(() {
          _imageFile = file;
        });
        print("Sukses mengunduh gambar dari server.");
      } else {
        throw Exception("Gagal mengunduh gambar dari server.");
      }
    } catch (e) {
      debugPrint("Error loading network image: $e");
      print("Error loading network image: $e");
    }
  }

  Future<void> initPlatformState() async {
    late Map<String, dynamic> deviceData;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        print('_deviceData');
        print(_deviceData['id']);
      } else if (Platform.isIOS) {
        // deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
      // _deviceNew = _mac_address;
      // print("_mac_address : " + _mac_address);
      print("_platformVersion");
      // print(_platformVersion);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
      // platformVersion = 'Failed to get Device MAC Address.';
    }

    if (!mounted) return;

    setState(() {
      _deviceData = deviceData;
    });
  }

  Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'brand': build.brand,
      'display': build.display,
      'board': build.board,
      'device': build.device,
      'androidId': build.androidId,
    };
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 5. FUNGSI UNTUK MENJALANKAN AUTO SCROLL
  void _startAutoScroll() {
    _autoScrollTimer =
        Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        if (_currentPage < _totalSlides - 1) {
          _currentPage++;
        } else {
          _currentPage = 0; // Kembali ke slide pertama jika sudah di akhir
        }

        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  Future<void> requestPermission() async {
    var status = await Permission.camera.status;
    var statusStorage = await Permission.storage.status;
    // _showDialog('Camera permission status 0 : $status');

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (statusStorage.isDenied) {
      statusStorage = await Permission.storage.request();
    }

    if (status.isGranted) {
      // Permission granted, proceed with camera operations
      print('Camera permission granted');
      // _showDialog("Camera permission granted");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, guide user to app settings
      print('Camera permission permanently denied. Open app settings.');
      // _showDialog("Camera permission permanently denied. Open app settings.");
      openAppSettings(); // Opens app settings for the user
    } else {
      // Handle other statuses like restricted or limited
      print('Camera permission status: $status');
      // _showDialog('Camera permission status2: $status');
    }

    if (statusStorage.isGranted) {
      // Permission granted, proceed with camera operations
      print('Storage permission granted');
      // _showDialog("Camera permission granted");
    } else if (statusStorage.isPermanentlyDenied) {
      // Permission permanently denied, guide user to app settings
      print('Storage permission permanently denied. Open app settings.');
      // _showDialog("Camera permission permanently denied. Open app settings.");
      openAppSettings(); // Opens app settings for the user
    } else {
      // Handle other statuses like restricted or limited
      print('Storage permission status: $statusStorage');
      // _showDialog('Camera permission status2: $status');
    }
  }

  Future<void> locatiopermision() async {
    LocationPermission permission;

    // 1. Meminta izin lokasi dan menyimpan hasilnya ke variabel permission
    permission = await Geolocator.requestPermission();

    // 2. Gunakan variabel di bawah ini untuk mengecek status izin dari karyawan
    if (permission == LocationPermission.denied) {
      print("Izin lokasi ditolak oleh pengguna.");
      // Anda bisa memunculkan snackbar atau pesan peringatan di sini
    } else if (permission == LocationPermission.deniedForever) {
      print(
          "Izin lokasi ditolak permanen, silakan aktifkan lewat pengaturan hp.");
    } else {
      print("Izin lokasi berhasil diberikan!");
      // Anda aman untuk melanjutkan proses pengambilan titik GPS / Absen
    }
  }

  Future<int> setIntoUserSession() async {
    UserSession.login(
        company_id_: company_id,
        company_name_: company_name2,
        employee_id_: employee_id,
        employee_name_: employee_name,
        employee_personalid_: employee_personalid,
        employee_fingerid_: employee_fingerid,
        employee_type_: employee_type,
        office_id_: office_id,
        office_name_: office_name,
        employee_gender_: employee_gender,
        employee_dateofbirth_: employee_dateofbirth,
        divisi_name_: divisi_name,
        database_name_: database_name,
        device_info_: device_info,
        shift_id_: shift_id,
        department_name_: department_name,
        url_api_: url_api,
        url_api_slide_: url_api_slide,
        url_api_image_: url_api_image,
        url_api_prod_: url_api_prod,
        url_api_slide_prod_: url_api_slide_prod,
        url_api_image_prod_: url_image_prod,
        url_api_dev_: url_api_dev,
        url_api_slide_dev_: url_api_slide_dev,
        url_api_image_dev_: url_image_dev,
        employee_phone_: employee_phone,
        apikey_: apikey,
        token_: token,
        listcompany_id_: listcompany_id,
        debug_: debug,
        profile_image_file_: _imageFile,
        profile_image_url_: profile_image_url,
        employee_password_: _password,
        employee_address1_: employee_address1,
        employee_address2_: employee_address2,
        employee_bpjs_: employee_bpjs,
        employee_entrydate_: employee_entrydate,
        employeetype_name_: employeetype_name,
        employeeeducation_level_: employeeeducation_level,
        employee_dob_: employee_dob,
        employee_joindate_: employee_joindate,
        position_name_: position_name,
        url_api_lokal_: url_api_lokal,
        url_api_part1_: widget.url_api_part1,
        url_api_part2_: widget.url_api_part2,
        url_api_dev_part1_: widget.url_api_dev_part1,
        url_api_image_part1_: widget.url_api_image_part1,
        url_api_image_part2_: widget.url_api_image_part2,
        url_api_image_dev_part1_: widget.url_api_image_dev_part1,
        url_image_profile_part1_: widget.url_image_profile_part1,
        url_image_profile_part2_: widget.url_image_profile_part2,
        url_image_profile_dev_part1_: widget.url_image_profile_dev_part1,
        url_image_profile_: url_image_profile,
        userlevel_: userlevel,
        image_idcard_: image_idcard,
        employeeeducation_name_: employeeeducation_name);

    return 0;
  }

  String generateSignature(String secretKey, String timestamp) {
    // header
    String header = base64Encode(utf8.encode(jsonEncode({
      'typ': 'API',
      'alg': 'SHA256',
    })));
    String payload = base64Encode(utf8.encode(secretKey));

    String ts = base64Encode(utf8.encode(timestamp));

    // gabungkan
    String secretkey = '$header.$payload.$ts';

    // hasil final
    return base64Encode(utf8.encode(secretkey));
  }

  String getSecretKeyNoLog() {
    // 1. Header Dictionary & Base64 Encoding
    final Map<String, String> headerDict = {"typ": "API", "alg": "SHA256"};
    final String headerJson = jsonEncode(headerDict);
    final String headerBase64 = base64.encode(utf8.encode(headerJson));

    // 2. Timestamp ISO8601 & Base64 Encoding
    // .toIso8601String() di Dart menghasilkan format UTC dengan akhiran 'Z'
    // jika kita memanggil .toUtc() terlebih dahulu
    final String timestampStr =
        DateTime.now().toUtc().toIso8601String().split('.').first + 'Z';
    final String timestampBase64 = base64.encode(utf8.encode(timestampStr));
    print("timestamp : $timestampBase64");

    // 3. Generate Random Hex String (Panjang 20) & Base64 Encoding
    final String randomHex = generateRandomHexString(20);
    final String payloadBase64 = base64.encode(utf8.encode(randomHex));

    // 4. Combined & Final Token Base64 Encoding
    final String combined = "$headerBase64.$timestampBase64.$payloadBase64";
    final String finalToken = base64.encode(utf8.encode(combined));

    return finalToken;
  }

// Fungsi pembantu untuk membuat String Hex acak sepanjang n karakter
  String generateRandomHexString(int length) {
    final Random random =
        Random.secure(); // Lebih aman untuk kebutuhan kriptografi/token
    final List<int> values =
        List<int>.generate(length, (i) => random.nextInt(256));

    // Mengubah bytes menjadi format String Hexadecimal
    final String hexString =
        values.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join('');

    // Mengambil sepanjang panjang karakter yang diminta (Swift length: 20)
    return hexString.substring(0, length);
  }

  void prosesnew() {
    setState(() {
      isLoading = true;
    });

    String SecretKeyNoLog = getSecretKeyNoLog();

    fh
        .loginv1(NIK, _password, SecretKeyNoLog, "absen/loginv1", url_api)
        .then((resultlogin) {
      print(resultlogin);

      if (resultlogin.isNotEmpty) {
        resultlogin.forEach((value) {
          database_name = value['company'] ?? "";
          apikey = value['api'] ?? "";
          userlevel = value['userlevel'] ?? 0;
          fh.token(apikey, url_api).then((hasils) {
            print('token :');
            print(hasils);
            if (hasils.isNotEmpty) {
              token = hasils;
              fh.Setting("apk_version", apikey, token, "setting/show", url_api)
                  .then((resultversion) {
                if (resultversion.isNotEmpty) {
                  resultversion.forEach((value) {
                    _version_id = value['setting_value'] ?? "";
                    if (projectVersion == _version_id) {
                      if (userlevel == 1) {
                        setIntoUserSession().then((i) {
                          _navigateToHome(context, 4);
                        });
                      } else {
                        fh.Setting("ID_CARDTRK", apikey, token, "setting/show",
                                url_api)
                            .then((resultidcard) {
                          if (resultidcard.isNotEmpty) {
                            resultidcard.forEach((value) {
                              idCard = value['setting_value2'] ?? "";
                              idCardArray = idCard
                                  .trim()
                                  .split(',')
                                  .map((id) => id.trim())
                                  .toList();
                              print(
                                  "setting_value2 " + value['setting_value2']);
                              print("idCard : ${idCardArray}");
                            });
                          }

                          employee();
                        });
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                      // _showDialogDownload();
                      // hideLoadingDialog(context);
                      _navigateToDownloadAPK(context);
                    }
                  });
                } else {
                  // hideLoadingDialog(context);
                  setState(() {
                    isLoading = false;
                  });
                  _showDialog("Versi APK tidak ditemukan");
                }
              });
            } else {
              setState(() {
                isLoading = false;
              });
              _showDialog("Token is Null");
            }
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showDialog("Gagal Login");
      }
    });
  }

  void proses() {
    setState(() {
      isLoading = true;
    });

    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    // int offsetInHours = timeZoneOffset.inHours;
    // int offsetInMinutes = timeZoneOffset.inMinutes;
    String formattedOffset = '';
    if (timeZoneOffset.isNegative) {
      formattedOffset += '-';
    } else {
      formattedOffset += '+';
    }
    formattedOffset +=
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:';
    formattedOffset +=
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;
    // print(strTIMESTAMP);
    String signature = generateSignature(
      database_name,
      strTIMESTAMP,
    );
    if (signature == "") {
      _showDialog("signature is null");
    } else {
      print("Signature: $signature");
      getapikey(signature, strTIMESTAMP);
    }
  }

  void prosestodownload() {
    setState(() {
      isLoading = true;
    });

    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = '';
    if (timeZoneOffset.isNegative) {
      formattedOffset += '-';
    } else {
      formattedOffset += '+';
    }
    formattedOffset +=
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:';
    formattedOffset +=
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;
    // print(strTIMESTAMP);
    String signature = generateSignature(
      database_name,
      strTIMESTAMP,
    );
    if (signature == "") {
      _showDialog("signature is null");
    } else {
      print("Signature: $signature");
      // getapikey(signature, strTIMESTAMP);
      fh.apikey(signature, "apikey/show", url_api).then((hasils) {
        print('apikey :');
        print(hasils);
        if (hasils.isNotEmpty) {
          apikey = hasils;
          fh.token(apikey, url_api).then((hasils) {
            print('token :');
            print(hasils);
            if (hasils.isNotEmpty) {
              token = hasils;
              _navigateToDownloadAPK(context);

              // });
            } else {
              // hideLoadingDialog(context);
              setState(() {
                isLoading = false;
              });
              _showDialog("Token is Empty");
            }
          });
        } else {
          // hideLoadingDialog(context);
          setState(() {
            isLoading = false;
          });
          _showDialog("API Key is Empty");
        }
      });
    }
  }

  void getapikey(String secretkey, String timestamp) {
    // showLoadingDialog("Processing...", context);
    fh.apikey(secretkey, "apikey/show", url_api).then((hasils) {
      print('apikey :');
      print(hasils);
      if (hasils.isNotEmpty) {
        apikey = hasils;
        fh.token(apikey, url_api).then((hasils) {
          print('token :');
          print(hasils);
          if (hasils.isNotEmpty) {
            token = hasils;
            // fh.HOdate(apikey, token, "headofficedate/show", url_api)
            //     .then((resultdate) {
            //   print(resultdate);

            fh.Setting("apk_version", apikey, token, "setting/show", url_api)
                .then((resultversion) {
              if (resultversion.isNotEmpty) {
                resultversion.forEach((value) {
                  _version_id = value['setting_value'] ?? "";
                  if (projectVersion == _version_id) {
                    // hideLoadingDialog(context);
                    // database_name = _passwordController.text;
                    // employee();
                    login();
                  } else {
                    setState(() {
                      isLoading = false;
                    });
                    // _showDialogDownload();
                    // hideLoadingDialog(context);
                    // _navigateToDownload(context);
                  }
                });
              } else {
                // hideLoadingDialog(context);
                setState(() {
                  isLoading = false;
                });
                _showDialog("Versi APK tidak ditemukan");
              }
            });

            // });
          } else {
            // hideLoadingDialog(context);
            setState(() {
              isLoading = false;
            });
            _showDialog("Token is Empty");
          }
        });
      } else {
        // hideLoadingDialog(context);
        setState(() {
          isLoading = false;
        });
        _showDialog("API Key is Empty");
      }
    });
  }

  void login() {
    fh
        .login(NIK, _password, apikey, token, "absen/login", url_api)
        .then((resultlogin) {
      print(resultlogin);
      if (resultlogin.isEmpty) {
        setState(() {
          isLoading = false;
        });
        // _showDialog("Data Tidak Ditemukan");
        database_name = "transsnow";
        employee();

        // } else if (resultlogin.substring(0, 6) == "sukses") {
        //   print("SUKSES LOGIN");
        //   database_name = resultlogin.replaceAll("sukses_", "");
        //   print("database_name : " + database_name);
        //   // employee();
        //   setState(() {
        //     userlevel = 1;
        //   });
        //   // setIntoUserSession().then((i) {
        //   //   _navigateToHome(context, 4);
        //   // });
      } else {
        resultlogin.forEach((value) {
          database_name = value['company'] ?? "";
          userlevel = value['userlevel'] ?? 0;
          if (userlevel == 1) {
            setIntoUserSession().then((i) {
              _navigateToHome(context, 4);
            });
          } else {
            employee();
          }
        });
      }
    });
  }

  void employee() {
    setState(() {
      _year = yearFormat.format(dt);
      _month = monthFormat.format(dt);
      daynow = dayFormat.format(now);
      yesterday = now.subtract(Duration(days: 1));
      dayyesterday = dayFormat.format(yesterday);
    });
    // showLoadingDialog("Processing...", context);
    //LoadingScreen.instance().show(context: context, text: "Processing...");
    fh
        .employee(NIK, database_name, apikey, token, "employee/show", url_api)
        .then((result) {
      print(result);

      if (result.isNotEmpty) {
        result.forEach((value) {
          setState(() {
            office_id = value['office_id'];
            company_id = value['company_id'];
            employee_id = value['employee_id'];
            employee_name = value['employee_name'];
            employee_personalid = value['employee_personalid'];
            employee_fingerid = value['employee_fingerid'];
            office_id = value['office_id'];
            employee_gender = value['employee_gender'] ?? "";
            employee_dateofbirth = newFormat.format(DateTime.parse(
                value['employee_dateofbirth'] ?? DateTime.now().toString()));
            employee_dob = dailyFormat.format(DateTime.parse(
                value['employee_dateofbirth'] ?? DateTime.now().toString()));
            divisi_name = value['division_name'] ?? "";
            office_name = value['office_name'] ?? "";
            department_name = value['department_name'] ?? "";
            company_name2 = value['company_name'] ?? "";
            employee_type = value['employee_type'] ?? "";
            employee_phone = value['employee_notelp1'] ?? "";

            employee_address1 = value['employee_address1'] ?? "";
            employee_address2 = value['employee_address2'] ?? "";
            employee_bpjs = value['employee_bpjs'] ?? "";
            employee_entrydate = value['employee_entrydate'] ?? "";
            employee_joindate = newFormat.format(DateTime.parse(
                value['employee_entrydate'] ?? DateTime.now().toString()));
            employeetype_name = value['employeetype_name'] ?? "";
            employeeeducation_level = value['employeeeducation_level'] ?? "";
            position_name = value['position_name'] ?? "";
            employeeeducation_name = value['employeeeducation_name'] ?? "";

            print("employee_type : " + employee_type);

            isLoading = false;

            profile_image_url = url_image_profile + employee_id + ".jpg";

            profile_image_url =
                "${profile_image_url}?t=${DateTime.now().millisecondsSinceEpoch}";
            print("profile_image_url : " + profile_image_url);
            NetworkImage(UserSession.profile_image_url).evict();

            if (database_name == "transstudio") {
              image_idcard = "idcard_ts.png";
            } else if (database_name == "transsnow") {
              image_idcard = "idcard_tsw.png";
            } else if (database_name == "transstudiomini") {
              print("office_id " + office_id);
              bool isFound = idCardArray.contains(office_id);
              if (isFound) {
                print('ID $office_id ditemukan di dalam daftar.');
                image_idcard = "idcard_kc.png";
              } else {
                print('ID $office_id tidak terdaftar.');
                image_idcard = "idcard_tsm.png";
              }
            } else {
              image_idcard = "idcard_te.png";
            }
            print("image_idcard : " + image_idcard);
            // setIntoUserSession().then((hasils) {
            //   _navigateToHome(context);
            // });
            db.deleteNIKbyid(employee_personalid).then((result) {
              db
                  .saveNIK(NIKS(employee_personalid, employee_name))
                  .then((result) {
                listNIK();
              });
            });
          });
        });
        if (employee_type == "EMP") {
          fh
              .employeeshift(database_name, _year, _month, employee_id, apikey,
                  token, "employeeshift/show", url_api)
              .then((resultshift) {
            if (resultshift.isNotEmpty) {
              resultshift.forEach((value) {
                shift_id = value['employeeshift_' + daynow] ?? "";
                shift_id = shift_id.trim();
                print('SHIFT ID : ' + daynow);
                print(value['employeeshift_' + daynow] ?? "");
                print(shift_id);
              });
              if (shift_id == "") {
                _showDialog("Anda Belum Memiliki Jadwal Shift Hari ini");
              } else {
                print("loadNetworkImageToOpenFile :");
                // loadNetworkImageToOpenFile(url_api_image + employee_id + ".jpg")
                //     .then((result) {
                setIntoUserSession().then((hasils) {
                  _navigateToHome(context, 0);
                });
                // });
              }
            } else {
              _showDialog("Anda Belum Memiliki Jadwal Shift Bulan ini");
            }
          });
        } else {
          // hideLoadingDialog(context);
          // if (_type == "ABSEN") {
          // loadNetworkImageToOpenFile(url_api_image + employee_id + ".jpg")
          //     .then((result) {
          setIntoUserSession().then((hasils) {
            _navigateToHome(context, 0);
          });
          // });
          // } else {
          //   _showDialog("Mohon hubungi atasan anda");
          // }
        }
      } else {
        // hideLoadingDialog(context);
        //LoadingScreen.instance().hide();
        setState(() {
          isLoading = false;
        });
        _showDialog("Data Pegawai tidak ditemukan");
      }
    });
  }

  void listNIK() {
    db.getNIK().then((resultsNIK) {
      menuNIKS.clear();
      if (resultsNIK.isNotEmpty) {
        setState(() {
          for (var rows in resultsNIK) {
            print(rows['personalid']);
            menuNIKS.add(MenuNIK(rows['personalid'], rows['name']));
          }
        });
      }
    });
  }

  void listcompany() {
    setState(() {
      isLoading = true;
    });
    fh.listcompany("company/slider", url_api).then((resultslider) {
      print(resultslider);
      if (resultslider.isNotEmpty) {
        imageslidePaths.clear();
        setState(() {
          imageslidePaths = resultslider;
        });
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showDialog("Data Banner is Empty");
      }
    });
  }

  static String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("H:m:s").format(now);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    // final TextEditingController niksController = TextEditingController();
    // MenuNIK? selectedNiks;

    return PopScope(
      canPop:
          false, // 💡 KUNCI UTAMA: false berarti tombol back HP dinonaktifkan total
      onPopInvoked: (didPop) {
        if (didPop) return;

        // (Opsional) Tempat menulis logika jika tombol back ditekan
        // Contoh: Menampilkan pesan singkat (Toast/Snackbar) atau Dialog konfirmasi
        debugPrint("Tombol back HP ditekan, tetapi digagalkan!");
      },
      child: Scaffold(
        body: Stack(
          children: [
            Container(color: Colors.white),

            // 2. BACKGROUND LAPISAN ATAS (NAVY)
            Container(
              height: screenHeight * 0.50,
              decoration: const BoxDecoration(
                color: AppColors.primary, // Menggunakan AppColors.primary
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: SizedBox(
                        height: 80.0,
                        child: Image.asset("assets/logote.png",
                            fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 20),
                    isLoading == true
                        ? const LinearProgressIndicator(
                            backgroundColor: Color(0xFFF1F1F1),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.accent),
                            minHeight: 4, // Ketebalan garis progress
                          )
                        : Container(),

                    // 3. BANNER SLIDER & INDICATOR
                    Column(
                      children: [
                        CarouselSlider.builder(
                          itemCount: imageslidePaths.length,
                          itemBuilder:
                              (BuildContext context, int index, int realIndex) {
                            return Stack(
                              children: [
                                Image.network(
                                  url_api_slide +
                                      imageslidePaths[index]['value'],
                                  width: MediaQuery.of(context).size.width,
                                  fit: BoxFit.cover,
                                  // height: 200,
                                  // fit: BoxFit.fitWidth,
                                  // width: double.infinity,
                                ),
                                Positioned(
                                  bottom: 35.0,
                                  child: Container(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                TimerBuilder.periodic(
                                                    Duration(seconds: 1),
                                                    builder: (context) {
                                                  return Text(
                                                    "${getSystemTime()}" +
                                                        " " +
                                                        strTimeZone,
                                                    textAlign: TextAlign.left,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w700),
                                                  );
                                                }),
                                                Text(
                                                  formattedDate,
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.0,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                  textAlign: TextAlign.left,
                                                ),
                                              ]),
                                        ]),
                                    color: Colors
                                        .black54, // Optional: for better text visibility
                                    padding: EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                  ),
                                ),
                              ],
                            );
                          },
                          options: CarouselOptions(
                            viewportFraction: 1.0,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            padEnds: false,
                            initialPage: 0,
                          ),
                        ),
                        // SizedBox(
                        //   height: 140, // Mengatur tinggi area slider
                        //   width: double.infinity,
                        //   child: CarouselSlider.builder(
                        //     itemCount: imageslidePaths.length,
                        //     itemBuilder: (BuildContext context, int index,
                        //         int realIndex) {
                        //       return Container(
                        //         margin:
                        //             const EdgeInsets.symmetric(horizontal: 24),
                        //         decoration: BoxDecoration(
                        //           gradient: const LinearGradient(
                        //             colors: [
                        //               AppColors.secondary,
                        //               AppColors.secondaryLight,
                        //             ],
                        //             begin: Alignment.topLeft,
                        //             end: Alignment.bottomRight,
                        //           ),
                        //           borderRadius: BorderRadius.circular(16),
                        //         ),
                        //         child: ClipRRect(
                        //           borderRadius: BorderRadius.circular(
                        //               16), // Memotong gambar sesuai bentuk container
                        //           child: Image.network(
                        //             url_api_slide +
                        //                 imageslidePaths[index]['value'],
                        //             width: double
                        //                 .infinity, // Membuat gambar memenuhi lebar container
                        //             height: double
                        //                 .infinity, // Membuat gambar memenuhi tinggi container
                        //             fit: BoxFit
                        //                 .cover, // Gambar otomatis terpotong rapi tanpa merusak rasio
                        //             errorBuilder: (context, error, stackTrace) {
                        //               return const Center(
                        //                 child: Icon(Icons.broken_image,
                        //                     color: Colors.white, size: 40),
                        //               );
                        //             },
                        //             loadingBuilder:
                        //                 (context, child, loadingProgress) {
                        //               if (loadingProgress == null) return child;
                        //               return const Center(
                        //                 child: CircularProgressIndicator(
                        //                     color: Colors.white),
                        //               );
                        //             },
                        //           ),
                        //         ),
                        //       );
                        //       // return Stack(
                        //       //   children: [
                        //       //     Image.network(
                        //       //       url_api_slide +
                        //       //           imageslidePaths[index]['value'],
                        //       //       width: MediaQuery.of(context).size.width,
                        //       //       fit: BoxFit.cover,
                        //       //       // height: 200,
                        //       //       // fit: BoxFit.fitWidth,
                        //       //       // width: double.infinity,
                        //       //     ),
                        //       //   ],
                        //       // );
                        //     },
                        //     options: CarouselOptions(
                        //       viewportFraction:
                        //           1.0, // Ensures full width for each item
                        //       // height: MediaQuery.of(context)
                        //       //     .size
                        //       //     .height, // Optional: full height
                        //       autoPlay: true,
                        //       enlargeCenterPage: false,
                        //       padEnds: false,
                        //       initialPage: 0,
                        //     ),
                        //   ),
                        //   // child: PageView(
                        //   //   controller: _pageController,
                        //   //   onPageChanged: (int page) {
                        //   //     setState(() {
                        //   //       _currentPage = page;
                        //   //     });
                        //   //   },
                        //   //   children: [
                        //   //     // SLIDE 1
                        //   //     _buildSliderItem(
                        //   //       imageUrl: '${url_api_slide}banner1.jpg',
                        //   //     ),
                        //   //     // SLIDE 2
                        //   //     _buildSliderItem(
                        //   //       imageUrl: '${url_api_slide}banner2.jpg',
                        //   //     ),
                        //   //     // SLIDE 3
                        //   //     _buildSliderItem(
                        //   //       imageUrl: '${url_api_slide}banner3.jpg',
                        //   //     ),
                        //   //   ],
                        //   // ),
                        // ),
                        // const SizedBox(height: 12),

                        // 4. DYNAMIC PAGE INDICATOR DOTS (ORANGE)
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children:
                        //       List.generate(imageslidePaths.length, (index) {
                        //     return AnimatedContainer(
                        //       duration: const Duration(milliseconds: 300),
                        //       margin: const EdgeInsets.symmetric(horizontal: 2),
                        //       width: _currentPage == index ? 24.0 : 8.0,
                        //       height: 8.0,
                        //       decoration: BoxDecoration(
                        //         color: _currentPage == index
                        //             ? AppColors.accent
                        //             : Colors.white54,
                        //         borderRadius: BorderRadius.circular(4),
                        //       ),
                        //     );
                        //   }),
                        // ),
                      ],
                    ),

                    // const SizedBox(height: 10),

                    // CARD FORM LOGIN
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 0),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((0.08 * 255).round()),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HEADER FORM
                          const Row(
                            children: [
                              Icon(Icons.person,
                                  color: AppColors.accent,
                                  size: 20), // Menggunakan AppColors.accent
                              SizedBox(width: 8),
                              Text(
                                'Masuk ke Akun Anda',
                                style: TextStyle(
                                  color: AppColors
                                      .primary, // Menggunakan AppColors.primary
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // TEXTFIELD USERNAME
                          const Text(
                            'Username',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight
                                    .w600), // Menggunakan AppColors.primary
                          ),
                          const SizedBox(height: 8),
                          // 1. Ganti Expanded menjadi SizedBox agar aman dari error Unbounded Height
                          SizedBox(
                            width: double
                                .infinity, // Membuat dropdown memenuhi lebar form mengikuti padding halaman
                            child: DropdownMenu<MenuNIK>(
                              controller: _NIKController,
                              expandedInsets: EdgeInsets
                                  .zero, // Tetap gunakan ini agar dropdown melebar memenuhi SizedBox
                              menuHeight: 300,
                              hintText: "Masukkan NIK Anda",
                              requestFocusOnTap: true,
                              enableFilter: true,
                              menuStyle: MenuStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Colors.lightBlue.shade50,
                                ),
                              ),
                              label: const Text('Masukkan NIK Anda'),
                              onSelected: (MenuNIK? menu) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  setState(() {
                                    // data onSelected Anda
                                  });
                                });
                              },
                              dropdownMenuEntries: menuNIKS
                                  .map<DropdownMenuEntry<MenuNIK>>(
                                      (MenuNIK menu) {
                                return DropdownMenuEntry<MenuNIK>(
                                  value: menu,
                                  label: menu.personalid,
                                );
                              }).toList(),
                            ),
                          ),

                          // TextField(
                          //   controller: _usernameController,
                          //   decoration: InputDecoration(
                          //     prefixIcon: const Icon(Icons.person_outline,
                          //         color: Colors.grey),
                          //     border: OutlineInputBorder(
                          //         borderRadius: BorderRadius.circular(12)),
                          //     enabledBorder: OutlineInputBorder(
                          //       borderRadius: BorderRadius.circular(12),
                          //       borderSide:
                          //           BorderSide(color: Colors.grey.shade300),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 16),

                          // TEXTFIELD PASSWORD
                          const Text(
                            'Password',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight
                                    .w600), // Menggunakan AppColors.primary
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Colors.grey),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.grey),
                                onPressed: () => setState(
                                    () => _obscureText = !_obscureText),
                              ),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // 5. TOMBOL LOGIN (ORANGE)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // NIK = _usernameController.text.trim();
                                NIK = _NIKController.text.trim();
                                _password = _passwordController.text.trim();
                                if (NIK == "") {
                                  _showDialog("NIK belum diisi");
                                } else if (_passwordController.text == "") {
                                  _showDialog("Password belum diisi");
                                } else if (NIK == "clear nik") {
                                  db.deleteNIKAll();
                                  listNIK();
                                  setState(() {
                                    _NIKController.text = "";
                                    NIK = "";
                                  });
                                } else if (NIK == "debug on") {
                                  url_api = url_api_dev;
                                  url_api_image = url_image_dev;
                                  url_api_slide = url_api_slide_dev;
                                  setState(() {
                                    debug = "on";
                                    _NIKController.text = "";
                                    NIK = "";
                                  });
                                } else if (NIK == "debug off") {
                                  url_api = url_api_prod;
                                  url_api_image = url_image_prod;
                                  url_api_slide = url_api_slide_prod;
                                  setState(() {
                                    debug = "off";
                                    _NIKController.text = "";
                                    NIK = "";
                                  });
                                } else if (NIK == "debug lokal") {
                                  _showDialogDebug();
                                } else if (NIK == "uploadphoto") {
                                  _navigateToUploadPhoto(context);
                                } else if (NIK == "downloadapk") {
                                  prosestodownload();
                                } else if (NIK == "download") {
                                  _navigateToDownloadAPK(context);
                                } else {
                                  prosesnew();
                                }
                              },
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              label: const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors
                                    .accent, // Menggunakan AppColors.accent
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(height: 50),
                          Container(
                            width: MediaQuery.of(context).copyWith().size.width,
                            height: 100.0,
                            // width: 150,
                            child: Row(children: <Widget>[
                              Switch(
                                value:
                                    _isSwitched, // Menentukan posisi tombol saat ini
                                activeColor: Colors.red, // Warna ketika ON
                                inactiveThumbColor:
                                    Colors.grey, // Warna lingkaran ketika OFF

                                onChanged: (value) {
                                  // 2. Mengubah status secara real-time saat ditekan
                                  setState(() {
                                    _isSwitched = value;
                                    // if (value == true) {
                                    //   debug = "on";
                                    //   url_api = url_api_dev;
                                    //   url_api_image = url_image_dev;
                                    //   url_api_slide = url_api_slide_dev;
                                    // } else {
                                    //   debug = "off";
                                    //   url_api = url_api_prod;
                                    //   url_api_image = url_image_prod;
                                    //   url_api_slide = url_api_slide_prod;
                                    // }
                                    if (value == true) {
                                      debug = "on";
                                      url_api = widget.url_api_dev_part1 +
                                          widget.url_api_part2;
                                      url_api_slide = widget.url_api_slide;
                                      url_api_image =
                                          widget.url_api_image_dev_part1 +
                                              widget.url_api_image_part2;
                                      url_image_profile =
                                          widget.url_image_profile_dev_part1 +
                                              widget.url_image_profile_part2;
                                    } else {
                                      debug = "off";
                                      url_api = widget.url_api_part1 +
                                          widget.url_api_part2;
                                      url_api_slide = widget.url_api_slide;
                                      url_api_image =
                                          widget.url_api_image_part1 +
                                              widget.url_api_image_part2;
                                      url_image_profile =
                                          widget.url_image_profile_part1 +
                                              widget.url_image_profile_part2;
                                    }
                                  });
                                  print("Status saklar saat ini: $_isSwitched");
                                },
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Debug " + debug,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            ]),
                          ),

                          // LUPA PASSWORD
                          // Center(
                          //   child: TextButton(
                          //     onPressed: () {},
                          //     child: const Text(
                          //       'Lupa Password?',
                          //       style: TextStyle(
                          //           color: AppColors.primary,
                          //           fontWeight: FontWeight.w600),
                          //       // Menggunakan AppColors.primary
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk membuat item banner di dalam slider
  Widget _buildSliderItem({
    required String imageUrl, // Hanya membutuhkan URL gambar
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.secondaryLight,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
            16), // Memotong gambar sesuai bentuk container
        child: Image.network(
          imageUrl,
          width: double.infinity, // Membuat gambar memenuhi lebar container
          height: double.infinity, // Membuat gambar memenuhi tinggi container
          fit: BoxFit
              .cover, // Gambar otomatis terpotong rapi tanpa merusak rasio
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 40),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          },
        ),
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

  _showDialogDebug() async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(16.0),
        content: Row(
          children: <Widget>[
            Expanded(
              //padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: TextField(
                autofocus: true,
                controller: _strController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                //onChanged: (value) {
                //
                // },
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
            child: new Text("BATAL"),
          )),
          Container(
              child: ElevatedButton(
            onPressed: () {
              setState(() {
                // _isSwitched = true;
                // strdebug = "On";
                _str = _strController.text;
                url_api = _str + widget.url_api_part2;
                url_api_image = _str + widget.url_api_image_part2;
                url_image_profile = _str + widget.url_image_profile_part2;
                url_api_lokal = _str;
                print("url_api : " + url_api);
                print("url_api_image : " + url_api_image);
                print("url_image_profile : " + url_image_profile);
                print("url_api_lokal : " + url_api_lokal);
                debug = "lokal";
                // url_api_lokal = url_api.replaceAll(
                //     "https://api-hcm.transentertainment.com/", _str);
                // url_api_lokal = url_api.replaceAll(
                //     "https://api-hcmdev.transentertainment.com/", _str);
                // url_api_lokal = url_api.replaceAll(str_url_api_lokal, _str);

                // print("str_url_api_lokal : " + str_url_api_lokal);

                // print("url_api : " + url_api_lokal);

                // url_image_lokal = url_api_image.replaceAll(
                //     "https://sso.transentertainment.com/", _str);
                // url_image_lokal = url_api_image.replaceAll(
                //     "https://ssodev.transentertainment.com/", _str);
                // // url_image_lokal =
                // //     url_api_image.replaceAll(str_url_api_lokal, _str);

                // print("url_api_image : " + url_image_lokal);

                // url_image_profile_lokal = url_image_profile.replaceAll(
                //     "https://sso.transentertainment.com/", _str);
                // url_image_profile_lokal = url_image_profile.replaceAll(
                //     "https://ssodev.transentertainment.com/", _str);

                // url_image_profile_lokal =
                //     url_image_profile.replaceAll(str_url_api_lokal, _str);

                // print("url_image_profile : " + url_image_profile_lokal);

                // url_api = url_api_lokal;
                // url_api_image = url_image_lokal;
                // url_image_profile = url_image_profile_lokal;

                // url_api_slide = url_api_slide_prod;

                _NIKController.text = "";
                NIK = "";
                url_api_lokal = _str;
                _strController.text = url_api_lokal;
              });
              Navigator.pop(context);
            },
            child: new Text("OK"),
          )),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context, int noindex) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => HomeNewPage(
              imageslidePaths: imageslidePaths,
              noindex: noindex,
              userlevel: userlevel,
            ));
    Navigator.push<void>(context, route);
  }

  // void _navigateToDownload(BuildContext context) async {
  //   Route route = MaterialPageRoute<void>(builder: (context) => DownloadPage());
  //   Navigator.push<void>(context, route);
  // }

  void _navigateToDownloadAPK(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => DownloadAPKPage(
              url_api: url_api,
              apikey: apikey,
              token: token,
            ));
    Navigator.push<void>(context, route);
  }

  void _navigateToUploadPhoto(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => UploadPhotoPage(
              url_api: url_api,
              apikey: apikey,
              token: token,
            ));
    Navigator.push<void>(context, route);
  }
}
