import 'package:flutter/material.dart';
// import 'package:hcms/home.dart';
// import 'package:hcms/login.dart';
import 'package:hcms/loginnew.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await initializeDateFormatting('id_ID', null);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // String url_api =
  //     "https://api-hcmdev.transentertainment.com/index.php/api/v1/";
  // String url_api_image =
  //     "https://ssodev.transentertainment.com/assets/upload/absen/";

  // String url_image_profile =
  //     "https://ssodev.transentertainment.com/assets/upload/candidate/photos/";

  String url_api_part1 = "https://api-hcmd.transentertainment.com";
  String url_api_part2 = "/index.php/api/v1/";
  String url_api_dev_part1 = "https://api-hcmdev.transentertainment.com";

  String url_api_image_part1 = "https://sso.transentertainment.com";
  String url_api_image_part2 = "/assets/upload/absen/";
  String url_api_image_dev_part1 = "https://ssodev.transentertainment.com";

  String url_image_profile_part1 = "https://sso.transentertainment.com";
  String url_image_profile_part2 = "/assets/upload/candidate/photos/";
  String url_image_profile_dev_part1 = "https://ssodev.transentertainment.com";

  String url_api_slide =
      "https://sso.transentertainment.com/assets/upload/slides/";

  String url_api_lokal = "http://172.16.5.227/api-ci3-dev";

  String debug = "on";
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HCMS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF001668),
      ),
      // home: const LoginPage(title: 'ABSENCE'),
      home: LoginNewPage(
          url_api_part1: url_api_part1,
          url_api_part2: url_api_part2,
          url_api_dev_part1: url_api_dev_part1,
          url_api_image_part1: url_api_image_part1,
          url_api_image_part2: url_api_image_part2,
          url_api_image_dev_part1: url_api_image_dev_part1,
          url_image_profile_part1: url_image_profile_part1,
          url_image_profile_part2: url_image_profile_part2,
          url_image_profile_dev_part1: url_image_profile_dev_part1,
          url_api_slide: url_api_slide,
          url_api_lokal: url_api_lokal,
          debug: debug),
      // home: DropDownPage(),
    );
  }
}
