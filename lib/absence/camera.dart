import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CameraWithRemarkScreen extends StatefulWidget {
  const CameraWithRemarkScreen({
    super.key,
    required this.remark,
  });
  final String remark;

  @override
  State<CameraWithRemarkScreen> createState() => _CameraWithRemarkScreenState();
}

class _CameraWithRemarkScreenState extends State<CameraWithRemarkScreen> {
  GlobalKey _repaintBoundaryKey = GlobalKey();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _remarkController = TextEditingController();

  Future<void> _captureAndSave() async {
    try {
      RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List? pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        final directory = await getApplicationDocumentsDirectory();
        // final path = '${directory.path}/my_widget_image.png';
        final path = '/storage/emulated/0/Download/my_widget_image.png';
        final file = File(path);
        await file.writeAsBytes(pngBytes);
        print('path : ');
        print(path);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image saved to: $path')),
        );
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveImageWithRemark() {
    if (_imageFile != null && _remarkController.text.isNotEmpty) {
      // Logic to save _imageFile and _remarkController.text
      print('Image saved with remark: ${_remarkController.text}');
      // You can then navigate away or clear the state
    } else {
      print('Please capture an image and add a remark.');
    }
  }

  @override
  void initState() {
    super.initState();
    _takePicture();
  }

  @override
  void dispose() {
    // _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera')),
      body: Column(
        // Use Column to arrange widgets vertically
        children: [
          RepaintBoundary(
            key: _repaintBoundaryKey,
            child: Stack(
              // Your Stack widget
              alignment: Alignment.center,
              children: [
                _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : const Text('No image captured yet.'),
                Positioned(
                  // bottom: 20.0,
                  top: 0,
                  child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              widget.remark,
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
                                  fontSize: 8.0,
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
          const SizedBox(height: 20), // Add some spacing
          ElevatedButton(
            // Your button placed after the Stack
            onPressed: () {
              // Handle button press
              // _takePicture();
              _captureAndSave();
              print('Button pressed!');
            },
            child: const Text('Save Image'),
          ),
          const SizedBox(height: 20), // Add some spacing
          ElevatedButton(
            // Your button placed after the Stack
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
