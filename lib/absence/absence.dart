import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:path/path.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:dio/dio.dart';
import 'package:hcms/dialog/loading_screen.dart';
import 'package:http_parser/http_parser.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:exif/exif.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:camera/camera.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' show join;
import 'package:permission_handler/permission_handler.dart';

// import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class AbsencePage extends StatefulWidget {
  const AbsencePage({
    super.key,
    required this.url_api,
    required this.token,
    required this.type,
    required this.apikey,
    required this.imageslidePaths,
    required this.url_api_slide,
    required this.strdebug,
    // required this.camera,
    // required this.company_id,
    // required this.company_name,
    // required this.listcompany_id,
    // required this.listcompany_remark,
    // required this.employee_idno,
    // required this.employee_name,
  });

  final String url_api;
  final String token;
  final String type;
  final String apikey;
  final List imageslidePaths;
  final String url_api_slide;
  final String strdebug;
  // final CameraDescription camera;
  // final String company_id;
  // final String company_name;
  // final String listcompany_id;
  // final String listcompany_remark;
  // final String employee_idno;
  // final String employee_name;

  @override
  State<AbsencePage> createState() => _AbsencePageState();
}

class _AbsencePageState extends State<AbsencePage> {
  GlobalKey _globalKey = GlobalKey();
  GlobalKey _repaintBoundaryKey = GlobalKey();
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();
  // late CameraController _controller;
  // late Future<void> _initializeControllerFuture;

  List<String> tglcuti = [];

  bool isLoading = false;
  TextEditingController _tanggalcutiController = new TextEditingController();
  TextEditingController _keteranganController = new TextEditingController();
  List imageslidePaths = [];
  String _tanggal = "";
  var newFormat = DateFormat("dd MMM yyyy");
  var tglFormat = DateFormat("dd MMM yyyy HH:mm:ss");
  var dateFormat = DateFormat("dd-MM-yyyy");
  var hourFormat = DateFormat("HH:mm");
  var absenceFormat = DateFormat("yyyy-MM-dd");
  var createFormat = DateFormat("yyyy:MM:dd");
  var imageFormat = DateFormat("yyyyMMddHHmmss");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormatnew = DateFormat("HH:mm:ss");
  var dayFormat = DateFormat("d");
  var yearFormat = DateFormat("yyyy");
  var monthFormat = DateFormat("M");
  final dt = new DateTime.now();
  DateTime now = DateTime.now();
  DateTime lastdate = DateTime.now();

  String dayName = "";
  String dayNameInd = "";
  int dayOfMonth = 0;
  XFile? imageFile;
  String _filename = "Tidak ada file dipilih";
  String _filecamera = "";
  String _cekin = "--:--";
  String _cekout = "--:--";
  String _datefrom = "";
  String _dateend = "";
  String _strdatefrom = "";
  String _strdateend = "";

  String company_id = "";
  String company_name = "";
  String listcompany_id = "";
  String listcompany_remark = "";
  String employee_idno = "";
  String employee_name = "";
  String employee_id = "";
  String employee_personalid = "";
  String employee_fingerid = "";
  String office_id = "";
  String absence_date = "";
  String absence_dateend = "";
  String absence_date_yesterday = "";
  bool ischekin = false;
  bool ischekout = false;
  String absence_description = "ONLINE - Absence From Mobile Application";
  Color cekincolor = Colors.green;
  Color cekoutcolor = Colors.orange;
  Color datefromcolor = Colors.blue;
  Color dateendcolor = Colors.blue;
  String absence_image = "";
  String absence_time = "";
  List absencehistory = [];
  String strabsencehistory = "";
  // String imageuploadUrl =
  //     "https://api-posdev.transentertainment.com/assets/upload/absence";
  String absen_image_url = "http://192.168.0.7/api-ci3/assets/upload/absence/";

  File? _image;

  String employee_gender = "";
  String employee_dateofbirth = "";
  String divisi_name = "";
  String uploadimage_name = "";
  String database_name = "";
  String shift_id = "";
  String shift_id_yesterday = "";
  String daynow = "";
  String dayyesterday = "";
  String _year = "";
  String _month = "";
  String _yearyesterday = "";
  String _monthyesterday = "";
  int shift_samedateout = 0;
  String _strdateAll = "";
  String _keterangan = "";
  String file_created_date = "";
  String daycreate = "";
  String filecreate = "";
  Position? _currentPosition;
  String _currentAddress = "";
  String strlatitude = "";
  String strlongitude = "";
  bool isLocation = false;
  String _strriwayatheader = "";
  String strabsenceonlinehistoryname = "";
  String url_api_root = "";
  String url_api_slide = "";
  String url_api_image = "";
  String device_info = "";
  String strTimeZone = "";
  String office_name = "";
  String company_name2 = "";
  String department_name = "";
  String absence_tin = "";
  String absence_tout = "";
  bool outyesterday = false;
  String employee_type = "";
  String strdebug = "";
  String absence_dateterakhir = "";
  String strabsence_dateterakhir = "";
  String strstatusabsen = "";

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String strremark = "";
  bool _isSwitched = false;
  String strcamera = "Off";
  String imgname = "";

