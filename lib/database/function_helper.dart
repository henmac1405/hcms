// import 'package:posdownload/database/db_helper.dart';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms/models/error.dart';
import 'package:hcms/database/db_helper.dart';
import 'package:hcms/user_session.dart';
import 'package:http_parser/http_parser.dart';

class HelperFunction {
  // DatabaseHelper db = DatabaseHelper();
  var dailyFormat = DateFormat("yyyy-MM-dd");
  var hourFormat = DateFormat("HH:mm:ss");
  List<Error> itemerror = [];
  DatabaseHelper db = new DatabaseHelper();

  Future<String> cekkoneksi(String apikey, String token, String url_api) async {
    List? data;
    String strerror = "";
    String str = "";
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
    print(strTIMESTAMP);
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "X-API-KEY": "rahasia123",
    };

    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api),
        headers: headers,
        body: params,
      );
      print('response cek_koneksi :' + response.statusCode.toString());
      print(response.body);
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        // data = json['data'];
        //str = json['data'];
        str = "success";
        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        // var json = jsonDecode(response.body);
        // print('json');
        // print(json['data']);
        str = url_api +
            ' ' +
            response.statusCode.toString() +
            ' ' +
            response.body.toString();
        _toastInfo("cek_koneksi : " + response.statusCode.toString());
        // itemerror
        //     .add(Error("cek_koneksi : " + str, "", DateTime.now().toString()));
        db.saveError(
            Error("cek_koneksi : " + str, "", DateTime.now().toString()));
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      str = e.toString();
      _toastInfo("cek_koneksi : " + e.toString());

      db.saveError(
          Error("cek_koneksi : " + str, "", DateTime.now().toString()));

