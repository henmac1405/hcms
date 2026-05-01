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
import 'package:hcms/models/error.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:hcms/database/function_helper.dart';

class MapsPage extends StatefulWidget {
  final String url_api;
  final String token;
  const MapsPage({
    super.key,
    required this.url_api,
    required this.token,
  });

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();

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
  List itemerror = [];

  @override
  void initState() {
    super.initState();
    this.getdata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'MAPS',
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Image.asset(
          'assets/maps.jpeg', // The path to your image
          // width: 200, // Optional: specify width
          // height: 150, // Optional: specify height
          fit: BoxFit
              .cover, // Optional: how the image should be inscribed into the box
        ),
      ),
      persistentFooterButtons: [
        Container(
            width: MediaQuery.of(context).copyWith().size.width,
            child: Row(children: <Widget>[
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  onPrimary: Colors.yellow,
                ),
                onPressed: () {
                  // db.deleteErrorAll();
                  // setState(() {
                  //   getdata();
                  // });
                },
                child: new Text(
                  "HAPUS",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  onPrimary: Colors.yellow,
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child: new Text(
                  "TUTUP",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              )),
            ])),
      ],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          // db.saveError(
          //     Error("cek_koneksi : 12 ", "", DateTime.now().toString()));

          // fh.cekkoneksi("", token, url_api).then((resulthodate) {
          //   setState(() {
          //     getdata();
          //   });
          // });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  void getdata() {
    db.getError().then((hasils) {
      itemerror.clear();
      setState(() {
        itemerror = hasils;
      });
    });
  }
}
