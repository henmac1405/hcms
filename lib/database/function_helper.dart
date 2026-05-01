// import 'package:posdownload/database/db_helper.dart';
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

  Future<(String, int)> fetchDataAndCount() async {
    // Simulate an asynchronous operation
    await Future.delayed(Duration(seconds: 2));

    String data = "Fetched data";
    int count = 10;

    // Return a record containing the multiple values
    return (data, count);
  }

  _toastInfo(String info) {
    Fluttertoast.showToast(
        msg: info, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 2);
  }
}