// itemerror.add(value)
      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      str = e.toString();
      _toastInfo("cek_koneksi : " + e.toString());
      db.saveError(
          Error("cek_koneksi : " + str, "", DateTime.now().toString()));
      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  Future<String> apikey(
      String secretkey, String api_name, String url_api) async {
    List? data;
    String str = "";
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "SECRETKEY": secretkey,
    };

    Map<String, dynamic> params = {};
    print(headers);
    print(params);
    print(url_api + api_name);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        str = json['data'];

        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        str = json['message'];
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  Future<String> token(String apikey, String url_api) async {
    List? data;
    String str = "";
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "X-API-KEY": "rahasia123",
    };
    print(headers);
    print(params);
    print(url_api + "token/show");
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + "token/show"),
        headers: headers,
        body: params,
      );
      print(
          'response  : ' + "token/show" + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        str = json['data'];
        if (json['data'] == "") {
          str = "Error when generate token";
        }
        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        str = json['message'];
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo("token/show" + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo("token/show" + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  Future<List> listcompany(String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "TIMESTAMP": strTIMESTAMP,
    };

    Map<String, dynamic> params = {};
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> absenceonline_show(
      String database_name,
      String employee_id,
      String employee_fingerid,
      String absence_date,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_id": employee_id,
      "employee_fingerid": employee_fingerid,
      "absence_date": absence_date
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> absen_show(
      String database_name,
      String employee_id,
      String employee_fingerid,
      String absence_date,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_id": employee_id,
      "employee_fingerid": employee_fingerid,
      "absence_date": absence_date
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> absenceonline_showsabsenmethod(
      String employee_id,
      String absence_date,
      String absence_method,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_id": employee_id,
      "absence_date": absence_date,
      "absence_method": absence_method
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<String> absenceonline_showstatusabsen(
      String employee_id,
      String absence_date,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    int idata = 0;
    String strstatus = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
    };

    Map<String, dynamic> params = {
      "employee_id": employee_id,
      "absence_date": absence_date,
    };
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        // print(json['data']);
        // data = json['data'];
        idata = json['data'];

        if (json['data'] == 2) {
          strstatus = "selesai";
        } else if (json['data'] == 1) {
          strstatus = "belum OUT";
        } else if (json['data'] == 3) {
          strstatus = "belum IN";
        }
        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else if (response.statusCode == 400) {
        // _toastInfo(json['message']);
        strstatus = "belum INOUT";
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return strstatus;
  }

  Future<List> absenceonline_history(String employee_id, String absence_date,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_id": employee_id,
      "absence_date": absence_date
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> master_leavetype(String database_name, String apikey,
      String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> master_leave_balance(
      String database_name,
      String employee_personalid,
      String year,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_personalid": employee_personalid,
      "tahun": year,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> cuti_history(String database_name, String employee_personalid,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_personalid": employee_personalid,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> requestabsen_history(
      String database_name,
      String employee_personalid,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_personalid": employee_personalid,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> absen_history(String database_name, String employee_fingerid,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_fingerid": employee_fingerid,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> absen_history_bydate(
      String database_name,
      String employee_fingerid,
      String absence_date,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_fingerid": employee_fingerid,
      "absence_date": absence_date,
    };
    // print(token);
    print(url_api + api_name);
    // print(url_api);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<String> requestabsen_insert(
      File imageFile,
      String database_name,
      String employee_personalid,
      String employee_name,
      String requestabsence_subject,
      String requestabsence_datestart,
      String requestabsence_dateend,
      String requestabsence_createlat,
      String requestabsence_createlon,
      String created_by,
      String requestabsence_file,
      String imageuploadname,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strcode = "";
    String imagePath = imageFile.path;

    // 1. Format Waktu & Timezone Offset
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = timeZoneOffset.isNegative ? '-' : '+';
    formattedOffset +=
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:';
    formattedOffset +=
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    // 2. Kredensial & Header Auth
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    // 3. Kumpulan Parameter Teks (Semua nilai harus berupa String)
    Map<String, String> params = {
      "database_name": database_name,
      "employee_personalid": employee_personalid,
      "employee_name": employee_name,
      "requestabsence_subject": requestabsence_subject,
      "requestabsence_datestart": requestabsence_datestart,
      "requestabsence_dateend": requestabsence_dateend,
      "requestabsence_createlat": requestabsence_createlat,
      "requestabsence_createlon": requestabsence_createlon,
      "created_by": created_by,
      "requestabsence_file": requestabsence_file,
      "created_date": requestabsence_datestart
    };

    print(apikey);
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);

    try {
      // 4. Inisialisasi Multipart Request
      var request =
          http.MultipartRequest('POST', Uri.parse(url_api + api_name));

      // 5. Masukkan Headers dan Teks Fields
      request.headers.addAll(headers);
      request.fields.addAll(params);
      request.fields['filename'] = imageuploadname;

      // 6. Masukkan File Gambar
      String fileName = imagePath.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Sesuaikan dengan key multipart yang diminta API Backend Anda
          imagePath,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 7. Kirim Request dan Konversi Hasilnya ke Response Biasa
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('response : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);

      // var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        var json = jsonDecode(response
            .body); // Hanya decode jika sukses atau format JSON pasti valid
        data = json['data'];
        _toastInfo(json['message']);
        strcode = "sukses";
      }
      // 2. DETEKSI ERROR 404 DENGAN AMAN
      else if (response.statusCode == 404) {
        // Amankan pembacaan pesan dari JSON, gunakan fallback jika bukan JSON
        try {
          var json = jsonDecode(response.body);
          _toastInfo(json['message'] ?? 'Halaman atau API tidak ditemukan');
          strcode = json['message'] ?? 'Halaman atau API tidak ditemukan';
        } catch (_) {
          _toastInfo('Error 404: Endpoint API tidak ditemukan di server.');
        }
      }
      // 3. PENANGANAN ERROR LAINNYA
      else {
        try {
          var json = jsonDecode(response.body);
          strcode = response.statusCode.toString() +
              " : " +
              (json['message'] ?? 'Error');
          _toastInfo(response.statusCode.toString() +
              " : " +
              (json['message'] ?? 'Error'));
        } catch (_) {
          strcode = 'Error ${response.statusCode}: Terjadi kesalahan server.';
          _toastInfo('Error ${response.statusCode}: Terjadi kesalahan server.');
        }
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    }

    return strcode;
  }

  Future<String> requestabsen_insert_(
      File imageFile,
      String database_name,
      String employee_personalid,
      String requestabsence_subject,
      String requestabsence_datestart,
      String requestabsence_dateend,
      String requestabsence_createlat,
      String requestabsence_createlon,
      String created_by,
      String requestabsence_file,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;

    String strcode = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "requestabsence_subject": requestabsence_subject,
      "requestabsence_datestart": requestabsence_datestart,
      "requestabsence_dateend": requestabsence_dateend,
      "requestabsence_file": requestabsence_file,
      "requestabsence_createlat": requestabsence_createlat,
      "requestabsence_createlon": requestabsence_createlon,
      "created_by": created_by,
    };
    print(apikey);
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      // if (response.body.length > 0) {}
      // print('1');
      var json = jsonDecode(response.body);
      // print('2');
      if (response.statusCode == 200) {
        // print('3');
        // print('json');
        // print(json['data']);
        // data = json['data'];
        strcode = "sukses";
      } else {
        strcode = json['message'];
        db.saveError(Error(
            api_name + " " + strcode + " " + employee_personalid + " ",
            "",
            DateTime.now().toString()));
        _toastInfo(json['message']);
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // db.saveError(
      //     Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // db.saveError(
      //     Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    }
    return strcode;
  }

  Future<String> cuti_insert(
      String database_name,
      String employee_personalid,
      String leave_date,
      String leavetype_id,
      String leave_qty,
      String leave_datestart,
      String leave_dateend,
      String leave_address,
      String leave_descr,
      String leave_createby,
      String office_id,
      String leave_contact,
      String sisa_cuti,
      String jatah_cuti_bulanan,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;

    String strcode = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "leave_date": leave_date,
      "office_id": office_id,
      "employee_personalid": employee_personalid,
      "leavetype_id": leavetype_id,
      "leave_qty": leave_qty,
      "leave_datestart": leave_datestart,
      "leave_dateend": leave_dateend,
      "leave_address": leave_address,
      "leave_descr": leave_descr,
      "leave_createby": leave_createby,
      "leave_contact": leave_contact,
      "sisa_cuti": sisa_cuti,
      "jatah_cuti": jatah_cuti_bulanan
    };
    print(apikey);
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      // if (response.body.length > 0) {}
      // print('1');
      var json = jsonDecode(response.body);
      // print('2');
      if (response.statusCode == 200) {
        // print('3');
        // print('json');
        // print(json['data']);
        // data = json['data'];
        strcode = "sukses";
      } else {
        strcode = json['message'];
        db.saveError(Error(
            api_name + " " + strcode + " " + employee_personalid + " ",
            "",
            DateTime.now().toString()));
        _toastInfo(json['message']);
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // db.saveError(
      //     Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // db.saveError(
      //     Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    }
    return strcode;
  }

  Future<String> absenceonline_insert(
      String database_name,
      String employee_id,
      String listcompany_id,
      String company_id,
      String office_id,
      String employee_personalid,
      String employee_fingerid,
      String employee_name,
      String absence_method,
      String absence_time,
      String absence_date,
      String absence_image,
      String absence_description,
      String employee_type,
      String absence_remark,
      String absence_dateend,
      String absence_long,
      String absence_lat,
      String absence_deviceinfo,
      String created_by,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;

    String strcode = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_id": employee_id,
      "listcompany_id": listcompany_id,
      "company_id": company_id,
      "office_id": office_id,
      "employee_personalid": employee_personalid,
      "employee_fingerid": employee_fingerid,
      "employee_name": employee_name,
      "absence_method": absence_method,
      "absence_time": absence_time,
      "absence_date": absence_date,
      "absence_image": absence_image,
      "absence_description": absence_description,
      "employee_type": employee_type,
      "absence_remark": absence_remark,
      "absence_dateend": absence_dateend,
      "absence_long": absence_long,
      "absence_lat": absence_lat,
      "absence_deviceinfo": absence_deviceinfo,
      "created_by": created_by
    };
    print(apikey);
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
        strcode = "sukses";
      } else {
        strcode = json['message'];
        db.saveError(Error(
            api_name +
                " " +
                strcode +
                " " +
                employee_personalid +
                " " +
                employee_name,
            "",
            DateTime.now().toString()));
        _toastInfo(json['message']);
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    }
    return strcode;
  }

  Future<String> absenceonline_insert_new(
      File imageFile,
      String imageuploadname,
      String database_name,
      String employee_id,
      String listcompany_id,
      String company_id,
      String office_id,
      String employee_personalid,
      String employee_fingerid,
      String employee_name,
      String absence_method,
      String absence_time,
      String absence_date,
      String absence_image,
      String absence_description,
      String employee_type,
      String absence_remark,
      String absence_dateend,
      String absence_long,
      String absence_lat,
      String absence_deviceinfo,
      String created_by,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strcode = "";
    String imagePath = imageFile.path;

    // 1. Format Waktu & Timezone Offset
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = timeZoneOffset.isNegative ? '-' : '+';
    formattedOffset +=
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:';
    formattedOffset +=
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    // 2. Kredensial & Header Auth
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    // 3. Kumpulan Parameter Teks (Semua nilai harus berupa String)
    Map<String, String> params = {
      "database_name": database_name,
      "employee_id": employee_id,
      "listcompany_id": listcompany_id,
      "company_id": company_id,
      "office_id": office_id,
      "employee_personalid": employee_personalid,
      "employee_fingerid": employee_fingerid,
      "employee_name": employee_name,
      "absence_method": absence_method,
      "absence_time": absence_time,
      "absence_date": absence_date,
      "absence_image": absence_image,
      "absence_description": absence_description,
      "employee_type": employee_type,
      "absence_remark": absence_remark,
      "absence_dateend": absence_dateend,
      "absence_long": absence_long,
      "absence_lat": absence_lat,
      "absence_deviceinfo": absence_deviceinfo,
      "created_by": created_by
    };

    print(apikey);
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);

    try {
      // 4. Inisialisasi Multipart Request
      var request =
          http.MultipartRequest('POST', Uri.parse(url_api + api_name));

      // 5. Masukkan Headers dan Teks Fields
      request.headers.addAll(headers);
      request.fields.addAll(params);
      request.fields['filename'] = imageuploadname;

      // 6. Masukkan File Gambar
      String fileName = imagePath.split('/').last;
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Sesuaikan dengan key multipart yang diminta API Backend Anda
          imagePath,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      // 7. Kirim Request dan Konversi Hasilnya ke Response Biasa
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('response : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);

      var json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
        strcode = "sukses";
      } else {
        strcode = json['message'] ?? "Gagal mengunggah data";
        db.saveError(Error(
            api_name +
                " " +
                strcode +
                " " +
                employee_personalid +
                " " +
                employee_name,
            "",
            DateTime.now().toString()));
        _toastInfo(strcode);
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      db.saveError(
          Error(api_name + " " + e.toString(), "", DateTime.now().toString()));
    }

    return strcode;
  }

  Future<List> login(String employee_personalid, String employee_password,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String str = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_personalid": employee_personalid,
      "password": employee_password
    };
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      str = response.body.toString();
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        // print(json['data']['company']);
        data = json['data'];
        // print(json['message']);
        // data = jsonDecode(response.body);
        // str = "sukses_" + json['data']['company'];

        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        str = json['message'];
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> loginv1(String employee_personalid, String employee_password,
      String secretkey, String api_name, String url_api) async {
    List? data;
    String str = "";
    DateTime now = DateTime.now();

    Map<String, String> headers = {"SecretKey": secretkey};
    Map<String, dynamic> params = {
      "employee_personalid": employee_personalid,
      "password": employee_password
    };

    print(url_api + api_name);
    print(headers);
    print(params);

    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );

      print('response : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      str = response.body.toString();

      // 1. CEK STATUS CODE 200 TERLEBIH DAHULU
      if (response.statusCode == 200) {
        var json = jsonDecode(response
            .body); // Hanya decode jika sukses atau format JSON pasti valid
        data = json['data'];
        _toastInfo(json['message'] ?? 'Login berhasil');
      }
      // 2. DETEKSI ERROR 404 DENGAN AMAN
      else if (response.statusCode == 404) {
        str = "${response.statusCode} : $api_name NOT FOUND";

        // Amankan pembacaan pesan dari JSON, gunakan fallback jika bukan JSON
        try {
          var json = jsonDecode(response.body);
          _toastInfo(json['message'] ?? 'Halaman atau API tidak ditemukan');
        } catch (_) {
          _toastInfo('Error 404: Endpoint API tidak ditemukan di server.');
        }
      }
      // 3. PENANGANAN ERROR LAINNYA
      else {
        try {
          var json = jsonDecode(response.body);
          str = response.statusCode.toString() +
              " : " +
              (json['message'] ?? 'Error');
          _toastInfo(response.statusCode.toString() +
              " : " +
              (json['message'] ?? 'Error'));
        } catch (_) {
          _toastInfo('Error ${response.statusCode}: Terjadi kesalahan server.');
        }
      }
    } on SocketException catch (e) {
      print(e);
      _toastInfo('Koneksi gagal: Periksa internet Anda');
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' Error: ' + e.toString());
    }

    return data ?? [];
  }

  Future<List> loginadmin(String employee_personalid, String apikey,
      String token, String api_name, String url_api) async {
    List? data;
    String str = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_personalid": employee_personalid,
    };
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      str = response.body.toString();
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        // print(json['data']['company']);
        data = json['data'];
      } else {
        str = json['message'];
        _toastInfo(json['message'] + " (SSO)");
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<String> changepassword(
      String employee_personalid,
      String old_password,
      String new_password,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    // old_password = "123456";
    String str = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_personalid": employee_personalid,
      "old_password": old_password,
      "new_password": new_password
    };
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      str = response.body.toString();
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        // print(json['data']['message']);
        // print(json['message']);
        // data = jsonDecode(response.body);
        str = "sukses : " + json['message'];

        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        str = json['message'];
        // _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();
      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      // str = e.toString();
      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  Future<List> employee(String employee_personalid, String database_name,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "employee_personalid": employee_personalid,
      "database_name": database_name
    };
    print(token);
    print(api_name);
    print(url_api);
    print(headers);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      if (response.body.length > 0) {}
      var json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
        // insertlogerror(
        //     "version_get : " + response.body.toString(), _device_id, params.toString(), url_api);
        // Do whatever you want to do with json.
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> employeeshift(
      String database_name,
      String employeeshift_year,
      String employeeshift_month,
      String employee_id,
      String apikey,
      String token,
      String api_name,
      String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "database_name": database_name,
      "employee_id": employee_id,
      "employeeshift_year": employeeshift_year,
      "employeeshift_month": employeeshift_month
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> uploadimage(String apikey, String token, String filename,
      File file, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {"filename": filename, "file": file};
    print(token);
    print(api_name);
    print(url_api);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
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
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<String> HOdate(
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String str = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {};
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
        str = "success";
      } else {
        str = api_name + ' ' + json['message'];
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      str = api_name + ' ' + e.toString();
      _toastInfo(api_name + ' ' + e.toString());
    } catch (e) {
      print(e);
      str = api_name + ' ' + e.toString();
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  Future<List> Setting(String setting_id, String apikey, String token,
      String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {"setting_id": setting_id};
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> SettingAbsenOnline(String setting_id, String apikey,
      String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {"setting_id": setting_id};
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> Shift(String database_name, String shift_id, String apikey,
      String token, String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "shift_id": shift_id,
      "database_name": database_name
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<List> Office(String database_name, String apikey, String token,
      String api_name, String url_api) async {
    List? data;
    String strerror = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {"databasename": database_name};
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        data = json['data'];
      } else {
        _toastInfo(json['message']);
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());

      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return data ?? [];
  }

  Future<(String, int)> fetchDataAndCount() async {
    // Simulate an asynchronous operation
    await Future.delayed(Duration(seconds: 2));

    String data = "Fetched data";
    int count = 10;

    // Return a record containing the multiple values
    return (data, count);
  }

  Future<String> uploadimageabsen(
      File imageFile, String imageuploadname, String apiname) async {
    String imagePath = imageFile.path;
    String str = "";
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = (timeZoneOffset.isNegative ? '-' : '+') +
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:' +
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var dio = Dio();
    String fileName = imagePath.split('/').last;
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
        UserSession.url_api + apiname,
        data: formData,
        options: Options(
          headers: {
            "APIKEY": UserSession.apikey,
            "TIMESTAMP": strTIMESTAMP,
            "TOKEN": UserSession.token,
            'authorization': basicAuth
          },
        ),
        onSendProgress: (int sent, int total) {
          print("sent $sent total $total");
        },
      );

      // 2. LOGIKA JIKA SUKSES: Cetak response server dan pindah halaman
      print("Upload sukses: ${response.data}");
      print("Upload sukses: ${response.data}");
      _toastInfo("Upload Dokumen Sukses");
      str = "sukses";
    } catch (onError) {
      str = "Upload gagal: ${onError}";
      print("Upload gagal: ${onError}");
      _toastInfo("Upload gagal: ${onError}");
      // 3. LOGIKA JIKA GAGAL: Menangkap semua error koneksi/server secara aman
    } finally {
      // 4. LOGIKA BLOK YANG PASTI BERJALAN (Sama seperti whenComplete)
    }
    return str;
  }

  Future<String> uploadimageIDCard(
      File imageFile,
      String imageuploadname,
      String pathname,
      String apiname,
      String apikey,
      String token,
      String url_api) async {
    String imagePath = imageFile.path;
    String str = "";
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = (timeZoneOffset.isNegative ? '-' : '+') +
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:' +
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var dio = Dio();
    String fileName = imagePath.split('/').last;
    print("url_api : $url_api$apiname");
    print("idcard : $pathname$imageuploadname");

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        imagePath,
        filename: fileName,
        contentType: MediaType("image", "jpeg"),
      ),
      "filename": imageuploadname,
      "path": pathname
    });

    try {
      // 1. Eksekusi API Post di dalam blok try
      var response = await dio.post(
        url_api + apiname,
        data: formData,
        options: Options(
          headers: {
            "APIKEY": apikey,
            "TIMESTAMP": strTIMESTAMP,
            "TOKEN": token,
            'authorization': basicAuth
          },
        ),
        onSendProgress: (int sent, int total) {
          print("sent $sent total $total");
        },
      );

      // 2. LOGIKA JIKA SUKSES: Cetak response server dan pindah halaman
      print("Upload sukses: ${response.data}");
      print("Upload sukses: ${response.data}");
      _toastInfo("Upload Dokumen Sukses");
      str = "sukses";
    } catch (onError) {
      str = "Upload gagal: ${onError}";
      print("Upload gagal: ${onError}");
      _toastInfo("Upload gagal: ${onError}");
      // 3. LOGIKA JIKA GAGAL: Menangkap semua error koneksi/server secara aman
    } finally {
      // 4. LOGIKA BLOK YANG PASTI BERJALAN (Sama seperti whenComplete)
    }
    return str;
  }

  Future<String> uploadimageprofile(
      File imageFile, String imageuploadname, String apiname) async {
    String imagePath = imageFile.path;
    String str = "";
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = (timeZoneOffset.isNegative ? '-' : '+') +
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:' +
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var dio = Dio();
    String fileName = imagePath.split('/').last;
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
        UserSession.url_api + apiname,
        data: formData,
        options: Options(
          headers: {
            "APIKEY": UserSession.apikey,
            "TIMESTAMP": strTIMESTAMP,
            "TOKEN": UserSession.token,
            'authorization': basicAuth
          },
        ),
        onSendProgress: (int sent, int total) {
          print("sent $sent total $total");
        },
      );

      // 2. LOGIKA JIKA SUKSES: Cetak response server dan pindah halaman
      print("Upload sukses: ${response.data}");
      print("Upload sukses: ${response.data}");
      _toastInfo("Upload Dokumen Sukses");
      str = "sukses";
    } catch (onError) {
      str = "Upload gagal: ${onError}";
      print("Upload gagal: ${onError}");
      _toastInfo("Upload gagal: ${onError}");
      // 3. LOGIKA JIKA GAGAL: Menangkap semua error koneksi/server secara aman
    } finally {
      // 4. LOGIKA BLOK YANG PASTI BERJALAN (Sama seperti whenComplete)
    }
    return str;
  }

  Future<String> uploadimagephoto(
      File imageFile, String imageuploadname, String apiname) async {
    String imagePath = imageFile.path;
    String str = "";
    DateTime now = DateTime.now();
    Duration timeZoneOffset = now.timeZoneOffset;
    String formattedOffset = (timeZoneOffset.isNegative ? '-' : '+') +
        '${timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:' +
        '${(timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';

    String strTIMESTAMP = dailyFormat.format(now) +
        "T" +
        hourFormat.format(now) +
        formattedOffset;

    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));

    var dio = Dio();
    String fileName = imagePath.split('/').last;
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
        UserSession.url_api + apiname,
        data: formData,
        options: Options(
          headers: {
            "APIKEY": UserSession.apikey,
            "TIMESTAMP": strTIMESTAMP,
            "TOKEN": UserSession.token,
            'authorization': basicAuth
          },
        ),
        onSendProgress: (int sent, int total) {
          print("sent $sent total $total");
        },
      );

      // 2. LOGIKA JIKA SUKSES: Cetak response server dan pindah halaman
      print("Upload sukses: ${response.data}");
      print("Upload sukses: ${response.data}");
      _toastInfo("Upload Dokumen Sukses");
      str = "sukses";
    } catch (onError) {
      str = "Upload gagal: ${onError}";
      print("Upload gagal: ${onError}");
      _toastInfo("Upload gagal: ${onError}");
      // 3. LOGIKA JIKA GAGAL: Menangkap semua error koneksi/server secara aman
    } finally {
      // 4. LOGIKA BLOK YANG PASTI BERJALAN (Sama seperti whenComplete)
    }
    return str;
  }

  Future<String> resetpassword(String employee_personalid, String tgllahir,
      String apikey, String token, String api_name, String url_api) async {
    List? data;
    String str = "";
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
    String username = 'admin';
    String password = '1234';
    String basicAuth =
        'Basic ' + base64Encode(utf8.encode('$username:$password'));
    Map<String, String> headers = {
      "APIKEY": apikey,
      "TIMESTAMP": strTIMESTAMP,
      "TOKEN": token,
      'authorization': basicAuth
    };

    Map<String, dynamic> params = {
      "tgllahir": tgllahir,
      "employee_personalid": employee_personalid
    };
    print(token);
    print(api_name);
    print(url_api);
    print(params);
    try {
      final http.Response response = await http.post(
        Uri.parse(url_api + api_name),
        headers: headers,
        body: params,
      );
      print('response  : ' + api_name + ' ' + response.statusCode.toString());
      print(response.body);
      var json = jsonDecode(response.body);
      if (response.body.length > 0) {}
      if (response.statusCode == 200) {
        print('json');
        print(json['data']);
        // data = json['data'];
        _toastInfo(json['message']);
        str = json['message'];
      } else {
        _toastInfo(json['message']);
        str = json['message'];
      }
      //return Album.fromJson(jsonDecode(response.body));
    } on SocketException catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      str = e.toString();
    } catch (e) {
      print(e);
      _toastInfo(api_name + ' ' + e.toString());
      str = e.toString();
      //return "Error on Server";
      // throw Exception("Error on server");
    }
    //return Album.fromJson(jsonDecode(response.body));
    return str;
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(
        msg: info, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 2);
  }
}