  @override
  void initState() {
    super.initState();
    strTimeZone = DateTime.now().timeZoneName;
    DateTime yesterday = now.subtract(const Duration(days: 1));
    url_api_slide = widget.url_api_slide;
    imageslidePaths = widget.imageslidePaths;
    strdebug = widget.strdebug;
    daynow = dayFormat.format(now);
    dayyesterday = dayFormat.format(yesterday);
    _tanggal = newFormat.format(now);
    // _strdatefrom = newFormat.format(now);
    // _strdateend = newFormat.format(now);
    _year = yearFormat.format(now);
    _month = monthFormat.format(now);
    _yearyesterday = yearFormat.format(yesterday);
    _monthyesterday = monthFormat.format(yesterday);
    absence_date = absenceFormat.format(dt);
    absence_date_yesterday = absenceFormat.format(yesterday);
    dayName = DateFormat('EEEE').format(now);
    daycreate = createFormat.format(now);
    if (widget.type == "ABSEN") {
      _strriwayatheader = "Riwayat Absensi 7 hari terakhir";
      strabsenceonlinehistoryname = "absen/showabsen";
    } else if (widget.type == "CUTI") {
      _strriwayatheader = "Riwayat Cuti/PH 7 hari terakhir";
      strabsenceonlinehistoryname = "absen/showcuti";
    } else if (widget.type == "SAKIT") {
      _strriwayatheader = "Riwayat Sakit/Izin 7 hari terakhir";
      strabsenceonlinehistoryname = "absen/showsakit_izin";
    }

    dayOfMonth = dt.day;
    if (dayName == "Sunday") {
      dayNameInd = "Minggu";
    } else if (dayName == "Monday") {
      dayNameInd = "Senin";
    } else if (dayName == "Tuesday") {
      dayNameInd = "Selasa";
    } else if (dayName == "Wednesday") {
      dayNameInd = "Rabu";
    } else if (dayName == "Thursday") {
      dayNameInd = "Kamis";
    } else if (dayName == "Friday") {
      dayNameInd = "Jumat";
    } else if (dayName == "Saturday") {
      dayNameInd = "Sabtu";
    }
    strstatusabsen = "";
    _getCurrentLocation();
    requestPermission();
    getFromSharedPreferences().then((_) {
      // setting();
      getdata();
      // getabsenterakhir();
      // getabsen();
    });
    // dayNameInd = dayName;
    // isLoading = true;
    // _controller = CameraController(
    //   // Get a specific camera from the list of available cameras.
    //   widget.camera,
    //   // Define the resolution to use.
    //   ResolutionPreset.medium,
    // );
    // _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    // _controller.dispose();
    super.dispose();
  }

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("My title"),
      content: Text("This is my message."),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  _showDialog(String keterangan) async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding: EdgeInsets.all(20.0),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          _refresh();
          // Replace this delay with the code to be executed during refresh
          // and return a Future when code finishes execution.
          return Future<void>.delayed(const Duration(seconds: 2));
        },
        child: ListView(children: <Widget>[
          CarouselSlider.builder(
            itemCount: imageslidePaths.length,
            itemBuilder: (BuildContext context, int index, int realIndex) {
              return Stack(
                children: [
                  Image.network(
                    url_api_slide + imageslidePaths[index]['value'],
                    fit: BoxFit.cover,
                    width: MediaQuery.of(context).size.width,
                    // height: 200,
                  ),
                  Positioned(
                    bottom: 5.0,
                    left: 0,
                    right: 0,
                    child: Container(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TimerBuilder.periodic(Duration(seconds: 1),
                                      builder: (context) {
                                    return Text(
                                      "${getSystemTime()}" + " " + strTimeZone,
                                      textAlign: TextAlign.left,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    );
                                  }),
                                  Text(
                                    dayNameInd + ", " + _tanggal,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.left,
                                  ),
                                ]),
                          ]),
                      color: Colors
                          .black54, // Optional: for better text visibility
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    ),
                  ),
                ],
              );
            },
            options: CarouselOptions(
              viewportFraction: 1.0, // Ensures full width for each item
              // height: MediaQuery.of(context)
              //     .size
              //     .height, // Optional: full height
              autoPlay: true,
              enlargeCenterPage: false,
              padEnds: false,
              initialPage: 0,
            ),
          ),
          RepaintBoundary(
              key: _globalKey,
              child: Center(
                  child: Container(
                      margin: const EdgeInsets.all(5.0),
                      padding: const EdgeInsets.all(5.0),
                      color: Colors.white,
                      // height: 100.0,
                      child: Column(children: <Widget>[
                        // _logo(),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // _logout(),
                        // const SizedBox(
                        //   height: 10,
                        // ),
                        // _tanggaljam(),
                        const SizedBox(
                          height: 10,
                        ),
                        _identitas(),
                        const SizedBox(
                          height: 20,
                        ),
                        if (strdebug == "On") ...[
                          Text(
                            "Debug ON : ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                        if (strdebug == "On") ...[
                          Text(
                            widget.url_api,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                        // _imageupload(),
                        // _imagecamera(),
                        widget.type == "ABSEN"
                            ? _imagecamera()
                            : _imageupload(),
                        widget.type == "ABSEN" ? _buttoncamera() : Container(),
                        // _buttoncamera(),
                        const SizedBox(
                          height: 20,
                        ),
                        widget.type == "ABSEN" ? _absensi() : Container(),

                        widget.type == "ABSEN" ? _jamabsensi() : Container(),

                        widget.type == "ABSEN" ? Container() : _datefromend(),
                        const SizedBox(
                          height: 30,
                        ),
                        if (strstatusabsen != "") ...[
                          Text(
                            strstatusabsen,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                        TextFormField(
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                  // borderRadius:
                                  //     BorderRadius.all(Radius.circular(20.0)),
                                  ),

                              // hintText: 'Enter your firs and latname',
                              labelText: 'Keterangan'),
                          controller: _keteranganController,

                          minLines: 1, //Normal textInputField will be displayed
                          maxLines: 3,
                          readOnly: false,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        widget.type == "CUTI" ? _cutibutton() : Container(),
                        widget.type == "SAKIT"
                            ? _sakitizinbutton()
                            : Container(),

                        // _keterangan(),
                        const SizedBox(
                          height: 20,
                        ),

                        _riwayatabsenheader(),
                        const SizedBox(
                          height: 10,
                        ),
                        // _riwayatabsen(),
                        widget.type == "ABSEN"
                            ? _gridriwayatabsen()
                            : _gridriwayatcutisakitizin(),
                        const SizedBox(
                          height: 100,
                        ),
                      ]))))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pop(context);
          // _uploaddio();
          // _captureAndSave();
          // _uploaddioNew();
          // getabsenterakhir();

          // getabsen();
          // getabsenhistory();
          // getabsenyesterday();
          // getdata();
          // FullscreenImageViewer.open(
          //   context: context,
          //   child: child,
          // );
          // print('_showFullScreenImageDialog');
          // _showFullScreenImageDialog(context, "");
          // getabsen();
          // getabsenhistory();
          // uploadImage(_image!, imageuploadUrl);
          // uploadImageToServer();
        },
        tooltip: 'OUT',
        child: const Icon(Icons.arrow_back),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _logo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 15.0, right: 20.0, top: 5.0),
        ),
        // ImageAsset(strimage: AssetImage('graphics/background.png')),
        // Image.asset('images/cat.png'),
        // ImageAsset.Image(image: 'assets/hillpark.png'),
        // ImageAsset.Image.asset('assets/hillpark.png'),
        isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.access_time_filled),
                  SizedBox(width: 8),
                  Text(
                    'Absensi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ],
    );
  }

  Widget _logout() {
    return Container(
        padding: EdgeInsets.fromLTRB(20, 5, 20, 10),
        child: Column(children: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              side: BorderSide(
                color: Colors.grey, // Your desired border color
                width: 2.0, // Your desired border width
              ),
              // minimumSize: Size(50.0, 50.0),
              backgroundColor: Colors.white,

              onPrimary: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              // Define the action to perform when the button is pressed
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back), // The icon to display
            label: const Text('Logout'), // The text label for the button
          ),
        ]));
  }

  Widget _tanggaljam() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 76, 85, 250),
        border: Border.all(width: 8, color: Color.fromARGB(255, 76, 85, 250)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            // This Column is a child of the Row
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TimerBuilder.periodic(Duration(seconds: 1), builder: (context) {
                return Text(
                  "${getSystemTime()}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                );
              }),
              Text(
                "WIB",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(
            width: 30,
          ),
          Column(
            // This Column is a child of the Row
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                _tanggal,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700),
              ),
              Text(
                dayNameInd,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _identitas() {
    return Container(
        // height: 80,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 2, 8, 134),
          border: Border.all(
            width: 8,
            color: Color.fromARGB(255, 2, 8, 134),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Column(
              // This Column is a child of the Row
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(" " + employee_name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                Text("  " + company_name2,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text(
                    "  " +
                        office_name +
                        " - " +
                        divisi_name +
                        " (" +
                        department_name +
                        ")",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text("  " + employee_personalid,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text("  " + employee_gender.capitalize(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Text("  " + employee_dateofbirth,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ])
        ]));
  }

  Widget _imageupload() {
    return Column(
      children: <Widget>[
        // Padding(
        //   padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
        //   child: const Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       Icon(Icons.photo_camera),
        //       SizedBox(width: 8),
        //       Text('Upload Gambar'),
        //     ],
        //   ),
        // ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 2, 8, 134),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Sets a circular border radius of 20
                  ),
                ),
                onPressed: () {
                  _openGallery();
                },
                child: Text("Upload Foto"),
              ),
              SizedBox(width: 8),
              Text(_filename),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imagecamera() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        RepaintBoundary(
          key: _repaintBoundaryKey,
          child: Stack(
            // Your Stack widget
            alignment: Alignment.center,
            children: [
              _imageFile != null
                  ? Image.file(_imageFile!, fit: BoxFit.cover)
                  : const Text(''),
              Positioned(
                // bottom: 20.0,
                top: 0,
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.only(
                              left: 20, right: 15, top: 0.0, bottom: 0.0),
                          child: Text(
                            strremark,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ]), // Optional: for better text visibility
                  // padding:
                  //     EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                ),
              ),
              Positioned(
                bottom: 0.0,
                child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          padding: EdgeInsets.all(0.0),
                          child: Text(
                            "Transentertainment     Transentertainment     Transentertainment     Transentertainment",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 7.0,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]), // Optional: for better text visibility
                  // padding:
                  //     EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _showcamera() {
  //   return Column(
  //     children: <Widget>[
  //       const SizedBox(
  //         height: 5,
  //       ),
  //       // if (strcamera == "On") ...[
  //       FutureBuilder<void>(
  //         future: _initializeControllerFuture,
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             // If the Future is complete, display the preview.
  //             return RepaintBoundary(
  //               key: _repaintBoundaryKey,
  //               child: Stack(
  //                 children: <Widget>[
  //                   CameraPreview(_controller), // Camera feed as the base layer
  //                   Positioned(
  //                     // bottom: 20.0,
  //                     top: 0,
  //                     child: Container(
  //                       child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: <Widget>[
  //                             Container(
  //                               width: MediaQuery.of(context).size.width,
  //                               padding: EdgeInsets.all(8.0),
  //                               child: Text(
  //                                 strremark,
  //                                 style: TextStyle(
  //                                     color: Colors.white,
  //                                     fontSize: 12.0,
  //                                     fontWeight: FontWeight.w700),
  //                                 textAlign: TextAlign.left,
  //                               ),
  //                             ),
  //                           ]), // Optional: for better text visibility
  //                       // padding:
  //                       //     EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     bottom: 0.0,
  //                     child: Container(
  //                       child: Row(
  //                           mainAxisAlignment: MainAxisAlignment.start,
  //                           children: <Widget>[
  //                             Container(
  //                               width: MediaQuery.of(context).size.width,
  //                               padding: EdgeInsets.all(0.0),
  //                               child: Text(
  //                                 "Transentertainment     Transentertainment     Transentertainment     Transentertainment",
  //                                 style: TextStyle(
  //                                     color: Colors.white,
  //                                     fontSize: 8.0,
  //                                     fontWeight: FontWeight.w700),
  //                                 textAlign: TextAlign.center,
  //                               ),
  //                             ),
  //                           ]), // Optional: for better text visibility
  //                       // padding:
  //                       //     EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           } else {
  //             // Otherwise, display a loading indicator.
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //         },
  //       ),
  //       // ],
  //       const SizedBox(
  //         height: 5,
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Switch(
  //             value: _isSwitched,
  //             onChanged: (newValue) {
  //               DateTime now = DateTime.now();
  //               String tglRemark = tglFormat.format(now);
  //               setState(() {
  //                 _isSwitched = newValue;
  //                 if (_isSwitched == true) {
  //                   // _isSwitched = false;
  //                   strcamera = "On";
  //                   // url_api = url_api_dev;
  //                   // urlschemaroot();
  //                   updateremark();
  //                 } else {
  //                   // _isSwitched = false;
  //                   strcamera = "Off";
  //                   // url_api = url_api_prod;
  //                   // urlschemaroot();
  //                 }
  //               });
  //               // You can add logic here based on the new switch state
  //               print('Switch state changed to: $newValue');
  //             },
  //           ),
  //           Text("Camera " + strcamera),
  //           // Spacer(),
  //           // if (strcamera == "On") ...[
  //           //   IconButton(
  //           //     icon: Icon(Icons.flip_camera_ios), // The icon to display
  //           //     iconSize: 30.0, // Optional: customize icon size
  //           //     color: Color.fromARGB(
  //           //         255, 2, 8, 134), // Optional: customize icon color
  //           //     onPressed: () {
  //           //       // This function will be executed when the IconButton is pressed
  //           //       print('Favorite icon pressed!');
  //           //       // You can add any logic here, like navigating to another screen,
  //           //       // updating state, showing a dialog, etc.
  //           //     },
  //           //   ),
  //           // ]
  //           // IconButton(
  //           //     onPressed: () {
  //           //       _navigateToCekKoneksi(context);
  //           //     },
  //           //     icon: Icon(Icons.settings)),
  //         ],
  //       ),
  //     ],
  //   );
  // }

  Widget _buttoncamera() {
    return Column(
      children: <Widget>[
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ElevatedButton.icon(
                icon: const Icon(Icons.camera),
                label: const Text('Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 2, 8, 134),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10), // Sets a circular border radius of 20
                  ),
                ),
                onPressed: () {
                  // _openGallery();

                  _takePicture();
                },
              ),
              SizedBox(width: 8),
              Text(_filename),
            ],
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       ElevatedButton.icon(
        //         icon: const Icon(Icons.save),
        //         label: const Text('Save'),
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Color.fromARGB(255, 2, 8, 134),
        //           onPrimary: Colors.white,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(
        //                 10), // Sets a circular border radius of 20
        //           ),
        //         ),
        //         onPressed: () {
        //           // _openGallery();
        //           // _takePicture();
        //           _captureAndSave();
        //         },
        //       ),
        //       SizedBox(width: 8),
        //     ],
        //   ),
        // ),
        // Padding(
        //   padding: EdgeInsets.only(left: 5, right: 5, top: 0.0, bottom: 0.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     children: <Widget>[
        //       ElevatedButton.icon(
        //         icon: const Icon(Icons.save),
        //         label: const Text('Upload'),
        //         style: ElevatedButton.styleFrom(
        //           backgroundColor: Color.fromARGB(255, 2, 8, 134),
        //           onPrimary: Colors.white,
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(
        //                 10), // Sets a circular border radius of 20
        //           ),
        //         ),
        //         onPressed: () {
        //           // _openGallery();
        //           // _takePicture();
        //           _uploaddioNew();
        //         },
        //       ),
        //       SizedBox(width: 8),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _absensi() {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width,
      // width: 150,
      child: Row(children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cekincolor,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    20), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              // _captureAndSave();
              if (ischekin == false) {
                if (_filename == "Tidak ada file dipilih") {
                  _showDialog("Belum ada foto dibuat");
                } else {
                  // if (filecreate != daycreate) {
                  //   _showDialog("Absen Gagal, harap perbaharui foto anda");
                  // } else {
                  // _captureAndSave();
                  insertabsenceonline("IN");
                  // }
                }
              } else {}
            },
            child: const Text('IN'),
          ),
        ),
        const SizedBox(
          height: 30,
          width: 50,
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cekoutcolor,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    20), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              setState(() {
                if (ischekout == false) {
                  if (_filename == "Tidak ada file dipilih") {
                    _showDialog("Belum ada foto dibuat");
                  } else {
                    // if (filecreate != daycreate) {
                    //   _showDialog("Absen Gagal, harap perbaharui foto anda");
                    // } else {
                    // if (shift_samedateout == 0) {
                    if (ischekin == false) {
                      _showDialog("Belum Cek In");
                    } else {
                      insertabsenceonline("OUT");
                    }
                    // } else {
                    //   insertabsenceonline("OUT");
                    // }
                    // }
                  }
                } else {}
              });
            },
            child: const Text('OUT'),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ]),
    );
  }

  Widget _jamabsensi() {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width,
      // width: 150,
      child: Row(children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                // This Column is a child of the Row
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Masuk",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _cekin,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
          width: 50,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                // This Column is a child of the Row
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "Keluar",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.orange,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                  Text(
                    _cekout,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ]),
    );
  }

  Widget _datefromend() {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width,
      // width: 150,
      child: Row(children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                // This Column is a child of the Row
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: datefromcolor,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Sets a circular border radius of 20
                      ),
                    ),
                    onPressed: () {
                      _chooseDate(context, _datefrom, "datefrom");
                    },
                    child: const Text('Tanggal Awal'),
                  ),
                  Text(
                    _strdatefrom,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
          width: 50,
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Column(
                // This Column is a child of the Row
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: datefromcolor,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            20), // Sets a circular border radius of 20
                      ),
                    ),
                    onPressed: () {
                      _chooseDate(context, _dateend, "dateend");
                    },
                    child: const Text('Tanggal Akhir'),
                  ),
                  Text(
                    _strdateend,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
      ]),
    );
  }

  Widget _cutibutton() {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width,
      // width: 150,
      child: Row(children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              // if (ischekin == false) {
              if (_filename == "Tidak ada file dipilih") {
                _showDialog("Tidak ada file dipilih");
              } else if (_keterangan == "") {
                _showDialog("Keterangan belum diisi");
                // } else if (filecreate != daycreate) {
                //   _showDialog("harap perbaharui foto anda");
              } else if (_datefrom == "") {
                _showDialog("Tanggal Awal belum dipilih");
              } else if (_dateend == "") {
                _showDialog("Tanggal Akhir belum dipilih");
              } else {
                insertabsenceonline("CUTI");
              }
              // } else {}
            },
            child: Text("CUTI"),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              // if (ischekin == false) {
              if (_filename == "Tidak ada file dipilih") {
                _showDialog("Tidak ada file dipilih");
              } else if (_keterangan == "") {
                _showDialog("Keterangan belum diisi");
                // } else if (filecreate != daycreate) {
                //   _showDialog("Harap perbaharui foto anda");
              } else if (_datefrom == "") {
                _showDialog("Tanggal Awal belum dipilih");
              } else if (_dateend == "") {
                _showDialog("Tanggal Akhir belum dipilih");
              } else {
                insertabsenceonline("PH");
              }
              // } else {}
            },
            child: Text("PENGGANTI HARI"),
          ),
        ),
      ]),
    );
  }

  Widget _sakitizinbutton() {
    return Container(
      width: MediaQuery.of(context).copyWith().size.width,
      // width: 150,
      child: Row(children: <Widget>[
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[400],
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              // if (ischekin == false) {
              if (_filename == "Tidak ada file dipilih") {
                _showDialog("Tidak ada file dipilih");
              } else if (_keterangan == "") {
                _showDialog("Keterangan belum diisi");
                // } else if (filecreate != daycreate) {
                //   _showDialog("Harap perbaharui foto anda");
              } else if (_datefrom == "") {
                _showDialog("Tanggal Awal belum dipilih");
              } else if (_dateend == "") {
                _showDialog("Tanggal Akhir belum dipilih");
              } else {
                insertabsenceonline("SAKIT");
              }
              // } else {}
            },
            child: Text("SAKIT"),
          ),
        ),
        SizedBox(
          width: 50,
        ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Sets a circular border radius of 20
              ),
            ),
            onPressed: () {
              _keterangan = _keteranganController.text;
              // if (ischekin == false) {
              if (_filename == "Tidak ada file dipilih") {
                _showDialog("Tidak ada file dipilih");
              } else if (_keterangan == "") {
                _showDialog("Keterangan belum diisi");
                // } else if (filecreate != daycreate) {
                //   _showDialog("Harap perbaharui foto anda");
              } else if (_datefrom == "") {
                _showDialog("Tanggal Awal belum dipilih");
              } else if (_dateend == "") {
                _showDialog("Tanggal Akhir belum dipilih");
              } else {
                insertabsenceonline("IZIN");
              }
              // } else {}
            },
            child: Text("IZIN"),
          ),
        ),
      ]),
    );
  }

  Widget _riwayatabsenheader() {
    return Column(
      children: <Widget>[
        Padding(
          padding:
              EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Icon(Icons.access_time_filled),
              SizedBox(width: 8),
              Text(_strriwayatheader,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _riwayatabsen() {
    String historyname = "";
    String image_url = "";
    String strhistory_date = "";
    String strhistory_dateformat = "";
    String strhistory_time = "";
    String strhistory_image = "";
    String strhistory_method = "";
    DateTime historydate = DateTime.now();
    String strhistory_descr = "";

    return Center(
      child: ListView.builder(
          shrinkWrap: true,
          physics: ScrollPhysics(),
          itemCount: absencehistory == null ? 0 : absencehistory.length,

          //padding: const EdgeInsets.all(15.0),
          itemBuilder: (context, index) {
            // print('list_struk.length');
            // print(absencehistory[index]['iteminventory_name']);
            strhistory_method = absencehistory[index]['absence_method'] ?? "";
            strhistory_date = absencehistory[index]['absence_date'] ?? "";
            historydate = DateTime.parse(strhistory_date);
            strhistory_dateformat = dateFormat.format(historydate);

            if (strhistory_method == "IN") {
              strhistory_time = absencehistory[index]['absence_oin'] ?? "";
              strhistory_image = absencehistory[index]['absence_imagein'] ?? "";
              strhistory_descr =
                  absencehistory[index]['absence_description'] ?? "";
            } else {
              strhistory_time = absencehistory[index]['absence_oout'] ?? "";
              strhistory_image =
                  absencehistory[index]['absence_imageout'] ?? "";
              strhistory_descr = "";
            }

            // if (strhistory_time.length > 5) {
            //   strhistory_time =
            //       absencehistory[index]['absence_time'].substring(0, 8);
            // } else {
            //   strhistory_time = strhistory_time;
            // }
            // if (strhistory_date.length > 8) {
            //   strhistory_date =
            //       absencehistory[index]['absence_date'].substring(8, 10) +
            //           "-" +
            //           absencehistory[index]['absence_date'].substring(5, 7) +
            //           "-" +
            //           absencehistory[index]['absence_date'].substring(0, 4);
            // } else {
            //   strhistory_date = strhistory_date;
            // }

            historyname = strhistory_dateformat +
                "      " +
                strhistory_time +
                "      " +
                strhistory_method +
                "      " +
                strhistory_descr;
            image_url = url_api_image + strhistory_image;
            // print(image_url);

            return Column(
              children: <Widget>[
                Divider(height: 5.0),
                ListTile(
                    title: Text(
                      historyname,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.black,
                      ),
                    ),
                    // leading: Column(
                    //   children: <Widget>[
                    //     Padding(
                    //         padding: EdgeInsets.all(10.0)),
                    //     CircleAvatar(
                    //       backgroundColor: Colors.black,
                    //       radius: 15.0,
                    //       child: Text(
                    //         '${items[position].qty}',
                    //         style: TextStyle(
                    //           fontSize: 16.0,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    trailing: Wrap(
                      spacing: 12, // space between two icons
                      children: <Widget>[
                        GestureDetector(
                            child: Icon(Icons.image),
                            onTap: () {
                              // print(url_api_image +
                              //     absencehistory[index]['absence_imagein']);
                              // print(image_url);
                              if (url_api_image == "") {
                                _showDialog("Image Path is Null");
                              } else {
                                if (absencehistory[index]['absence_method'] ==
                                    "OUT") {
                                  _showFullScreenImageDialog(
                                      context,
                                      url_api_image +
                                          absencehistory[index]
                                              ['absence_imageout']);
                                } else {
                                  _showFullScreenImageDialog(
                                      context,
                                      url_api_image +
                                              absencehistory[index]
                                                  ['absence_imagein'] ??
                                          "");
                                }
                              }
                            }), // icon-2
                      ],
                    ),
                    // trailing: GestureDetector(
                    //   child: Icon(Icons.edit),
                    //   onTap: () => _navigateToLog(context, items[position]),
                    // ),

                    onTap: () {}),
              ],
            );
          }),
    );
  }

  Widget _gridriwayatabsen() {
    DateTime historydate = DateTime.now();
    String strhistory_date = "";
    String strhistory_dateformat = "";
    String strhistory_oin = "";
    String strhistory_oout = "";
    String strhistory_reason = "";
    String strhistory_descr = "";
    return Container(
      width: double.infinity,
      child: DataTable(
        horizontalMargin: 0,
        columnSpacing: 15.0,
        headingRowHeight: 0.0,
        dataRowMaxHeight: double.infinity,
        columns: const <DataColumn>[
          DataColumn(label: Text('Header 1')),
          DataColumn(label: Text('Header 2')),
          DataColumn(label: Text('Header 1')),
          DataColumn(label: Text('Header 2')),
          DataColumn(label: Text('Header 1')),
        ],
        rows: List<DataRow>.generate(absencehistory.length, (index) {
          strhistory_oin = absencehistory[index]['absence_oin'] ?? "";
          strhistory_oout = absencehistory[index]['absence_oout'] ?? "";
          strhistory_reason = absencehistory[index]['absence_reason'] ?? "";
          strhistory_descr = absencehistory[index]['absence_description'] ?? "";
          if (strhistory_descr == "H") {
            strhistory_descr = "Hadir";
          } else if (strhistory_descr == "HL") {
            strhistory_descr = "Hadir Terlambat";
          }
          return DataRow(
            cells: [
              DataCell(Container(
                  child: Text(dateFormat.format(
                      DateTime.parse(absencehistory[index]['absence_date']))))),
              DataCell(absencehistory[index]['absence_method'] == "OUT"
                  ? Container(child: Text(strhistory_oout))
                  : Container(
                      child: Text(strhistory_oin + " " + strhistory_reason))),
              DataCell(
                  absencehistory[index]['absence_method'] == "IN"
                      ? Container(
                          width: 30,
                          color: Colors.green,
                          child: Text(
                            absencehistory[index]['absence_method'] ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors
                                  .white, // Using a predefined color from Colors class
                            ),
                          ))
                      : Container(
                          width: 30,
                          color: Colors.red,
                          child: Text(
                            absencehistory[index]['absence_method'] ?? "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors
                                  .white, // Using a predefined color from Colors class
                            ),
                          )), onTap: () {
                if (url_api_image == "") {
                  _showDialog("Image Path is Null");
                } else {
                  if (absencehistory[index]['absence_method'] == "OUT") {
                    _showFullScreenImageDialog(
                        context,
                        url_api_image +
                            absencehistory[index]['absence_imageout']);
                  } else {
                    _showFullScreenImageDialog(
                        context,
                        url_api_image +
                                absencehistory[index]['absence_imagein'] ??
                            "");
                  }
                }
              }),
              DataCell(
                  absencehistory[index]['absence_method'] == "IN"
                      ? Container(child: Text(strhistory_descr, maxLines: 3))
                      : Text(""), onTap: () {
                if (url_api_image == "") {
                  _showDialog("Image Path is Null");
                } else {
                  if (absencehistory[index]['absence_method'] == "OUT") {
                    _showFullScreenImageDialog(
                        context,
                        url_api_image +
                            absencehistory[index]['absence_imageout']);
                  } else {
                    _showFullScreenImageDialog(
                        context,
                        url_api_image +
                                absencehistory[index]['absence_imagein'] ??
                            "");
                  }
                }
              }),
              DataCell(Container(
                child: IconButton(
                  onPressed: () {
                    if (url_api_image == "") {
                      _showDialog("Image Path is Null");
                    } else {
                      if (absencehistory[index]['absence_method'] == "OUT") {
                        _showFullScreenImageDialog(
                            context,
                            url_api_image +
                                absencehistory[index]['absence_imageout']);
                      } else {
                        _showFullScreenImageDialog(
                            context,
                            url_api_image +
                                    absencehistory[index]['absence_imagein'] ??
                                "");
                      }
                    }
                  },
                  icon: Icon(
                    Icons.image,
                  ),
                ),
              )),
            ],
          );
        }),
      ),
    );
  }

  // Widget _gridriwayatabsen_() {
  //   DateTime historydate = DateTime.now();
  //   String strhistory_date = "";
  //   String strhistory_dateformat = "";
  //   String strhistory_oin = "";
  //   String strhistory_oout = "";
  //   String strhistory_reason = "";
  //   String strhistory_descr = "";
  //   return Column(
  //     children: <Widget>[
  //       SingleChildScrollView(
  //           scrollDirection: Axis.vertical,
  //           child: SingleChildScrollView(
  //               scrollDirection: Axis.horizontal,
  //               child: DataTable(
  //                 horizontalMargin: 0,
  //                 columnSpacing: 15.0,
  //                 headingRowHeight: 0.0,
  //                 dataRowMaxHeight: double.infinity,
  //                 columns: [
  //                   DataColumn(
  //                     label: Text(""),
  //                   ),
  //                   DataColumn(
  //                     label: Text(""),
  //                   ),
  //                   DataColumn(
  //                     label: Text(""),
  //                   ),
  //                   DataColumn(
  //                     label: Text(""),
  //                   ),
  //                   DataColumn(
  //                     label: Text(""),
  //                   ),
  //                 ],
  //                 rows: List<DataRow>.generate(absencehistory.length, (index) {
  //                   strhistory_oin = absencehistory[index]['absence_oin'] ?? "";
  //                   strhistory_oout =
  //                       absencehistory[index]['absence_oout'] ?? "";
  //                   strhistory_reason =
  //                       absencehistory[index]['absence_reason'] ?? "";
  //                   strhistory_descr =
  //                       absencehistory[index]['absence_description'] ?? "";
  //                   if (strhistory_descr == "H") {
  //                     strhistory_descr = "Hadir";
  //                   } else if (strhistory_descr == "HL") {
  //                     strhistory_descr = "Hadir Terlambat";
  //                   }
  //                   return DataRow(
  //                     cells: [
  //                       DataCell(Container(
  //                           width: 80,
  //                           child: Text(dateFormat.format(DateTime.parse(
  //                               absencehistory[index]['absence_date']))))),
  //                       DataCell(absencehistory[index]['absence_method'] ==
  //                               "OUT"
  //                           ? Container(width: 60, child: Text(strhistory_oout))
  //                           : Container(
  //                               width: 60,
  //                               child: Text(
  //                                   strhistory_oin + "" + strhistory_reason))),
  //                       DataCell(absencehistory[index]['absence_method'] == "IN"
  //                           ? Container(
  //                               width: 30,
  //                               color: Colors.green,
  //                               child: Text(
  //                                 absencehistory[index]['absence_method'] ?? "",
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(
  //                                   color: Colors
  //                                       .white, // Using a predefined color from Colors class
  //                                 ),
  //                               ))
  //                           : Container(
  //                               width: 30,
  //                               color: Colors.red,
  //                               child: Text(
  //                                 absencehistory[index]['absence_method'] ?? "",
  //                                 textAlign: TextAlign.center,
  //                                 style: TextStyle(
  //                                   color: Colors
  //                                       .white, // Using a predefined color from Colors class
  //                                 ),
  //                               ))),
  //                       DataCell(absencehistory[index]['absence_method'] == "IN"
  //                           ? Container(
  //                               width: 75,
  //                               child: Text(strhistory_descr, maxLines: 3))
  //                           : Text("")),
  //                       DataCell(Container(
  //                         width: 30,
  //                         child: IconButton(
  //                           onPressed: () {
  //                             if (url_api_image == "") {
  //                               _showDialog("Image Path is Null");
  //                             } else {
  //                               if (absencehistory[index]['absence_method'] ==
  //                                   "OUT") {
  //                                 _showFullScreenImageDialog(
  //                                     context,
  //                                     url_api_image +
  //                                         absencehistory[index]
  //                                             ['absence_imageout']);
  //                               } else {
  //                                 _showFullScreenImageDialog(
  //                                     context,
  //                                     url_api_image +
  //                                             absencehistory[index]
  //                                                 ['absence_imagein'] ??
  //                                         "");
  //                               }
  //                             }
  //                           },
  //                           icon: Icon(
  //                             Icons.image,
  //                           ),
  //                         ),
  //                       )),
  //                     ],
  //                   );
  //                 }),
  //               ))),
  //       SizedBox(
  //         width: 20.0,
  //         height: 20.0,
  //       ),
  //     ],
  //   );
  // }

  Widget _gridriwayatcutisakitizin() {
    DateTime historydate = DateTime.now();
    String strhistory_date = "";
    String strhistory_dateformat = "";
    return Container(
        width: double.infinity,
        child: DataTable(
          horizontalMargin: 0,
          columnSpacing: 15.0,
          headingRowHeight: 0.0,
          dataRowMinHeight: 48.0, // Set minimum row height
          dataRowMaxHeight: double.infinity,
          columns: [
            DataColumn(
              label: Text(""),
            ),
            DataColumn(
              label: Text(""),
            ),
            DataColumn(
              label: Text(""),
            ),
            DataColumn(
              label: Text(""),
            ),
            DataColumn(
              label: Text(""),
            ),
          ],
          rows: List<DataRow>.generate(absencehistory.length, (index) {
            return DataRow(
              cells: [
                DataCell(Container(
                    child: Text(dateFormat.format(DateTime.parse(
                        absencehistory[index]['absence_date']))))),
                DataCell(Container(
                    child:
                        Text(absencehistory[index]['absence_reason'] ?? ""))),
                DataCell(
                    absencehistory[index]['absence_method'] == "SAKIT"
                        ? Container(
                            width: 50,
                            color: Colors.blue[400],
                            child: Text(
                              absencehistory[index]['absence_method'] ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors
                                    .white, // Using a predefined color from Colors class
                              ),
                            ))
                        : absencehistory[index]['absence_method'] == "IZIN"
                            ? Container(
                                width: 50,
                                color: Colors.orange,
                                child: Text(
                                  absencehistory[index]['absence_method'] ?? "",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors
                                        .white, // Using a predefined color from Colors class
                                  ),
                                ))
                            : absencehistory[index]['absence_method'] == "CUTI"
                                ? Container(
                                    width: 50,
                                    color: Colors.blue[400],
                                    child: Text(
                                      absencehistory[index]['absence_method'] ??
                                          "",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Using a predefined color from Colors class
                                      ),
                                    ))
                                : absencehistory[index]['absence_method'] ==
                                        "PH"
                                    ? Container(
                                        width: 50,
                                        color: Colors.orange,
                                        child: Text(
                                          absencehistory[index]
                                                  ['absence_method'] ??
                                              "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Using a predefined color from Colors class
                                          ),
                                        ))
                                    : Container(
                                        width: 50,
                                        color: Colors.grey,
                                        child: Text(
                                          absencehistory[index]
                                                  ['absence_method'] ??
                                              "",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors
                                                .white, // Using a predefined color from Colors class
                                          ),
                                        )), onTap: () {
                  if (url_api_image == "") {
                    _showDialog("Image Path is Null");
                  } else {
                    if (absencehistory[index]['absence_method'] == "OUT") {
                      _showFullScreenImageDialog(
                          context,
                          url_api_image +
                              absencehistory[index]['absence_imageout']);
                    } else {
                      _showFullScreenImageDialog(
                          context,
                          url_api_image +
                                  absencehistory[index]['absence_imagein'] ??
                              "");
                    }
                  }
                }),
                DataCell(
                    absencehistory[index]['absence_method'] == "IN"
                        ? Container(
                            child: Text(
                                absencehistory[index]['absence_description'] ??
                                    "",
                                maxLines: 3))
                        : Text(""), onTap: () {
                  if (url_api_image == "") {
                    _showDialog("Image Path is Null");
                  } else {
                    if (absencehistory[index]['absence_method'] == "OUT") {
                      _showFullScreenImageDialog(
                          context,
                          url_api_image +
                              absencehistory[index]['absence_imageout']);
                    } else {
                      _showFullScreenImageDialog(
                          context,
                          url_api_image +
                                  absencehistory[index]['absence_imagein'] ??
                              "");
                    }
                  }
                }),
                DataCell(Container(
                  child: IconButton(
                    onPressed: () {
                      if (url_api_image == "") {
                        _showDialog("Image Path is Null");
                      } else {
                        if (absencehistory[index]['absence_method'] == "OUT") {
                          _showFullScreenImageDialog(
                              context,
                              url_api_image +
                                  absencehistory[index]['absence_imageout']);
                        } else {
                          _showFullScreenImageDialog(
                              context,
                              url_api_image +
                                      absencehistory[index]
                                          ['absence_imagein'] ??
                                  "");
                        }
                      }
                    },
                    icon: Icon(
                      Icons.image,
                    ),
                  ),
                )),
              ],
            );
          }),
        ));
  }

  static String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("H:m:s").format(now);
  }

  Future<int> getFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      listcompany_id = prefs.getString("listcompany_id") ?? "";
      listcompany_remark = prefs.getString("listcompany_remark") ?? "";
      employee_idno = prefs.getString("employee_idno") ?? "";
      company_id = prefs.getString("company_id") ?? "";
      company_name = prefs.getString("company_name") ?? "";
      employee_id = prefs.getString("employee_id") ?? "";
      employee_name = prefs.getString("employee_name") ?? "";
      employee_personalid = prefs.getString("employee_personalid") ?? "";
      employee_fingerid = prefs.getString("employee_fingerid") ?? "";
      office_id = prefs.getString("office_id") ?? "";
      employee_dateofbirth = prefs.getString("employee_dateofbirth") ?? "";
      employee_gender = prefs.getString("employee_gender") ?? "";
      divisi_name = prefs.getString("divisi_name") ?? "";
      database_name = prefs.getString("database_name") ?? "";
      shift_id = prefs.getString("shift_id") ?? "";
      url_api_slide = prefs.getString("url_api_slide") ?? "";
      url_api_image = prefs.getString("url_api_image") ?? "";
      device_info = prefs.getString("device_info") ?? "";
      department_name = prefs.getString("department_name") ?? "";
      office_name = prefs.getString("office_name") ?? "";
      company_name2 = prefs.getString("company_name2") ?? "";
      employee_type = prefs.getString("employee_type") ?? "";
    });
    return 0;
  }

  void insertabsenceonline(String absence_method) {
    updateremark();
    setState(() {
      // isLoading = true;
    });
    showLoadingDialog("Simpan Data...", context);
    //LoadingScreen.instance().show(context: context, text: "Save Data...");
    now = DateTime.now();
    absence_date = absenceFormat.format(now);
    absence_time = hourFormatnew.format(now);
    absence_image = employee_id + "_" + imageFormat.format(now) + ".jpg";
    uploadimage_name = employee_id + "_" + imageFormat.format(now);
    if (absence_method == "OUT") {
      if (outyesterday == true) {
        absence_date = absence_date_yesterday;
        if (shift_samedateout == 0) {
          absence_time = "23:59:59";
        }
      }
    }
    fh
        .absenceonline_insert(
            database_name,
            employee_id,
            listcompany_id,
            company_id,
            office_id,
            employee_personalid,
            employee_fingerid,
            employee_name,
            absence_method,
            absence_time,
            absence_date,
            absence_image,
            absence_description,
            employee_type,
            _keterangan,
            absence_dateend,
            strlongitude,
            strlatitude,
            device_info,
            "ANDROID MOBILE APPS",
            widget.apikey,
            widget.token,
            "absen/insert",
            widget.url_api)
        .then((hasils) async {
      print(hasils);
      hideLoadingDialog(context);
      if (hasils == "sukses") {
        setState(() {
          isLoading = false;

          _datefrom = "";
          _dateend = "";
          _strdatefrom = "";
          _strdateend = "";
          _keterangan = "";
          _keteranganController = TextEditingController(text: "");
          absence_date = absenceFormat.format(dt);
          if (widget.type == "ABSEN") {
            _captureAndSave();
          } else {
            _uploaddio();
          }
        });
      } else {
        _cekin = "--:--";
        _cekout = "--:--";
        ischekin = false;
        ischekout = false;
        showLoadingDialog("Data Gagal tersimpan...", context);
        await Future.delayed(
            const Duration(seconds: 2)); // waiting for a second
        hideLoadingDialog(context);
        _showDialog(hasils);
      }
      //LoadingScreen.instance().hide();

      // if (hasils == "sukses") {
      //   setState(() {
      //     if (absence_method == "IN") {
      //       ischekin = true;
      //     } else {
      //       ischekout = true;
      //     }
      //     isLoading = false;
      //     _filename = "Tidak ada file dipilih";
      //     _uploaddio();
      //   });
      // } else {
      //   _showDialog(hasils);
      // }
    });
  }

  void getdata() {
    setState(() {
      _cekin = "--:--";
      _cekout = "--:--";
      ischekin = false;
      ischekout = false;
      cekincolor = Colors.green;
      cekoutcolor = Colors.orange;
      strstatusabsen = "";
    });

    //LoadingScreen.instance().show(context: context, text: "Load Data Shift...");
    // showLoadingDialog("Load Data...", context);
    if (widget.type == "ABSEN") {
      getabsen();
    } else {
      // hideLoadingDialog(context);
      getabsenhistory();
    }
  }

  void getabsenold() {
    setState(() {
      // isLoading = true;
    });
    showLoadingDialog("Load Data...", context);
    //LoadingScreen.instance().show(context: context, text: "Load Data Absence...");
    fh
        .absen_show(database_name, employee_id, employee_fingerid, absence_date,
            widget.apikey, widget.token, "absen/show", widget.url_api)
        .then((hasils) {
      hideLoadingDialog(context);
      print(hasils);
      if (hasils.length > 0) {
        hasils.forEach((rows) {
          setState(() {
            absence_tin = rows['absence_oin'] ?? "";
            absence_tout = rows['absence_oout'] ?? "";

            if (absence_tin == "" || absence_tin == "00:00:00") {
              _cekin = "--:--";
              ischekin = false;
              cekincolor = Colors.green;
            } else {
              _cekin = absence_tin;
              ischekin = true;
              cekincolor = Colors.grey;
            }

            if (absence_tout == "" || absence_tout == "00:00:00") {
              _cekout = "--:--";
              ischekout = false;
              cekoutcolor = Colors.orange;
            } else {
              _cekout = absence_tout;
              ischekout = true;
              cekoutcolor = Colors.grey;
            }

            if (ischekin == true && ischekin == true) {
              print("FULL ABSEN HARI INI");
            }
            // url_api = rows['config1'];
          });
        });
        getabsenhistory();
      } else {
        _cekin = "--:--";
        _cekout = "--:--";
        ischekin = false;
        ischekout = true;
        cekincolor = Colors.green;
        cekoutcolor = Colors.grey;

        getabsenyesterday();
      }
      setState(() {
        isLoading = false;
      });
      // hideLoadingDialog(context);
    });
  }

  void getabsenyesterday() {
    print('getabsenyesterday');
    setState(() {
      // isLoading = true;
    });
    // showLoadingDialog("Load Data...", context);
    //LoadingScreen.instance().show(context: context, text: "Load Data Absence...");
    fh
        .absen_show(
            database_name,
            employee_id,
            employee_fingerid,
            absence_date_yesterday,
            widget.apikey,
            widget.token,
            "absen/show",
            widget.url_api)
        .then((hasils) {
      print(hasils);
      if (hasils.length > 0) {
        hasils.forEach((rows) {
          setState(() {
            absence_tin = rows['absence_oin'] ?? "";
            absence_tout = rows['absence_oout'] ?? "";

            if (absence_tin == "" || absence_tin == "00:00:00") {
              ischekin = false;
              print('ischekin = false');
            } else {
              ischekin = true;
              print('ischekin = true');
            }

            if (absence_tout == "" || absence_tout == "00:00:00") {
              ischekout = false;
              print('ischekout = false');
            } else {
              ischekout = true;
              print('ischekout = true');
            }

            if (ischekin == true && ischekout == false) {
              print("BELUM ABSEN OUT KEMARIN");
              _showDialog(
                  "Anda Belum Melakukan Absen Keluar Kemarin, Segera Lakukan Absen Keluar Dahulu");
              _cekin = "--:--";
              _cekout = "--:--";
              ischekout = false;
              cekincolor = Colors.grey;
              cekoutcolor = Colors.orange;
              outyesterday = true;
              fh
                  .employeeshift(
                      database_name,
                      _yearyesterday,
                      _monthyesterday,
                      employee_id,
                      widget.apikey,
                      widget.token,
                      "employeeshift/show",
                      widget.url_api)
                  .then((resultshift) {
                if (resultshift.isNotEmpty) {
                  resultshift.forEach((value) {
                    shift_id_yesterday =
                        value['employeeshift_' + dayyesterday] ?? "";
                    print('SHIFT ID : ');
                    print(value['employeeshift_' + dayyesterday] ?? "");
                    print(shift_id_yesterday);
                  });
                  if (shift_id_yesterday == "") {
                  } else {
                    fh.Shift(database_name, shift_id_yesterday, widget.apikey,
                            widget.token, "shift/show", widget.url_api)
                        .then((mastershift) {
                      if (mastershift.isNotEmpty) {
                        mastershift.forEach((value) {
                          shift_samedateout = value['shift_samedateout'] ?? 0;
                        });
                      } else {
                        shift_samedateout = 0;
                      }
                      print('shift_samedateout : ');
                      print(shift_samedateout);
                    });
                  }
                } else {
                  // _showDialog("Anda Belum Memiliki Jadwal Shift");
                }
              });
            } else {
              print('hemmm');
              outyesterday = false;
              setState(() {
                _cekin = "--:--";
                _cekout = "--:--";
                ischekin = false;
                ischekout = true;
                cekincolor = Colors.green;
                cekoutcolor = Colors.grey;
              });
            }
            // url_api = rows['config1'];
          });
        });
      } else {
        outyesterday = false;
      }
      getabsenhistory();
    });
  }

  void getabsenhistory() {
    setState(() {
      // isLoading = true;
    });
    showLoadingDialog("Load History...", context);
    fh
        .absen_history(database_name, employee_fingerid, widget.apikey,
            widget.token, strabsenceonlinehistoryname, widget.url_api)
        .then((hasils) async {
      absencehistory.clear();
      strabsencehistory = "";
      print(hasils);
      if (hasils.length > 0) {
        absencehistory = hasils;
        hasils.forEach((rows) {
          setState(() {
            // print(rows['absence_date']);
          });
        });
      } else {}
      setState(() {
        absencehistory = hasils;
        isLoading = false;
      });
      hideLoadingDialog(context);
      showLoadingDialog("Selesai...", context);
      await Future.delayed(const Duration(seconds: 2)); // waiting for a second
      hideLoadingDialog(context);
    });
  }

  void getabsen() {
    setState(() {
      _cekin = "--:--";
      _cekout = "--:--";
      ischekin = false;
      ischekout = true;
      cekincolor = Colors.green;
      cekoutcolor = Colors.grey;
      strstatusabsen = "";
    });
    showLoadingDialog("Load Data...", context);
    fh
        .absen_history(database_name, employee_fingerid, widget.apikey,
            widget.token, strabsenceonlinehistoryname, widget.url_api)
        .then((hasils) async {
      print(hasils);
      if (hasils.length > 0) {
        absence_dateterakhir = hasils[0]['absence_date'] ?? "";
        absence_tin = hasils[0]['absence_oin'] ?? "";
        absence_tout = hasils[0]['absence_oout'] ?? "";
        _cekin = absence_tin;
        _cekout = absence_tout;

        if (absence_dateterakhir != "") {
          absence_dateterakhir =
              absenceFormat.format(DateTime.parse(absence_dateterakhir));
          lastdate = DateTime.parse(absence_dateterakhir);
          _yearyesterday = yearFormat.format(lastdate);
          _monthyesterday = monthFormat.format(lastdate);
          dayyesterday = dayFormat.format(lastdate);
          strabsence_dateterakhir = dateFormat.format(lastdate);
        }

        if (absence_tin == "" || absence_tin == "00:00:00") {
          setState(() {
            _cekin = "--:--";
            ischekin = false;
            cekincolor = Colors.green;
          });
          print('ischekin = false');
        } else {
          setState(() {
            ischekin = true;
            cekincolor = Colors.grey;
          });
          print('ischekin = true');
        }

        if (absence_tout == "" || absence_tout == "00:00:00") {
          setState(() {
            _cekout = "--:--";
            ischekout = false;
            cekoutcolor = Colors.orange;
          });
          print('ischekout = false');
        } else {
          setState(() {
            ischekout = true;
            cekoutcolor = Colors.grey;
          });
          print('ischekout = true');
        }

        print('absence_dateterakhir : ' + absence_dateterakhir);
        print('absence_date : ' + absence_date);
        if (absence_date == absence_dateterakhir) {
          ////////////////////// ABSEN TODAY /////////////////////
          ///
          print('absence_date == absence_dateterakhir');
          outyesterday = false;
          hideLoadingDialog(context);
          getabsenhistory();
        } else {
          hideLoadingDialog(context);
          ////////////////////// ABSEN LASTDAY /////////////////////
          print('absence_date != absence_dateterakhir');
          absence_date_yesterday = absence_dateterakhir;
          if (ischekin == true && ischekout == false) {
            print("BELUM ABSEN OUT KEMARIN");
            _showDialog("Anda Belum Melakukan Absen Keluar Kemarin (" +
                strabsence_dateterakhir +
                "), Segera Lakukan Absen Keluar Dahulu");
            setState(() {
              strstatusabsen = "Anda Belum Melakukan Absen Keluar Kemarin (" +
                  strabsence_dateterakhir +
                  "), Segera Lakukan Absen Keluar Dahulu";
            });

            outyesterday = true;
            if (employee_type == "EMP") {
              fh
                  .employeeshift(
                      database_name,
                      _yearyesterday,
                      _monthyesterday,
                      employee_id,
                      widget.apikey,
                      widget.token,
                      "employeeshift/show",
                      widget.url_api)
                  .then((resultshift) {
                if (resultshift.isNotEmpty) {
                  resultshift.forEach((value) {
                    shift_id_yesterday =
                        value['employeeshift_' + dayyesterday] ?? "";
                    print('SHIFT ID : ');
                    print(value['employeeshift_' + dayyesterday] ?? "");
                    print(shift_id_yesterday);
                  });
                  if (shift_id_yesterday == "") {
                    _showDialog("Shift Hari Sebelum nya (" +
                        strabsence_dateterakhir +
                        "), kosong");
                    setState(() {
                      ischekin = true;
                      cekincolor = Colors.grey;
                      ischekout = true;
                      cekoutcolor = Colors.grey;
                    });
                  } else {
                    fh.Shift(database_name, shift_id_yesterday, widget.apikey,
                            widget.token, "shift/show", widget.url_api)
                        .then((mastershift) {
                      if (mastershift.isNotEmpty) {
                        mastershift.forEach((value) {
                          shift_samedateout = value['shift_samedateout'] ?? 0;
                        });
                      } else {
                        shift_samedateout = 0;
                      }
                      print('shift_samedateout : ');
                      print(shift_samedateout);
                    });
                  }
                } else {
                  // _showDialog("Anda Belum Memiliki Jadwal Shift");
                }
              });
              // hideLoadingDialog(context);
              getabsenhistory();
            } else {
              // hideLoadingDialog(context);
              getabsenhistory();
            }
          } else if (ischekin == true && ischekout == true) {
            // hideLoadingDialog(context);
            setState(() {
              isLoading = false;
              _cekin = "--:--";
              _cekout = "--:--";
              ischekin = false;
              ischekout = true;
              cekincolor = Colors.green;
              cekoutcolor = Colors.grey;
              outyesterday = false;
            });
            getabsenhistory();
          }
          // hideLoadingDialog(context);
          // getabsenhistory();
        }
      } else {
        setState(() {
          isLoading = false;
          _cekin = "--:--";
          _cekout = "--:--";
          ischekin = false;
          ischekout = true;
          cekincolor = Colors.green;
          cekoutcolor = Colors.grey;
          outyesterday = false;
        });
        hideLoadingDialog(context);
        getabsenhistory();
      }

      // hideLoadingDialog(context);
      // showLoadingDialog("Selesai...", context);
      // await Future.delayed(const Duration(seconds: 2)); // waiting for a second
      // hideLoadingDialog(context);
    });
  }

  Future<void> _refresh() async {
    getdata();
    // getabsenterakhir();
    // getabsen();
    // getabsenhistory();
  }

  //to show our dialog
  Future<void> showLoadingDialog(
    String status,
    BuildContext context,
  ) {
    return showDialog(
      context: context,
      barrierDismissible: false, // Prevents dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text(status),
            ],
          ),
        );
      },
    );
  }

