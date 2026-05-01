import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:hcms/database/function_helper.dart';
// import 'package:posticket/database/syncronize_helper.dart';
import 'package:hcms/database/db_helper.dart';
// import 'package:posticket/models/parameter.dart';
// import 'package:posticket/models/poscashier.dart';
import 'package:hcms/models/config.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class ConfigPage extends StatefulWidget {
  final String url_api;
  final String token;
  ConfigPage({
    Key? key,
    required this.url_api,
    required this.token,
  }) : super(key: key);
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  HelperFunction fh = new HelperFunction();
  DatabaseHelper db = new DatabaseHelper();
  Map<String, dynamic> closed = {'id': 'CLOSE', 'name': 'CLOSE'};
  final dt = new DateTime.now();
  var newFormat = DateFormat("yyyy-MM-dd");
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");

  String _url_api = "";

  TextEditingController _urlapiController = new TextEditingController();
  TextEditingController _urlapilokalController = new TextEditingController();
  TextEditingController _urlapisyncController = new TextEditingController();
  bool isLoading = false;

  String statusurlapi1 = "";
  String statusurlapi2 = "";
  String statusurlapi3 = "";
  String strerror = "";
  String token = "";
  String apikey = "";
  @override
  void initState() {
    super.initState();
    // _url_api = widget.url_api;
    // _url_api_lokal = widget.url_api_lokal;
    // _url_api_sync = widget.url_api_sync;
    // getconfig();
    _url_api = widget.url_api;
    _urlapiController = TextEditingController(text: _url_api);
    // isLoading = true;
  }

  void getconfig() {
    db.getConfig().then((hasils) {
      print(hasils);
      if (hasils.length > 0) {
        hasils.forEach((rows) {
          setState(() {
            _url_api = rows['config1'];
            // _url_api_sync = rows['config3'];
            // _url_api_lokal = rows['config2'];
            _urlapiController = new TextEditingController(text: _url_api);
            // _urlapilokalController =
            //     new TextEditingController(text: _url_api_lokal);
            // _urlapisyncController =
            //     new TextEditingController(text: _url_api_sync);
          });
        });
      } else {
        setState(() {
          _url_api = "";
          // _url_api_lokal = "";
          // _url_api_sync = "";
          _urlapiController = new TextEditingController(text: _url_api);
          // _urlapilokalController =
          //     new TextEditingController(text: _url_api_lokal);
          // _urlapisyncController =
          //     new TextEditingController(text: _url_api_sync);
        });
      }
    });
  }

  void cekkoneksi(String url_api, String no) {
    print(_url_api);
    fh.token(apikey, _url_api).then((result) {
      print('token : ' + result);
      token = result;
      fh.HOdate(apikey, token, "headofficedate/show", url_api).then((result) {
        if (result.isNotEmpty) {
          setState(() {
            isLoading = false;
            if (no == "1") {
              statusurlapi1 = "result : success"; //+ result.toString();
            } else if (no == "2") {
              statusurlapi2 = "result : success"; // + result.toString();
            } else {
              statusurlapi3 = "result : success"; // + result.toString();
            }
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) return;
          print('didPop');
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("API SETUP"),
            centerTitle: true,
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
                    Text(
                      "  " + strerror,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                      ),
                    ),
                    isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox(
                            height: 20,
                          ),
                    TextFormField(
                      decoration: const InputDecoration(
                          icon: Icon(Icons.adjust),
                          // hintText: 'Enter your firs and latname',
                          labelText: 'URL API'),
                      controller: _urlapiController,
                      keyboardType: TextInputType.multiline,
                      minLines: 1, //Normal textInputField will be displayed
                      maxLines: 3,
                      readOnly: false,
                      // validator: (val) => val.isEmpty ? 'URL API 1' : null,
                      // onSaved: (val) => newContact.name = val,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(statusurlapi1),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: EdgeInsets.only(left: 40, top: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              _url_api = _urlapiController.text;
                              statusurlapi1 = "";
                              strerror = "";
                            });
                            proses();
                          },
                          child: new Text("TES API"),
                        )),
                    const SizedBox(
                      height: 20,
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
          // floatingActionButton: FloatingActionButton(
          //   // onPressed: _saveScreen,
          //   onPressed: () async {
          //     sh
          //         .syncBranch(_channelid, _regionid, _branchid, _url_api)
          //         .then((result) {
          //       if (result != "success") {
          //         //isukses = 0;
          //         _showDialogWarning(result);
          //       }
          //     });
          //     // getparameter();
          //     // getposcashier();
          //     // getparameter();
          //     // getbranch();
          //     // getposstatussales();
          //     // var response = await FlutterShareMe().shareToSystem(msg: base64Image);
          //     // if (response == 'success') {
          //     //   print('navigate success');
          //     // }
          //   },
          //   child: Icon(Icons.refresh),
          //   backgroundColor: Colors.blue,
          // ),
          persistentFooterButtons: [
            Container(
              width: MediaQuery.of(context).copyWith().size.width,
              // width: 150,
              child: Row(children: <Widget>[
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, closed);
                  },
                  child: new Text("TUTUP"),
                )),
                const SizedBox(
                  height: 10,
                  width: 10,
                ),
                Expanded(
                    child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      _url_api = _urlapiController.text;
                      statusurlapi1 = "";
                      statusurlapi2 = "";
                      statusurlapi3 = "";
                    });
                    if (_url_api == "") {
                      isLoading = false;
                      _showDialogWarning("URL API tidak boleh kosong");
                      // } else if (_url_api_lokal == "") {
                      //   isLoading = false;
                      //   _showDialogWarning("URL API 2 tidak boleh kosong");
                      // } else if (_url_api_sync == "") {
                      //   isLoading = false;
                      //   _showDialogWarning("URL API SYNC tidak boleh kosong");
                    } else {
                      // db.deleteConfigAll().then((result) {});
                      Map<String, dynamic> table = {
                        'id': _url_api,
                        'name': _url_api,
                        'descr': _url_api,
                      };

                      Future.delayed(Duration(seconds: 1)).then((onValue) {
                        setState(() {
                          isLoading = false;
                          // db.saveConfig(Config(_url_api, _url_api, _url_api));
                          Navigator.pop(context, table);
                        });
                      });
                    }
                  },
                  child: const Text("SIMPAN"),
                )),
              ]),
            ),
          ],
        ));
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

  void proses() {
    DateTime now = DateTime.now();
    String strTIMESTAMP =
        dailyFormat.format(now) + "T" + hourFormat.format(now) + "+07:00";
    // print(strTIMESTAMP);
    String signature = generateSignature(
      "transsnow",
      strTIMESTAMP,
    );
    // _showDialog(database_name);
    // _showDialog(strTIMESTAMP);
    // _showDialog(signature);
    print(strTIMESTAMP);
    if (signature == "") {
      _showDialog("signature is null");
    } else {
      print("Signature: $signature");
      getapikey(signature, strTIMESTAMP);
    }
  }

  String generateSignature(String secretKey, String timestamp) {
    // header
    String header = base64Encode(utf8.encode(jsonEncode({
      'typ': 'API',
      'alg': 'SHA256',
    })));
    // print('secretKey : ' + secretKey);
    // print('timestamp : ' + timestamp);
    // payload
    String payload = base64Encode(utf8.encode(secretKey));

    String ts = base64Encode(utf8.encode(timestamp));

    // gabungkan
    String secretkey = '$header.$payload.$ts';

    // hasil final
    return base64Encode(utf8.encode(secretkey));
  }

  void getapikey(String secretkey, String timestamp) {
    // showLoadingDialog("Processing...", context);
    fh.apikey(secretkey, "apikey/show", _url_api).then((hasils) {
      print('apikey :');
      print(hasils);
      if (hasils.isNotEmpty) {
        apikey = hasils;
        setState(() {
          strerror = strerror + "\n" + "apikey : " + apikey;
        });

        fh.token(apikey, _url_api).then((hasils) {
          print('token :');
          print(hasils);
          token = hasils;
          setState(() {
            strerror = strerror + "\n" + "token : " + token;
          });
          if (hasils.isNotEmpty) {
            fh.HOdate(apikey, token, "headofficedate/show", _url_api)
                .then((resultdate) {
              print(resultdate);
              setState(() {
                statusurlapi1 = "result : " + resultdate;
                isLoading = false;
                if (resultdate == "success") {
                  strerror = "";
                }
              });
              // if (resultdate.isNotEmpty) {
              //   setState(() {
              //     statusurlapi1 = "success";
              //     strerror = "";
              //     isLoading = false;
              //   });
              // } else {
              //   setState(() {
              //     statusurlapi1 = "error";
              //     isLoading = false;
              //   });
              // }
              // hideLoadingDialog(context);
            });
          } else {
            // hideLoadingDialog(context);
            _showDialog("Token is Empty");
          }
        });
      } else {
        // hideLoadingDialog(context);
        _showDialog("API Key is Empty");
      }
    });
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
          Container(
              child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )),
        ],
      ),
    );
  }
}
