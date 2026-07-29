import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hcms/database/function_helper.dart';
import 'package:hcms/database/db_helper.dart';

class OfficePage extends StatefulWidget {
  final String url_api;
  final String token;
  final String apikey;
  final String databasename;
  OfficePage({
    Key? key,
    required this.url_api,
    required this.token,
    required this.apikey,
    required this.databasename,
  }) : super(key: key);
  @override
  _OfficePageState createState() => new _OfficePageState();
}

class _OfficePageState extends State<OfficePage> {
  HelperFunction fh = new HelperFunction();

  List data = [];
  Map<String, dynamic> closed = {
    'id': 'CLOSE',
    'name': 'CLOSE',
    'lat': 0,
    'long': 0,
    'radius': 0
  };

  var formatter = NumberFormat('#,###');
  String _crew_id = '';
  String _crew_name = '';
  String _strappbarname = '';
  String _item_type = '';
  String _branchid = "";
  String _regionid = "";
  String _channelid = "";
  String _machineid = "";
  String _username = "";
  String _userfullname = "";
  String _usercat = "";
  String _strukturunitid = "";
  String _url_api = "";
  bool isLoading = false;

  @override
  void initState() {
    isLoading = true;
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Office'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: isLoading
            ? LinearProgressIndicator()
            : ListView.builder(
                itemCount: data == null ? 0 : data.length,
                padding: const EdgeInsets.all(15.0),
                itemBuilder: (context, index) {
                  return Column(
                    children: <Widget>[
                      Divider(height: 5.0),
                      ListTile(
                        title: Text(
                          data[index]['office_name'],
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.black,
                          ),
                        ),
                        leading: Icon(Icons.adjust),
                        onTap: () {
                          Map<String, dynamic> result = {
                            'id': data[index]['office_id'],
                            'name': data[index]['office_name'],
                            'latitude': data[index]['latitude'],
                            'longitude': data[index]['longitude'],
                            'radius': data[index]['radius']
                          };
                          //  print('data[index]:');
                          //print(disc);
                          Navigator.pop(context, result);
                          //  _prosesdiscount(data[index]['disc_id'],double.parse(data[index]['disc_amount']),widget.log.salesid,widget.log.id);
                        },
                        //onTap: () => _navigateToNote(context, items[position]),
                      ),
                    ],
                  );
                }),
      ),
      persistentFooterButtons: [
        Container(
            width: MediaQuery.of(context).copyWith().size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                onPrimary: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, closed);
              },
              child: new Text("TUTUP"),
            )),
      ],
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () async {
      //     syncsalesman();
      //   },
      //   child: Icon(Icons.refresh),
      //   backgroundColor: Colors.blue,
      // ),
    );
  }

  void getData() {
    fh.Office(widget.databasename, widget.apikey, widget.token,
            "absen/showoffice", widget.url_api)
        .then((result) {
      setState(() {
        data.clear();
        isLoading = false;
      });

      if (result.isNotEmpty) {
        setState(() {
          data = result;
        });
      }
    });
  }
}
