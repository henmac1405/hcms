// import 'dart:async';
// import 'dart:io';
// import 'package:intl/intl.dart';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'dart:ui' as ui;
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_image_compress/flutter_image_compress.dart';
// import 'package:path/path.dart' show join;

// // Future<void> main() async {
// //   // Ensure that plugin services are initialized so that `availableCameras()`
// //   // can be called before `runApp()`
// //   WidgetsFlutterBinding.ensureInitialized();

// //   // Obtain a list of the available cameras on the device.
// //   final cameras = await availableCameras();

// //   // Get a specific camera from the list of available cameras.
// //   final firstCamera = cameras.first;

// //   runApp(
// //     MaterialApp(
// //       theme: ThemeData.dark(),
// //       home: CameraHomePage(
// //         // Pass the appropriate camera to the CameraHomePage widget.
// //         camera: firstCamera,
// //       ),
// //     ),
// //   );
// // }

// // A screen that allows users to take a picture using a given camera.
// class CameraHomePage extends StatefulWidget {
//   const CameraHomePage({
//     super.key,
//     required this.camera,
//   });

//   final CameraDescription camera;

//   @override
//   CameraHomePageState createState() => CameraHomePageState();
// }

// class CameraHomePageState extends State<CameraHomePage> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   GlobalKey _repaintBoundaryKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     // To display the current output from the Camera,
//     // create a CameraController.
//     _controller = CameraController(
//       // Get a specific camera from the list of available cameras.
//       widget.camera,
//       // Define the resolution to use.
//       ResolutionPreset.medium,
//     );

//     // Next, initialize the controller. This returns a Future.
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed.
//     _controller.dispose();
//     super.dispose();
//   }

//   Future<void> _captureAndSave() async {
//     var imageFormat = DateFormat("yyyyMMddHHmmss");
//     DateTime now = DateTime.now();
//     String imgname = imageFormat.format(now);
//     try {
//       RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
//           .findRenderObject() as RenderRepaintBoundary;
//       ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       ByteData? byteData =
//           await image.toByteData(format: ui.ImageByteFormat.png);
//       Uint8List? pngBytes = byteData?.buffer.asUint8List();

//       if (pngBytes != null) {
//         final directory = await getApplicationDocumentsDirectory();
//         // final path = '${directory.path}/my_widget_image.png';
//         final path = '/storage/emulated/0/Download/' + imgname + '.jpg';
//         final file = File(path);
//         await file.writeAsBytes(pngBytes);
//         print('path : ');
//         print(path);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Image saved to: $path')),
//         );

//         final Uint8List? compressedImageBytes =
//             await FlutterImageCompress.compressWithFile(
//           path,
//           minWidth: 500, // Desired width
//           minHeight: 500, // Desired height
//           quality: 80, // Compression quality (0-100)
//         );

//         // Save the compressed image bytes to a new file
//         if (compressedImageBytes != null) {
//           final File resizedFile =
//               File(join('/storage/emulated/0/Download/', imgname + '.jpg'));
//           await resizedFile.writeAsBytes(compressedImageBytes);
//           print(resizedFile.path);
//         }
//       }
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to save image: $e')),
//       );
//     }
//   }

//   // Future<void> _ResizeImage() async {
//   //   final Uint8List? compressedImageBytes =
//   //       await FlutterImageCompress.compressWithFile(
//   //     image.path,
//   //     minWidth: 500, // Desired width
//   //     minHeight: 500, // Desired height
//   //     quality: 80, // Compression quality (0-100)
//   //   );

//   //   // Save the compressed image bytes to a new file
//   //   if (compressedImageBytes != null) {
//   //     final File resizedFile = File(join(directory.path, 'resized_image.jpg'));
//   //     await resizedFile.writeAsBytes(compressedImageBytes);
//   //   }
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Take a picture')),
//       // You must wait until the controller is initialized before displaying the
//       // camera preview. Use a FutureBuilder to display a loading spinner until the
//       // controller has finished initializing.
//       body: FutureBuilder<void>(
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
//                                 "Your Overlay Text Here",
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
//       floatingActionButton: FloatingActionButton(
//         // Provide an onPressed callback.
//         onPressed: () async {
//           // Take the Picture in a try / catch block. If anything goes wrong,
//           // catch the error.
//           _captureAndSave();

//           // try {
//           //   // Ensure that the camera is initialized.
//           //   await _initializeControllerFuture;

//           //   // Attempt to take a picture and get the file `image`
//           //   // where it was saved.
//           //   final image = await _controller.takePicture();

//           //   if (!context.mounted) return;

//           //   // If the picture was taken, display it on a new screen.
//           //   await Navigator.of(context).push(
//           //     MaterialPageRoute(
//           //       builder: (context) => DisplayPictureScreen(
//           //         // Pass the automatically generated path to
//           //         // the DisplayPictureScreen widget.
//           //         imagePath: image.path,
//           //       ),
//           //     ),
//           //   );
//           // } catch (e) {
//           //   // If an error occurs, log the error to the console.
//           //   print(e);
//           // }
//         },
//         child: const Icon(Icons.camera_alt),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }

// // A widget that displays the picture taken by the user.
// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;

//   const DisplayPictureScreen({super.key, required this.imagePath});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Display the Picture')),
//       // The image is stored as a file on the device. Use the `Image.file`
//       // constructor with the given path to display the image.
//       body: Image.file(File(imagePath)),
//     );
//   }
// }
