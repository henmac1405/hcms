import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hcms/database/db_helper.dart';
// import 'package:posdownload/models/config.dart';
// import 'package:posticket/screens/cek_koneksi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms/database/function_helper.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:hcms/sesstion_settings.dart';
import 'package:flutter_archive/flutter_archive.dart';
// import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';

//tes uploadddd
class DownloadPage extends StatefulWidget {
  DownloadPage({
    Key? key,
  }) : super(key: key);
  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();
  Map<String, dynamic> closed = {'id': 'CLOSE', 'name': 'CLOSE'};
  final dt = new DateTime.now();
  var newFormat = DateFormat("yyyy-MM-dd");
  var dailyFormat = DateFormat("yyMMdd");
  String _url_api = "";
  String _url_api_lokal = "";
  String _url_api_sync = "";
  TextEditingController _fileurlController = new TextEditingController();
  TextEditingController _filenameController = new TextEditingController();
  bool isLoading = false;

  String statusurlapi1 = "";
  String statusurlapi2 = "";
  String statusurlapi3 = "";
  String strerror = "";
  String _fileurl = "";
  String _filename = "";

  String _fileurl_new = "";
  String _filename_new = "";
  String _fileurl_old = "";
  String _filename_old = "";

  double? _progress;
  String _status = '';
  final SessionSettings settings = SessionSettings();

  int? _downloadId;
  String directory = "";
  var _openResult = 'Unknown';
  String zipfilename = "";
  String zipfilepath = "";
  String _subPath = "";
  var dio = Dio();
  int? _selectedValue;
  String _selectedOption = "";

  int _radioSelected = 1;
  String _radioVal = "NEW";

  @override
  void initState() {
    super.initState();
    _getPath();
    _filenameController.text = "hcms.zip";
    // _fileurlController.text =
    //     "https://sso.transentertainment.com/files.php?f=absence-te-apps.zip";
    _fileurlController.text =
        "https://sso.transentertainment.com/files.php?f=absence-te-hcm-14-okt-2025.apk";
    requestPermission();
    // getconfig();
  }

  Future<String> getconfig() async {
    db.getConfig().then((hasils) {
      print(hasils);
      _radioSelected = 1;
      _radioVal = "NEW";
      if (hasils.length > 0) {
        hasils.forEach((rows) {
          // print(rows['qty']);
          setState(() {
            _url_api = rows['config1'];
            _url_api_lokal = rows['config2'];
            _url_api_sync = rows['config1'];
            strerror = "";
            getmastersetting();
          });
        });
      } else {
        setState(() {
          _url_api = "";
          _url_api_lokal = "";
          _url_api_sync = "";
          strerror = "URL API KOSONG";
        });
      }
    });
    return _url_api;
  }

  void getmastersetting() {}

