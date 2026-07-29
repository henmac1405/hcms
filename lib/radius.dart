import 'dart:math';
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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hcms/office.dart';

//tes uploadddd
class RadiusPage extends StatefulWidget {
  final String url_api;
  final String token;
  final String apikey;
  final String databasename;
  const RadiusPage({
    super.key,
    required this.url_api,
    required this.token,
    required this.apikey,
    required this.databasename,
  });
  @override
  _RadiusPageState createState() => _RadiusPageState();
}

class _RadiusPageState extends State<RadiusPage> {
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();
  Map<String, dynamic> closed = {'id': 'CLOSE', 'name': 'CLOSE'};
  final dt = new DateTime.now();
  var newFormat = DateFormat("yyyy-MM-dd");
  var dailyFormat = DateFormat("yyMMdd");
  String _url_api = "";
  String _url_api_lokal = "";
  String _url_api_sync = "";
  TextEditingController _latitudeController = new TextEditingController();
  TextEditingController _longitudeController = new TextEditingController();
  TextEditingController _radiusController = new TextEditingController();
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

  String _selectedOfficeName = "Select Office";
  String _office_id = "";
  String _office_name = "Select Office";
  String _office_lat = "";
  String _office_long = "";
  String _office_location = "";
  String _office_radius = "";
  String _current_lat = "";
  String _current_long = "";
  String _current_location = "";
  String _disctance = "";

  Position? _currentPosition;
  bool isLocation = false;
  double jarak = 0;
  bool isTooFar = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          "DISTANCE",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
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
                isLoading
                    ? LinearProgressIndicator()
                    : Text(
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
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.adjust),
                      // hintText: 'Enter your firs and latname',
                      labelText: 'Latitude'),
                  controller: _latitudeController,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 3,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.adjust),
                      // hintText: 'Enter your firs and latname',
                      labelText: 'Longitude'),
                  controller: _longitudeController,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 3,
                ),
                TextFormField(
                  decoration: const InputDecoration(
                      icon: Icon(Icons.adjust),
                      // hintText: 'Enter your firs and latname',
                      labelText: 'Radius'),
                  controller: _radiusController,
                  keyboardType: TextInputType.number,
                  minLines: 1, //Normal textInputField will be displayed
                  maxLines: 3,
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.only(left: 5, top: 10),
                  child: Row(children: <Widget>[
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () {
                        _navigateToOffice(context);
                      },
                      child: new Text(_office_name),
                    )),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () {
                        _office_lat = _latitudeController.text;
                        _office_long = _longitudeController.text;
                        _office_radius = _radiusController.text;
                        if (_office_lat == "") {
                          _showDialogWarning("latitude kosong");
                        } else if (_office_long == "") {
                          _showDialogWarning("longitude kosong");
                        } else if (_office_radius == "") {
                          _showDialogWarning("radius kosong");
                        } else {
                          setState(() {
                            isLoading = true;
                          });
                          _getAddressFromOffice(double.parse(_office_lat),
                              double.parse(_office_long));
                        }
                      },
                      child: new Text("Get Address"),
                    )),
                  ]),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Office Address : " + _office_location,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                    padding: EdgeInsets.only(left: 5, top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        onPrimary: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _current_lat = "";
                          _current_long = "";
                          _current_location = "";
                          _disctance = "";
                          isLoading = true;
                        });
                        _getCurrentLocation();
                      },
                      child: new Text("CURRENT LOCATION"),
                    )),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Current Koordinate : " +
                      _current_lat +
                      "   " +
                      _current_long,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Current Address : " + _current_location,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Distance : " + _disctance,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: isTooFar ? Colors.red : Colors.green,
                    fontSize: 20.0,
                  ),
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

  _getCurrentLocation() async {
    print('_getAddressFromLatLng2');
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
            forceAndroidLocationManager: false)
        .then((Position position) {
      print('_getAddressFromLatLng');
      setState(() {
        isLocation = true;
        _currentPosition = position;

        _getAddressFromLatLng();
      });
    }).catchError((e) {
      setState(() {
        isLocation = false;
        isLoading = false;
      });
      print(e);
      print('_getAddressFromLatLng');
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude, _currentPosition!.longitude);

      Placemark place = placemarks[0];
      if (_office_lat == "") {
        setState(() {
          _disctance = "-";
        });
      } else {
        jarak = distanceMeter(
            double.parse(_office_lat),
            double.parse(_office_long),
            _currentPosition!.latitude,
            _currentPosition!.longitude);

        setState(() {
          if (jarak > double.parse(_office_radius)) {
            isTooFar = true;
          } else {
            isTooFar = false;
          }
          _disctance = '${jarak.toStringAsFixed(2)} meter';
        });
      }

      setState(() {
        _current_lat = _currentPosition!.latitude.toString();
        _current_long = _currentPosition!.longitude.toString();
        _current_location =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print('strlatitude');
        print(_current_lat);
        print('strlongitude');
        print(_current_long);
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  _getAddressFromOffice(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

      Placemark place = placemarks[0];

      setState(() {
        _office_location =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print('_office_location');
        print(_office_location);
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
      print(e);
    }
  }

  double distanceMeter(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meter

    // Konversi derajat ke radian menggunakan pi / 180
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  void _navigateToOffice(BuildContext context) async {
    String result_id = "";
    String result_name = "";
    int iRadius = 0;
    Map<String, dynamic> result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => OfficePage(
                url_api: widget.url_api,
                apikey: widget.apikey,
                token: widget.token,
                databasename: widget.databasename,
              )),
    );
    print('_navigateToOffice : ');
    print('result : ');
    print(result);
    if (result != null) {
      if (result.length > 0) {
        print('result : ');
        print(result['name']);
        result_id = result['id'];
        result_name = result['name'];
        if (result_id == 'CLOSE') {
          print('CLOSE');
        } else {
          setState(() {
            _office_id = result['id'] ?? "";
            _office_name = result['name'] ?? "";
            _office_lat = result['latitude'] ?? "0";
            _office_long = result['longitude'] ?? "0";
            // _office_radius = result['radius'].toString();
            iRadius = result['radius'];
            _office_radius = iRadius.toString();

            _latitudeController.text = _office_lat;
            _longitudeController.text = _office_long;
            _radiusController.text = _office_radius;
            // url_api = result_id;
            // getconfig();
            // _url_api_sync = result_name;
            // print('_url_api : ' + _url_api);
            // print('_url_api_sync : ' + _url_api_sync);
          });
        }
      }
    }
  }
}
