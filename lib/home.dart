import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hcms/absence/absence.dart';
import 'package:hcms/absence/camera.dart';
import 'package:hcms/absence/camera_page.dart';
import 'package:hcms/dinas/dinas.dart';
import 'package:hcms/config.dart';
import 'package:hcms/tester.dart';
import 'package:hcms/download.dart';
import 'package:hcms/error.dart';
import 'package:intl/intl.dart';
import 'package:timer_builder/timer_builder.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:hcms/models/config.dart';
import 'package:hcms/models/company.dart';
import 'package:hcms/models/nik.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms/dialog/loading_screen.dart';
import 'package:hcms/upload.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:input_history_text_field/input_history_text_field.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:link_text/link_text.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

// import 'package:dropdown_search/dropdown_search.dart';
//tes git
class MenuItem {
  final String company_name;
  final String database_name;

  MenuItem(this.company_name, this.database_name);
}

class MenuNIK {
  final String personalid;
  final String name;

  MenuNIK(this.personalid, this.name);
}

final List<String> imagePaths = [
  'assets/Logo-TSG-S.png',
  'assets/TE.png',
  'assets/citygarden.png',
];

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  DatabaseHelper db = new DatabaseHelper();
  HelperFunction fh = new HelperFunction();

  GlobalKey _globalKey = GlobalKey();
  bool isLoading = false;
  TextEditingController _NIKController = new TextEditingController();
  List<Company> itemlistcompany = [];

  List<MenuItem> menuItems = [];

  List<MenuNIK> menuNIKS = [];

  List imageslidePaths = [];

  String _tanggal = "";
  var newFormat = DateFormat("dd MMM yyyy");
  var clientFormat = DateFormat("yyyy-MM-dd");
  var yearFormat = DateFormat("yyyy");
  var monthFormat = DateFormat("M");
  var dayFormat = DateFormat("d");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");
  var tglFormat = DateFormat("dd MMM yyyy HH:mm:ss");
  final dt = new DateTime.now();
  DateTime now = DateTime.now();
  DateTime yesterday = DateTime.now();

  String dayName = "";
  String dayNameInd = "";
  int dayOfMonth = 0;
  String url_api = "https://api-hcm.transentertainment.com/index.php/api/v1/";
  // String url_api = "http://192.168.0.5/api-ci3/index.php/api/v1/";
  // String url_api = "http://172.16.3.56/api-ci3-dev/index.php/api/v1/";

  String token = "";
  List companyItemlist = [];
  var dropdownvalue;
  String company_id = "";
  String company_name = "";
  String company_name2 = "";
  String listcompany_id = "";
  String listcompany_remark = "";
  String NIK = "";
  String employee_id = "";
  String employee_name = "";
  String employee_personalid = "";
  String employee_fingerid = "";
  String office_id = "";
  String _year = "";
  String _month = "";
  String employee_gender = "";
  String employee_dateofbirth = "";
  String divisi_name = "";
  String ho_date = "";
  String client_date = "";
  String database_name = "";
  String shift_id = "";
  String daynow = "";
  String dayyesterday = "";
  String _type = "";
  Uri uri = Uri.parse('http://www.example.com');

  bool _isSwitched = false;
  String strdebug = "Off";
  String url_api_prod =
      "https://api-hcm.transentertainment.com/index.php/api/v1/";
  String url_api_dev =
      "https://api-hcmdev.transentertainment.com/index.php/api/v1/";

  String url_api_root = "";
  String url_api_slide = "";
  String url_api_image = "";
  String url_image_dev = "https://ssodev.transentertainment.com/";
  String url_image_prod = "https://sso.transentertainment.com/";
  String apikey = "";
  String _brand = "";
  String _model = "";
  String device_info = "";
  String strTimeZone = "";
  String office_name = "";
  String department_name = "";
  Position? _currentPosition;
  String _currentAddress = "";
  String strlatitude = "";
  String strlongitude = "";
  bool isLocation = false;
  String projectVersion = "";
  String _version_id = "";

  final Uri _url = Uri.parse('https://sso.transentertainment.com/download.php');
  String employee_type = "";

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    projectVersion = "1.0.1";
    // isLoading = true;
    // getconfig().then((hasils) {
    //   // print('getdata');
    // });
    requestPermission();
    urlschemaroot();
    listcompany();
    listNIK();
    strTimeZone = DateTime.now().timeZoneName;
    daynow = dayFormat.format(now);

    yesterday = now.subtract(Duration(days: 1));
    dayyesterday = dayFormat.format(yesterday);

    _tanggal = newFormat.format(now);
    _year = yearFormat.format(now);
    _month = monthFormat.format(now);
    client_date = clientFormat.format(now);
    dayName = DateFormat('EEEE').format(now);
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
    // dayNameInd = dayName;
    initPlatformState().then((result) {
      if (_deviceData.isNotEmpty) {
        _brand = _deviceData['brand'];
        _model = _deviceData['model'];
        device_info = _brand + " - " + _model;
        print(device_info);
      }
    });
    _getCurrentLocation();
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
    double width = MediaQuery.of(context).size.width - 12;
    final TextEditingController menuController = TextEditingController();
    MenuItem? selectedMenu;

    final TextEditingController niksController = TextEditingController();
    MenuNIK? selectedNiks;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        print('didPop');
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            _refresh();
            // Replace this delay with the code to be executed during refresh
            // and return a Future when code finishes execution.
            return Future<void>.delayed(const Duration(seconds: 2));
          },
          child: ListView(
            children: <Widget>[
              CarouselSlider.builder(
                itemCount: imageslidePaths.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return Stack(
                    children: [
                      Image.network(
                        url_api_slide + imageslidePaths[index]['value'],
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        // height: 200,
                        // fit: BoxFit.fitWidth,
                        // width: double.infinity,
                      ),
                      Positioned(
                        bottom: 5.0,
                        child: Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
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
                          padding: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
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
                    margin: const EdgeInsets.all(10.0),
                    padding: const EdgeInsets.all(10.0),
                    // color: Colors.white,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        width: 8,
                        color: Colors.white,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // height: 100.0,
                    child: Column(
                      children: <Widget>[
                        // InkWell(
                        //     child: SizedBox(
                        //       height: 130.0,
                        //       child: Image.asset(
                        //         "assets/TE.png",
                        //         fit: BoxFit.contain,
                        //       ),
                        //     ),
                        //     onTap: () {
                        //       print('logo');
                        //       _navigateToCekKoneksi(context);
                        //     }),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        isLoading
                            ? const Center(
                                child: LinearProgressIndicator(),
                              )
                            : Container(),
                        // Container(
                        //   height: 80,
                        //   decoration: BoxDecoration(
                        //     color: Color.fromARGB(255, 76, 85, 250),
                        //     border: Border.all(
                        //       width: 8,
                        //       color: Color.fromARGB(255, 76, 85, 250),
                        //     ),
                        //     borderRadius: BorderRadius.circular(10),
                        //   ),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     children: <Widget>[
                        //       Column(
                        //         // This Column is a child of the Row
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: <Widget>[
                        //           TimerBuilder.periodic(Duration(seconds: 1),
                        //               builder: (context) {
                        //             return Text(
                        //               "${getSystemTime()}",
                        //               textAlign: TextAlign.center,
                        //               style: const TextStyle(
                        //                   color: Colors.white,
                        //                   fontSize: 20,
                        //                   fontWeight: FontWeight.w700),
                        //             );
                        //           }),
                        //           const Text(
                        //             "WIB",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //               color: Colors.white,
                        //               fontSize: 12.0,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(
                        //         width: 30,
                        //       ),
                        //       Column(
                        //         // This Column is a child of the Row
                        //         mainAxisAlignment: MainAxisAlignment.center,
                        //         children: <Widget>[
                        //           Text(
                        //             _tanggal,
                        //             textAlign: TextAlign.center,
                        //             style: const TextStyle(
                        //                 color: Colors.white,
                        //                 fontSize: 20.0,
                        //                 fontWeight: FontWeight.w700),
                        //           ),
                        //           Text(
                        //             dayNameInd,
                        //             textAlign: TextAlign.center,
                        //             style: const TextStyle(
                        //               color: Colors.white,
                        //               fontSize: 12.0,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.apartment),
                            SizedBox(width: 8),
                            Text('Company'),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownMenu<MenuItem>(
                          //initialSelection: menuItems.first,

                          controller: menuController,
                          width: MediaQuery.of(context).size.width - 55,
                          menuHeight: 400,
                          hintText: "Search Company",
                          requestFocusOnTap: true,
                          // enableFilter: true,
                          menuStyle: MenuStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightBlue.shade50),
                          ),

                          label: const Text('Search Company'),
                          onSelected: (MenuItem? menu) {
                            setState(() {
                              selectedMenu = menu;
                              print(selectedMenu!.database_name.toString());
                              database_name = selectedMenu!.database_name;
                              company_name = selectedMenu!.company_name;
                            });
                          },
                          dropdownMenuEntries: menuItems
                              .map<DropdownMenuEntry<MenuItem>>(
                                  (MenuItem menu) {
                            return DropdownMenuEntry<MenuItem>(
                              value: menu,
                              label: menu.company_name,
                            );
                          }).toList(),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(Icons.contact_emergency),
                            SizedBox(width: 8),
                            Text('NIK'),
                            Text(
                              '*',
                              style: TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        DropdownMenu<MenuNIK>(
                          //initialSelection: menuItems.first,

                          controller: _NIKController,
                          width: MediaQuery.of(context).size.width - 55,
                          menuHeight: 400,
                          hintText: "Masukkan NIK Anda",
                          requestFocusOnTap: true,
                          enableFilter: true,
                          menuStyle: MenuStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightBlue.shade50),
                          ),

                          label: const Text('Masukkan NIK Anda'),
                          onSelected: (MenuNIK? menu) {
                            setState(() {
                              selectedNiks = menu;
                              print(selectedNiks!.personalid.toString());
                              // database_name = selectedNiks!.database_name;
                              // company_name = selectedNiks!.personalid;
                            });
                          },
                          dropdownMenuEntries: menuNIKS
                              .map<DropdownMenuEntry<MenuNIK>>((MenuNIK menu) {
                            return DropdownMenuEntry<MenuNIK>(
                              value: menu,
                              label: menu.personalid,
                            );
                          }).toList(),
                        ),

                        // TextFormField(
                        //   decoration: const InputDecoration(
                        //       border: OutlineInputBorder(
                        //           // borderRadius:
                        //           //     BorderRadius.all(Radius.circular(20.0)),
                        //           ),

                        //       // hintText: 'Enter your firs and latname',
                        //       labelText: 'Masukkan NIK Anda'),
                        //   controller: _NIKController,
                        //   // keyboardType: TextInputType.,

                        //   minLines: 1, //Normal textInputField will be displayed
                        //   maxLines: 3,
                        //   readOnly: false,
                        // ),
                        const SizedBox(
                          height: 10,
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
                          // const SizedBox(height: 16),
                        ],
                        if (strdebug == "On") ...[
                          Text(
                            url_api,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                        ],
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          width: MediaQuery.of(context).copyWith().size.width,
                          height: 50.0,
                          // width: 150,
                          child: Row(children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 76, 85, 250),
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Sets a circular border radius of 20
                                  ),
                                ),
                                onPressed: () {
                                  NIK = _NIKController.text.trim();
                                  if (NIK == "123123123") {
                                    _navigateToCekKoneksi(context);
                                  } else if (NIK == "cek api") {
                                    _navigateToCekKoneksi(context);
                                  } else if (NIK == "error page") {
                                    _navigateToError(context);
                                  } else if (NIK == "download") {
                                    _navigateToDownload(context);
                                  } else if (NIK == "download apk") {
                                    _navigateToDownload(context);
                                  } else if (NIK == "update apk") {
                                    _navigateToDownload(context);
                                  } else if (NIK == "apk") {
                                    _navigateToDownload(context);
                                  } else if (NIK == "download dialog") {
                                    _showDialogDownload();
                                  } else if (NIK == "debug on") {
                                    setState(() {
                                      _isSwitched = true;
                                      strdebug = "On";
                                      url_api = url_api_dev;
                                      urlschemaroot();
                                      _NIKController.text = "";
                                    });
                                  } else if (NIK == "debug off") {
                                    setState(() {
                                      _isSwitched = false;
                                      strdebug = "Off";
                                      url_api = url_api_prod;
                                      urlschemaroot();
                                      _NIKController.text = "";
                                    });
                                  } else if (NIK == "clear nik") {
                                    db.deleteNIKAll();
                                    listcompany();
                                    setState(() {
                                      _NIKController.text = "";
                                    });
                                  } else if (NIK == "clear") {
                                    db.deleteNIKAll();
                                    listcompany();
                                    setState(() {
                                      _NIKController.text = "";
                                    });
                                  } else {
                                    if (company_name == "") {
                                      _showDialog("Company belum dipilih");
                                    } else if (NIK == "") {
                                      _showDialog("NIK belum diisi");
                                    } else if (company_name == "api") {
                                      _navigateToCekKoneksi(context);
                                    } else {
                                      _type = "ABSEN";
                                      if (isLocation == false) {
                                        _showDialog(
                                            "Mohon Ijinkan Lokasi Perangkat Anda");
                                      } else {
                                        proses();
                                      }
                                    }
                                  }
                                  // Route route = MaterialPageRoute<void>(
                                  //     builder: (context) => AbsencePage(
                                  //           title: '',
                                  //         ));
                                  // Navigator.push<void>(context, route);
                                }, // The icon to display
                                child: const Text(
                                    'ABSEN'), // The text label for the button
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).copyWith().size.width,
                          height: 50.0,
                          // width: 150,
                          child: Row(children: <Widget>[
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[400],
                                  onPrimary: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10), // Sets a circular border radius of 20
                                  ),
                                ),
                                onPressed: () {
                                  NIK = _NIKController.text.trim();
                                  if (NIK == "123123123") {
                                    _navigateToCekKoneksi(context);
                                  } else {
                                    if (company_name == "") {
                                      _showDialog("Company belum dipilih");
                                    } else if (NIK == "") {
                                      _showDialog("NIK belum diisi");
                                    } else if (company_name == "api") {
                                      _navigateToCekKoneksi(context);
                                    } else {
                                      _type = "CUTI";
                                      proses();
                                    }
                                  }
                                  // Route route = MaterialPageRoute<void>(
                                  //     builder: (context) => AbsencePage(
                                  //           title: '',
                                  //         ));
                                  // Navigator.push<void>(context, route);
                                }, // The icon to display
                                child: const Text(
                                    'CUTI / PENGGANTI HARI'), // The text label for the button
                              ),
                            ),
                          ]),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: MediaQuery.of(context).copyWith().size.width,
                          height: 50.0,
                          // width: 150,
                          child: Row(children: <Widget>[
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
                                  NIK = _NIKController.text.trim();
                                  if (NIK == "123123123") {
                                    _navigateToCekKoneksi(context);
                                  } else {
                                    if (company_name == "") {
                                      _showDialog("Company belum dipilih");
                                    } else if (NIK == "") {
                                      _showDialog("NIK belum diisi");
                                    } else if (company_name == "api") {
                                      _navigateToCekKoneksi(context);
                                    } else {
                                      _type = "SAKIT";
                                      proses();
                                    }
                                  }
                                }, // The icon to display
                                child: const Text(
                                    'SAKIT / IZIN'), // The text label for the button
                              ),
                            ),
                          ]),
                        ),
                        // const SizedBox(
                        //   height: 20,
                        // ),
                        // Container(
                        //   width: MediaQuery.of(context).copyWith().size.width,
                        //   height: 50.0,
                        //   // width: 150,
                        //   child: Row(children: <Widget>[
                        //     Expanded(
                        //       child: ElevatedButton(
                        //         style: ElevatedButton.styleFrom(
                        //           backgroundColor: Colors.pink,
                        //           onPrimary: Colors.white,
                        //           shape: RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(
                        //                 10), // Sets a circular border radius of 20
                        //           ),
                        //         ),
                        //         onPressed: () {
                        //           NIK = _NIKController.text.trim();
                        //           _type = "DINAS";
                        //           //_navigateToDinas(context);
                        //           _navigateToCamera2(context);
                        //         }, // The icon to display
                        //         child: const Text(
                        //             'PERJALANAN DINAS'), // The text label for the button
                        //       ),
                        //     ),
                        //   ]),
                        // ),
                        const SizedBox(
                          height: 40,
                        ),
                        SizedBox(
                          height:
                              70.0, // Sets the height of the SizedBox, and thus the button
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 47, 221, 248),
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10), // Sets a circular border radius of 20
                              ),
                            ),
                            onPressed: () {
                              // Define the action to perform when the button is pressed
                              print('Button pressed!');
                            },
                            icon: const Icon(Icons.info), // The icon to display
                            label: const Text(
                                'Petunjuk : Pilih Company dan masukkan NIK untuk melanjutkan proses absensi'), // The text label for the button
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        // SizedBox(
                        //   height: 10,
                        // ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.start,
                        //   children: <Widget>[
                        //     Switch(
                        //       value: _isSwitched,
                        //       onChanged: (newValue) {
                        //         setState(() {
                        //           _isSwitched = newValue;
                        //           if (_isSwitched == true) {
                        //             _isSwitched = false;
                        //             // strdebug = "On";
                        //             // url_api = url_api_dev;
                        //             // urlschemaroot();
                        //           } else {
                        //             _isSwitched = false;
                        //             strdebug = "Off";
                        //             url_api = url_api_prod;
                        //             urlschemaroot();
                        //           }
                        //         });
                        //         // You can add logic here based on the new switch state
                        //         print('Switch state changed to: $newValue');
                        //       },
                        //     ),
                        //     Text("Debug " + strdebug),
                        //     // IconButton(
                        //     //     onPressed: () {
                        //     //       _navigateToCekKoneksi(context);
                        //     //     },
                        //     //     icon: Icon(Icons.settings)),
                        //   ],
                        // ),

                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Version : " + projectVersion,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "(C) 2025 HUMAN CAPITAL TRANS ENTERTAINMENT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          onPressed: () async {
            //gettoken();
            // db.deleteConfigAll().then((result) {});
            // getconfig();
            // listcompany();

            // getLocalTimezone();
            // print(DateTime.now().timeZoneName);
            // DateTime now = DateTime.now();
            // String strTIMESTAMP = dailyFormat.format(now) +
            //     "T" +
            //     hourFormat.format(now) +
            //     "+07:00";
            // // print(strTIMESTAMP);
            // String signature = generateSignature(
            //   database_name,
            //   strTIMESTAMP,
            // );
            // if (kDebugMode) {
            //   print("Signature: $signature");
            //   getapikey(signature, strTIMESTAMP);
            // }

            requestPermission();

            listcompany();
            listNIK();
            _getCurrentLocation();
            // _takePicture();

//             DateTime now = DateTime.now();
//             Duration timeZoneOffset = now.timeZoneOffset;

// // To get the offset in hours:
//             int offsetInHours = timeZoneOffset.inHours;

// // To get the offset in minutes:
//             int offsetInMinutes = timeZoneOffset.inMinutes;

// // To format the offset as a string like "+HH:MM" or "-HH:MM":
//             String formattedOffset = '';
//             if (timeZoneOffset.isNegative) {
//               formattedOffset += '-';
//             } else {
//               formattedOffset += '+';
//             }
//             formattedOffset +=
//                 '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:';
//             formattedOffset +=
//                 '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

//             print('Time Zone Offset (Duration): $timeZoneOffset');
//             print('Time Zone Offset (in Hours): $offsetInHours');
//             print('Time Zone Offset (in Minutes): $offsetInMinutes');
//             print('Formatted Time Zone Offset: $formattedOffset');

            // print('Current UTC Time: ${DateTime.now().toUtc()}');
            // DateTime dateTime = DateTime.now();
            // final DateTime now = DateTime.now();
            // final Duration timeZoneOffset = now.timeZoneOffset;
            // print(dateTime.timeZoneName);
            // print(dateTime.timeZoneOffset);
            // print(
            //     'Time zone offset from UTC: ${timeZoneOffset.inHours} hours and ${timeZoneOffset.inMinutes.remainder(60)} minutes');

            // print(DateTime.now().timeZoneOffset.inHours);
            // print(DateTime.now().timeZoneOffset.inMinutes.remainder(60));

            // print('-----------');
            // print('Current local time: ${DateTime.now()}');
            // print('GMT Offset: ${DateTime.now().timeZoneOffset}');
            // print(
            //     'GMT Offset in hours: ${DateTime.now().timeZoneOffset.inHours}');
            // print(
            //     'GMT Offset in minutes: ${DateTime.now().timeZoneOffset.inMinutes}');

            // _showDialogDownload();

            // _launchWebUrl();

            // print('getcompany');

            // urlschemaroot();
            // getdata();

            // getdata();
            // print(menuItems);
            // showLoadingDialog(context); // show our loading dialog
            // await Future.delayed(
            //     const Duration(seconds: 2)); // waiting for a second
            // hideLoadingDialog(context);

            // //LoadingScreen.instance().show(context: context); // show our dialog
            // await Future.delayed(
            //     const Duration(seconds: 1)); // wait for a second
            // if (mounted) {
            //   //LoadingScreen.instance().show(
            //       context: context,
            //       text: "Almost done.."); // then we update our text
            // } // !! I believe we don't need to use the mounted property since we won't be using our 'pop' function anymore.
            // await Future.delayed(
            //     const Duration(seconds: 1)); // wait for a second
            // //LoadingScreen.instance().hide(); // then we hide our dialog

            // Route route = MaterialPageRoute<void>(
            //     builder: (context) => SyncfusionDatePage());
            // Navigator.push<void>(context, route);
          },
          tooltip: 'Increment',
          child: const Icon(Icons.refresh),
        ), // This trailing comma makes auto-formatting nicer for build methods.
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

  _showDialogDownload() async {
    await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title:
            const Text('Mohon update apps yang terbaru, silahkan download : ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                )),
        content: SizedBox(
          height: 100, // Fixed height for the content area
          child: Column(children: <Widget>[
            // LinkText("https://sso.transentertainment.com/download.php"),
            GestureDetector(
              onTap: () async {
                _launchInAppWebView();
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                  // "https://sso.transentertainment.com/download.php",
                  "https://sso.transentertainment.com/download.php",
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                      fontSize: 16,
                      fontWeight: FontWeight.w400),
                ),
              ),
            )
          ]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String getSystemTime() {
    var now = new DateTime.now();
    return new DateFormat("H:m:s").format(now);
  }

  void _navigateToCekKoneksi(BuildContext context) async {
    String result_id = "";
    String result_name = "";
    Map<String, dynamic> result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ConfigPage(
                url_api: url_api,
                token: token,
              )),
    );
    print('_navigateToCekKoneksi : ');
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
            url_api = result_id;
            // getconfig();
            // _url_api_sync = result_name;
            // print('_url_api : ' + _url_api);
            // print('_url_api_sync : ' + _url_api_sync);
          });
        }
      }
    }
  }

  void _navigateToError(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => ErrorPage(
              url_api: url_api,
              token: token,
            ));
    Navigator.push<void>(context, route);
  }

  void _navigateToDownload(BuildContext context) async {
    Route route = MaterialPageRoute<void>(builder: (context) => DownloadPage());
    Navigator.push<void>(context, route);
  }

  void _navigateToCamera(BuildContext context) async {
    String strRemark = "";
    String tglRemark = tglFormat.format(now);
    _tanggal = newFormat.format(now);
    strRemark = "Absen Online - Android Mobile Apps \n" +
        "202250101010 - Suhendra \n" +
        dayNameInd +
        ", " +
        tglRemark +
        " " +
        strTimeZone +
        "\n" +
        _currentAddress;
    print('strRemark : ');
    print(strRemark);
    Route route = MaterialPageRoute<void>(
        builder: (context) => CameraWithRemarkScreen(remark: strRemark));
    Navigator.push<void>(context, route);
  }

  void _navigateToCamera2(BuildContext context) async {
    // final cameras = await availableCameras();
    // final firstCamera = cameras[1];

    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => CameraHomePage(
    //             // camera: firstCamera,
    //           )),
    // );
  }

  void listcompany() {
    setState(() {
      isLoading = true;
    });
    fh.listcompany("company/show", url_api).then((resultcompany) {
      print(resultcompany);
      if (resultcompany.isNotEmpty) {
        menuItems.clear();
        setState(() {
          for (var rows in resultcompany) {
            print(rows['name']);
            menuItems.add(MenuItem(rows['name'], rows['value']));
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showDialog("Data Company is Empty");
      }
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

  void employee() {
    setState(() {
      // isLoading = true;
      _year = yearFormat.format(dt);
      _month = monthFormat.format(dt);
    });
    showLoadingDialog("Processing...", context);
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
            employee_dateofbirth =
                newFormat.format(DateTime.parse(value['employee_dateofbirth']));
            divisi_name = value['division_name'] ?? "";
            office_name = value['office_name'] ?? "";
            department_name = value['department_name'] ?? "";
            company_name2 = value['company_name'] ?? "";
            employee_type = value['employee_type'] ?? "";
            print("employee_type : " + employee_type);
            // db.saveNIK(nik);
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
            hideLoadingDialog(context);
            // //LoadingScreen.instance().hide();
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
                setIntoSharedPreferences().then((hasils) {
                  _navigateToAbsence(context);
                });
              }
            } else {
              _showDialog("Anda Belum Memiliki Jadwal Shift");
            }
          });
        } else {
          hideLoadingDialog(context);
          if (_type == "ABSEN") {
            setIntoSharedPreferences().then((hasils) {
              _navigateToAbsence(context);
            });
          } else {
            _showDialog("Mohon hubungi atasan anda");
          }
        }
      } else {
        hideLoadingDialog(context);
        //LoadingScreen.instance().hide();
        _showDialog("Data Pegawai tidak ditemukan");
      }
    });
  }

  void _navigateToAbsence(BuildContext context) async {
    // final cameras = await availableCameras();
    // final firstCamera = cameras[1];
    Route route = MaterialPageRoute<void>(
        builder: (context) => AbsencePage(
              url_api: url_api,
              token: token,
              type: _type,
              apikey: apikey,
              imageslidePaths: imageslidePaths,
              url_api_slide: url_api_slide,
              strdebug: strdebug,
              // camera: firstCamera,
            ));
    Navigator.push<void>(context, route);
  }

  void _navigateToDinas(BuildContext context) async {
    Route route = MaterialPageRoute<void>(
        builder: (context) => DinasPage(
            url_api: url_api,
            token: token,
            type: _type,
            apikey: apikey,
            imageslidePaths: imageslidePaths,
            url_api_slide: url_api_slide,
            strdebug: strdebug));
    Navigator.push<void>(context, route);
  }

  Future<String> getconfig() async {
    db.getConfig().then((hasils) {
      print(hasils);

      if (hasils.length > 0) {
        hasils.forEach((rows) {
          // print(rows['qty']);
          setState(() {
            url_api = rows['config1'];
          });
        });
      } else {
        _navigateToCekKoneksi(context);
        // db.saveConfig(Config(url_api, url_api, url_api));
      }
    });
    return url_api;
  }

  Future<int> setIntoSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("listcompany_id", listcompany_id);
    await prefs.setString("listcompany_remark", listcompany_remark);
    await prefs.setString("employee_idno", NIK);
    await prefs.setString("company_id", company_id);
    await prefs.setString("company_name", company_name);
    await prefs.setString("employee_id", employee_id);
    await prefs.setString("employee_name", employee_name);
    await prefs.setString("employee_personalid", employee_personalid);
    await prefs.setString("employee_fingerid", employee_fingerid);
    await prefs.setString("office_id", office_id);
    await prefs.setString("url_api", url_api);
    await prefs.setString("employee_dateofbirth", employee_dateofbirth);
    await prefs.setString("employee_gender", employee_gender);
    await prefs.setString("divisi_name", divisi_name);
    await prefs.setString("database_name", database_name);
    await prefs.setString("shift_id", shift_id);
    await prefs.setString("url_api_slide", url_api_slide);
    await prefs.setString("url_api_image", url_api_image);
    await prefs.setString("device_info", device_info);
    await prefs.setString("office_name", office_name);
    await prefs.setString("department_name", department_name);
    await prefs.setString("company_name2", company_name2);
    await prefs.setString("employee_type", employee_type);

    return 0;
  }

  Future<void> _refresh() async {
    listcompany();
    _getCurrentLocation();
  }

  // Future<String> HOdate() async {
  //   String strhasil = "";
  //   fh.HOdate(apikey, token, "headofficedate/show", url_api).then((hasils) {
  //     if (hasils.length > 0) {
  //       hasils.forEach((rows) {
  //         setState(() {
  //           strhasil = rows['ho_date'];
  //         });
  //       });
  //     }
  //   });
  //   return strhasil;
  // }

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

  void urlschemaroot() {
    uri = Uri.parse(url_api);
    print(uri);

    String host = uri.host;
    print(host);

    String authority = uri.authority;
    print(authority); // =
    String scheme = uri.scheme;
    print(scheme); // http

    url_api_root = scheme + "://" + authority + "/";
    print(url_api_root);

    if (scheme == "http") {
      url_api_slide = url_api_root + "api-ci3-dev/assets/upload/slides/";
      url_api_image = url_api_root + "api-ci3-dev/assets/upload/absen/";
      listcompany();
    } else if (scheme == "https") {
      if (_isSwitched == true) {
        url_api_image = url_image_dev + "assets/upload/absen/";
        url_api_slide = url_image_dev + "assets/upload/slides/";
        listcompany();
      } else {
        url_api_image = url_image_prod + "assets/upload/absen/";
        url_api_slide = url_image_prod + "assets/upload/slides/";
        listcompany();
      }
    }
    print(url_api_slide);
    print(url_api_image);
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

  void getapikey(String secretkey, String timestamp) {
    showLoadingDialog("Processing...", context);
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
                    hideLoadingDialog(context);
                    employee();
                  } else {
                    // _showDialogDownload();
                    hideLoadingDialog(context);
                    _navigateToDownload(context);
                  }
                });
              } else {
                hideLoadingDialog(context);
                _showDialog("Versi APK tidak ditemukan");
              }
            });
            // });
          } else {
            hideLoadingDialog(context);
            _showDialog("Token is Empty");
          }
        });
      } else {
        hideLoadingDialog(context);
        _showDialog("API Key is Empty");
      }
    });
  }

  void proses() {
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
        hourFormat.format(now) +
        formattedOffset;
    // print(strTIMESTAMP);
    String signature = generateSignature(
      database_name,
      strTIMESTAMP,
    );
    // _showDialog(database_name);
    // _showDialog(strTIMESTAMP);
    // _showDialog(signature);
    if (signature == "") {
      _showDialog("signature is null");
    } else {
      print("Signature: $signature");
      getapikey(signature, strTIMESTAMP);
    }
  }

  Future<void> initPlatformState() async {
    late Map<String, dynamic> deviceData;
    String platformVersion;

    String platformImei;
    String idunique;
    String mac_address;

    try {
      if (Platform.isAndroid) {
        deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
        print('_deviceData');
        print(_deviceData['id']);
      } else if (Platform.isIOS) {
        deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
      }
      // _deviceNew = _mac_address;
      // print("_mac_address : " + _mac_address);
      print("_platformVersion");
      // print(_platformVersion);
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
      platformVersion = 'Failed to get Device MAC Address.';
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

  Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  Future<String> getLocalTimezone() async {
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    print(currentTimeZone);
    return currentTimeZone;
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

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  Future<void> _launchWebUrl() async {
    final Uri url =
        Uri.parse('https://sso.transentertainment.com/download.php');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchInAppWebView() async {
    final Uri url =
        Uri.parse('https://sso.transentertainment.com/download.php');
    await launchUrl(url, mode: LaunchMode.inAppWebView);
  }

  Future<void> _takePicture() async {
    DateTime now = DateTime.now();
    // String tglRemark = tglFormat.format(now);
    // String imgname = imageFormat.format(now);

    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );
    if (pickedFile != null) {}
  }
}