// to hide our current dialog
  void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<void> _uploaddio() async {
    //LoadingScreen.instance().show(context: context, text: "Upload Photo...");
    showLoadingDialog("Upload Photo...", context);
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    int offsetInHours = timeZoneOffset.inHours;
    int offsetInMinutes = timeZoneOffset.inMinutes;
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
        hourFormatnew.format(now) +
        formattedOffset;
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    // imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    var dio = Dio();
    print('strTIMESTAMP:');
    print(strTIMESTAMP);
    print('apikey:');
    print(widget.apikey);
    print('token:');
    print(widget.token);
    print('imageFile ; ');
    print(imageFile!.path.toString());
    print('uploadimage_name ; ');
    print(uploadimage_name);
    String fileName = imageFile!.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        imageFile!.path,
        filename: fileName,
        contentType: MediaType("image", "jpeg"), //add this
      ),
      "filename": uploadimage_name
    });

    print(fileName);
    print(widget.url_api);
    print(strTIMESTAMP);

    var response = await dio.post(
      widget.url_api + "uploadgambar/upload",
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
        debugPrint("sent${sent.toString()}" + " total${total.toString()}");
      },
    ).whenComplete(() {
      debugPrint("complete:");
      hideLoadingDialog(context);
      setState(() {
        _filename = "Tidak ada file dipilih";
      });
      getdata();
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
      hideLoadingDialog(context);
      _showDialog("error upload photo:${onError.toString()}");
    });
  }

  Future<void> _uploaddioNew() async {
    String imagePath = '/storage/emulated/0/Download/' +
        imgname; // Replace with your actual image path
    print('imagePath:');
    print(imagePath);
    File imageFile = File(imagePath);
    //LoadingScreen.instance().show(context: context, text: "Upload Photo...");
    showLoadingDialog("Upload Photo...", context);
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    int offsetInHours = timeZoneOffset.inHours;
    int offsetInMinutes = timeZoneOffset.inMinutes;
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
        hourFormatnew.format(now) +
        formattedOffset;
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    // imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    var dio = Dio();
    print('strTIMESTAMP:');
    print(strTIMESTAMP);
    print('apikey:');
    print(widget.apikey);
    print('token:');
    print(widget.token);
    print('filename:');
    print(uploadimage_name);
    String fileName = imageFile!.path.split('/').last;

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: MediaType("image", "jpeg"), //add this
      ),
      "filename": uploadimage_name
    });

    print(fileName);
    print(widget.url_api);
    print(strTIMESTAMP);

    var response = await dio.post(
      widget.url_api + "uploadgambar/upload",
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
        debugPrint("sent${sent.toString()}" + " total${total.toString()}");
      },
    ).whenComplete(() {
      debugPrint("complete:");
      hideLoadingDialog(context);
      setState(() {
        _imageFile = null;
        _filename = "Tidak ada file dipilih";
        strcamera = "off";
        _isSwitched = false;
      });

      getdata();
    }).catchError((onError) {
      debugPrint("error:${onError.toString()}");
      hideLoadingDialog(context);
      // _showDialog("error upload photo:${onError.toString()}");
    });
  }

  void _showFullScreenImageDialog(BuildContext context, String ImageUrl) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true, // Allows dismissing by tapping outside
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black, // Dark background for the dialog
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.black, // Black background for the image
          body: Stack(
            children: [
              Center(
                child: Image.network(
                  ImageUrl, // Replace with your image URL
                  fit: BoxFit.contain, // Adjust fit as needed
                ),
              ),
              Positioned(
                top: 40, // Adjust position as needed
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void setting() {
    // image slider
    fh.SettingAbsenOnline("carouselsli", widget.apikey, widget.token,
            "setting/absenonline", widget.url_api)
        .then((resultsetting) {
      imageslidePaths.clear();
      setState(() {
        imageslidePaths = resultsetting;
      });
      setState(() {
        isLoading = false;
      });
    });
  }

  DateTime convertToDate(String input) {
    try {
      var d = new DateFormat.yMd().parseStrict(input);
      // var d = new DateFormat.yMd().parseStrict(input);
      return d;
    } catch (e) {
      return DateTime.now();
    }
  }

  Future<Null> _chooseDate(
      BuildContext context, String initalDateString, String datetype) async {
    var now = new DateTime.now();
    var initialDate = convertToDate(initalDateString) ?? now;
    initialDate = (initialDate.year >= 1900 && initialDate.isBefore(now)
        ? initialDate
        : now);
    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: new DateTime.now(),
        lastDate: new DateTime(2050));

    if (result == null) return;
    setState(() {
      if (datetype == "datefrom") {
        _datefrom = dailyFormat.format(result);
        _strdatefrom = newFormat.format(result);
        absence_date = _datefrom;
      } else if (datetype == "dateend") {
        _dateend = dailyFormat.format(result);
        _strdateend = newFormat.format(result);
        absence_dateend = _dateend;
      }

      // _datefrom = dailyFormat.format(result);
      // List<String> aWords =
      //     tglcuti.where((w) => w.startsWith(_datefrom)).toList();

      // print('aWords');
      // print(aWords.length);
      // if (aWords.length > 0) {
      //   print('sudah ada');
      // } else {
      //   tglcuti.add(_datefrom);
      //   if (_strdateAll == "") {
      //     _strdateAll = newFormat.format(result);
      //   } else {
      //     _strdateAll = _strdateAll + ", " + newFormat.format(result);
      //   }
      // }
      // _tanggalcutiController = new TextEditingController(text: _strdateAll);
    });
    print(_datefrom);
    print(_dateend);
  }

  Future<void> getFileMetadata(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      final stat = await file.stat();
      print('File path: ${filePath}');
      print('File size: ${stat.size} bytes');
      print('Last modified: ${stat.modified}');
      print('Last accessed: ${stat.accessed}');
    } else {
      print('File not found.');
    }
  }

  Future<void> getImageExif(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final exifData = await readExifFromBytes(bytes);
      if (exifData != null) {
        exifData.forEach((key, value) {
          if (key == "Image DateTime") {
            file_created_date = '$value';
            print(file_created_date.substring(0, 10));
            filecreate = file_created_date.substring(0, 10);
          }
          // print('$key: $value');
          // print('$value');
        });
      } else {
        print('No EXIF data found.');
      }
    } else {
      print('Image file not found.');
    }
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

        isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        isLocation = false;
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

      setState(() {
        strlatitude = _currentPosition!.latitude.toString();
        strlongitude = _currentPosition!.longitude.toString();
        _currentAddress =
            "${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}";
        print('strlatitude');
        print(strlatitude);
        print('strlongitude');
        print(strlongitude);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDataAndCount() async {
    fh.fetchDataAndCount;
    var (data, count) = await fh.fetchDataAndCount();
  }

  _openGallery() async {
    imageFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    // getFileMetadata(imageFile!.path);
    getImageExif(imageFile!.path);
    // String basename = basename(imageFile!.path);
    setState(() {
      print(imageFile!.name);
      _filename = imageFile!.name;
      absence_image = employee_id + "_";
    });
    print(filecreate);
    print(daycreate);
    // if (filecreate != daycreate) {
    //   _showDialog("Absen Gagal, harap perbaharui foto anda");
    // }
    // _uploaddio();
  }

  Future<void> _takePicture() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request permission if it's denied
      // status = await Permission.camera.request();
      _showDialog(
          "Izin akses kamera ditolak. Buka pengaturan aplikasi untuk memngizinkan akses kamera");
      openAppSettings();
    } else {
      _getCurrentLocation();
      DateTime now = DateTime.now();
      String tglRemark = tglFormat.format(now);
      String imgname = imageFormat.format(now);

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 25,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _filename = imgname + ".jpg";
          print(_imageFile);
          strremark = "Absen Online - Android Mobile Apps \n" +
              employee_personalid +
              " - " +
              employee_name +
              "\n" +
              dayNameInd +
              ", " +
              tglRemark +
              " " +
              strTimeZone +
              "\n" +
              "Lat : " +
              strlatitude +
              ", Long : " +
              strlongitude;
        });
      }
    }
  }

  void updateremark() {
    _getCurrentLocation();
    DateTime now = DateTime.now();
    String tglRemark = tglFormat.format(now);
    strremark = "Absen Online - Android Mobile Apps \n" +
        employee_personalid +
        " - " +
        employee_name +
        "\n" +
        dayNameInd +
        ", " +
        tglRemark +
        " " +
        strTimeZone +
        "\n" +
        "Lat : " +
        strlatitude +
        ", Long : " +
        strlongitude;
  }

  Future<void> _captureAndSave() async {
    DateTime now = DateTime.now();
    imgname = imageFormat.format(now) + ".jpg";
    try {
      showLoadingDialog("Simpan Photo...", context);
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        // final path = '${directory.path}/my_widget_image.png';
        final path = '/storage/emulated/0/Download/' + imgname;
        final file = File(path);
        await file.writeAsBytes(pngBytes);
        print('path : ');
        print(path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $path')),
        );

        final Uint8List? compressedImageBytes =
            await FlutterImageCompress.compressWithFile(
          path,
          minWidth: 500, // Desired width
          minHeight: 500, // Desired height
          quality: 80, // Compression quality (0-100)
        );

        // Save the compressed image bytes to a new file
        if (compressedImageBytes != null) {
          final File resizedFile =
              File(join('/storage/emulated/0/Download/', imgname));
          await resizedFile.writeAsBytes(compressedImageBytes);
          print(resizedFile.path);
        }

        hideLoadingDialog(context);
        _uploaddioNew();
      }
    } catch (e) {
      print(e);
      hideLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  void getimagepath() {
    String imagePath = '/storage/emulated/0/Download/' +
        _filename; // Replace with your actual image path
    File imageFile = File(imagePath);
    print(imageFile);
  }
}

extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) {
      return this; // Handle empty strings
    }
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