  void _navigateToCekKoneksi(BuildContext context) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "DOWNLOAD AND UPDATE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Colors.black,
            ),
            onPressed: () {
              // _navigateToRegistrasi(context);
              // getconfig();
              _getPath();
              _status = "";
              strerror = "";
              _progress = 0;
            },
          ),
        ],
      ),
      body: SafeArea(
          bottom: false,
          top: false,
          child: Form(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Mohon update apps yang terbaru, silahkan download dan update : ",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20.0,
                  ),
                ),
                Text(
                  strerror,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 20.0,
                  ),
                ),
                if (_status.isNotEmpty) ...[
                  Text(
                    _status,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_progress != null) ...[
                  LinearProgressIndicator(
                    value: _progress! / 100,
                  ),
                  const SizedBox(
                    height: 20,
                    width: 20,
                  ),
                ],
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.adjust),
                      // hintText: 'Enter your firs and latname',
                      labelText: 'DOWNLOAD FILE URL'),
                  controller: _fileurlController,
                  keyboardType: TextInputType.multiline,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 3,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                    padding: EdgeInsets.only(left: 5, top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () async {
                        setState(() {
                          // isLoading = true;
                          _fileurl = _fileurlController.text;
                          _status = "";
                          _progress = 0;

                          // statusurlapi1 = "";
                        });
                        _fileurl =
                            "https://sso.transentertainment.com/files.php?f=absence-te-hcm-14-okt-2025.apk";
                        _filename = "absence-te-hcm.apk";
                        if (_fileurl == "") {
                          _showDialogWarning("File URL Kosong");
                          _status = "--Path Not Found--";
                        } else {
                          deleteFile(File(directory + _filename));
                          // _onDownloadFilePressed();
                          download2(dio, _fileurl, directory + _filename);
                        }
                        // cekkoneksi(_url_api + "cek_koneksi", "1");
                      },
                      child: new Text("DOWNLOAD"),
                    )),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          )),
      persistentFooterButtons: [
        Container(
          width: MediaQuery.of(context).copyWith().size.width,
          // width: 150,
          child: Row(children: <Widget>[
            Expanded(
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: new Text("TUTUP"),
            )),
          ]),
        ),
      ],
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.red,
      //   foregroundColor: Colors.white,
      //   onPressed: () async {
      //     _unzipFile();
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.refresh),
      // ),
    );
  }

  _showDialogWarning(String ket) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          ket,
          overflow: TextOverflow.ellipsis,
          maxLines: 20,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
        actions: <Widget>[
          Container(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("OK"),
          )),
        ],
      ),
    );
  }

  void _unzipFile() async {
    final zipFile = File(directory + _filename);
    final destinationDir = Directory(directory);
    zipfilename = _filename;
    try {
      await ZipFile.extractToDirectory(
          zipFile: zipFile,
          destinationDir: destinationDir,
          onExtracting: (zipEntry, progress) {
            zipfilename = zipEntry.name;
            print('progress: ${progress.toStringAsFixed(1)}%');
            print('name: ${zipEntry.name}');
            print('isDirectory: ${zipEntry.isDirectory}');
            print(
                'modificationDate: ${zipEntry.modificationDate?.toLocal().toIso8601String()}');
            print('uncompressedSize: ${zipEntry.uncompressedSize}');
            print('compressedSize: ${zipEntry.compressedSize}');
            print('compressionMethod: ${zipEntry.compressionMethod}');
            print('crc: ${zipEntry.crc}');
            setState(() {
              _status =
                  'Download Finished, Please Update APK  \nFile Name : ${zipEntry.name}';
              isLoading = false;
            });
            return ZipFileOperation.includeItem;
          });
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> openFile() async {
    // final filePath =
    //     '/storage/emulated/0/Downloads/app-release-NEW-06-08-2025.apk';
    String fullPath = directory + _filename;
    final result = await OpenFile.open(fullPath);
    print('fullPath : ' + fullPath);

    setState(() {
      _status = "Finished... Opened";
      _openResult = "type=${result.type}  message=${result.message}";
      print(_openResult);
    });
  }

  Future<String> _getPath() async {
    if (Platform.isIOS) {
      directory = (await getDownloadsDirectory())?.path ??
          (await getTemporaryDirectory()).path;
    } else {
      directory = '/storage/emulated/0/Download/';
      var dirDownloadExists = true;
      dirDownloadExists = await Directory(directory).exists();
      if (!dirDownloadExists) {
        directory = '/storage/emulated/0/Downloads/';
        dirDownloadExists = await Directory(directory).exists();
        if (!dirDownloadExists) {
          directory = (await getTemporaryDirectory()).path;
        }
      }
    }
    return directory;
  }

  Future<void> deleteFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Error in getting access to the file.
    }
  }

  Future download2(Dio dio, String url, String savePath) async {
    setState(() {
      isLoading = true;
    });
    print(url);
    try {
      Response response = await dio.get(
        url,
        onReceiveProgress: showDownloadProgress,
        //Received data with List<int>
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            validateStatus: (status) {
              return status! < 500;
            }),
      );
      // String basename = basename(file.path);
      final String downloadfilename = p.basename(url);
      print('downloadfilename');
      print(downloadfilename);

      print('response.headers');
      print(response.headers);
      print('response.statusCode');
      print(response.statusCode);
      print('response.statusMessage');
      print(response.statusMessage);
      if (response.statusCode == 404) {
        setState(() {
          _status = "--Path Not Found--";
          _progress = 0;
          isLoading = false;
        });
      }
      File file = File(savePath);
      var raf = file.openSync(mode: FileMode.write);
      // response.data is List<int> type
      raf.writeFromSync(response.data);
      await raf.close();
    } catch (e) {
      print(e);
      print("error");
      setState(() {
        isLoading = false;
      });
    }
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100);
        _status = "wait.. " + (received / total * 100).toStringAsFixed(0) + "%";
      });
      print((received / total * 100).toStringAsFixed(0) + "%");
      if (_progress == 100) {
        Future.delayed(Duration(seconds: 1)).then((onValue) {
          // _unzipFile();
          setState(() {
            _status = "Finished..";
          });
          openFile();
        });
      }
    }
  }

  Future<void> requestPermission() async {
    var status = await Permission.camera.status;
    var statusStorage = await Permission.storage.status;
    // _showDialog('Camera permission status 0 : $status');

    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (statusStorage.isDenied) {
      status = await Permission.storage.request();
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
}
