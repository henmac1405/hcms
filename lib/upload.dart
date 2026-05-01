import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  String _filename = "";
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");
  var daily2Format = DateFormat("yyyyMMdd");
  var hour2Format = DateFormat("HHmmss");
  XFile? imageFile;
  String token =
      "ZXlKMGVYQWlPaUpCVUVraUxDSmhiR2NpT2lKVFNFRXlOVFlpZlE9PS5leUoxYzJWeVgybGtJam9pYkdsNVlXNTBieUo5LjE3NTY0NTgzNTEuYzUzOWMzY2Y4ZDM4MDM1NzdjMWQ3NGZiYjhkMTRjNWU1ODM0OGJkMjk4MGQzYmFmYjQ0OTQxMzA3NmZiNmVjYQ==";
  // String url_api =
  //     "http://172.16.5.58/api-ci3/index.php/api/v1/uploadgambar/upload";
  String url_api =
      "http://192.168.0.7/api-ci3/index.php/api/v1/uploadgambar/upload";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Upload',
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Padding(
        padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(255, 76, 85, 250),
                onPrimary: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10), // Sets a circular border radius of 20
                ),
              ),
              onPressed: () {
                _uploaddio();
              },
              child: Text("Choose File"),
            ),
            SizedBox(width: 8),
            Text(_filename),
          ],
        ),
      ),
    );
  }

  _openGallery() async {
    DateTime now = DateTime.now();
    String strTIMESTAMP =
        dailyFormat.format(now) + "T" + hourFormat.format(now) + "+07:00";
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY":
          "14f9e5a911b12c409d9993491f782a2ace5d043ed58e358768ab1b3177c22fcd",
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    // Map<String, dynamic> params = {"filename": "tes", "file": file};

    imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    // String basename = basename(imageFile!.path);
    setState(() {
      print(imageFile!.name);
      _filename = imageFile!.name;
    });
    // uploadPhoto(imageFile);

    // Membuat objek Dio
    Dio dio = new Dio();

    // Membuat data yang akan di-upload
    FormData data = new FormData.fromMap({
      "name": "file",
      "file": await MultipartFile.fromFile(imageFile!.path),
    });

    // Mengatur opsi untuk permintaan
    Options options = new Options(
      headers: {
        "Authorization": basicAuth,
        "APIKEY":
            "14f9e5a911b12c409d9993491f782a2ace5d043ed58e358768ab1b3177c22fcd",
        "TIMESTAMP": strTIMESTAMP,
        "TOKEN": token,
      },
    );

    // Mengirim data ke server
    Response response = await dio.post(url_api, data: data, options: options);
  }

  Future<List> uploadimage(String filename, File file) async {
    List? data;
    String strerror = "";
    DateTime now = DateTime.now();
    String strTIMESTAMP =
        dailyFormat.format(now) + "T" + hourFormat.format(now) + "+07:00";
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY":
          "14f9e5a911b12c409d9993491f782a2ace5d043ed58e358768ab1b3177c22fcd",
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {"filename": filename, "file": file};
    print(token);
    // print(api_name);
    print(url_api);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api),
        headers: headers,
        body: params,
      );
      // print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {}
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<void> _uploaddio() async {
    DateTime now = DateTime.now();
    String strTIMESTAMP =
        dailyFormat.format(now) + "T" + hourFormat.format(now) + "+07:00";
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    // Adjust quality (0-100)

    var dio = Dio();
    String fileName = imageFile!.path.split('/').last;
    String imgname = daily2Format.format(now) + hour2Format.format(now);
    print(imgname);

    FormData formData = FormData.fromMap({
      // resizedImageBytes,

      "file": await MultipartFile.fromFile(
        imageFile!.path,

        filename: fileName,

        contentType: MediaType("image", "jpeg"), //add this
      ),

      "filename": imgname,
    });

    print(fileName);
    print(url_api);
    print(strTIMESTAMP);

    var response = await dio.post(
      url_api,
      data: formData,
      options: Options(
        headers: {
          "APIKEY":
              "14f9e5a911b12c409d9993491f782a2ace5d043ed58e358768ab1b3177c22fcd",
          "TIMESTAMP": strTIMESTAMP,
          "TOKEN": token,
          'authorization': basicAuth
        },
      ),
      onSendProgress: (int sent, int total) {
        debugPrint("sent${sent.toString()}" + " total${total.toString()}");
      },
    ).whenComplete(() {
      debugPrint("complete:");
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
    });
  }

  Future<File> resizeImage(
      File originalImageFile, int maxWidth, int maxHeight) async {
    // Decode the image bytes into an Img.Image object
    Img.Image? imageTemp = Img.decodeImage(originalImageFile.readAsBytesSync());

    if (imageTemp == null) {
      // Handle error if image decoding fails
      return originalImageFile;
    }

    // Resize the image while maintaining aspect ratio
    Img.Image resizedImage = Img.copyResize(
      imageTemp,
      width: maxWidth,
      height: maxHeight,
    );

    // Create a new file for the resized image
    final String dir =
        (await getTemporaryDirectory()).path; // Requires path_provider package
    final String fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    final File resizedImageFile = File('$dir/$fileName');

    // Encode the resized image to JPEG format with a specified quality
    await resizedImageFile.writeAsBytes(
        Img.encodeJpg(resizedImage, quality: 85)); // Adjust quality as needed

    return resizedImageFile;
  }
}
