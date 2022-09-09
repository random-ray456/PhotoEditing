// ignore_for_file: library_private_types_in_public_api

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remove_bg_example/api_client.dart';
import 'package:screenshot/screenshot.dart';

class RemoveBackground extends StatefulWidget {
  const RemoveBackground({super.key});

  @override
  _RemoveBackgroundState createState() => _RemoveBackgroundState();
}

class _RemoveBackgroundState extends State<RemoveBackground> {
  Uint8List? imageFile;

  String? imagePath;

  ScreenshotController controller = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff764abc),
          actions: [
            IconButton(
                onPressed: () {
                  getImage(ImageSource.gallery);
                },
                icon: const Icon(Icons.image),
                tooltip: "Gallery"),
            IconButton(
              onPressed: () {
                getImage(ImageSource.camera);
              },
              icon: const Icon(Icons.camera_alt),
              tooltip: "Camera",
            ),
            IconButton(
              onPressed: () async {
                imageFile = await ApiClient().removeBgApi(imagePath!);
                setState(() {});
              },
              icon: const Icon(Icons.delete),
              tooltip: "Remove Background",
            ),
            IconButton(
              onPressed: () async {
                saveImage();
              },
              icon: const Icon(Icons.save),
              tooltip: "Save",
            )
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              (imageFile != null)
                  ? Screenshot(
                      controller: controller,
                      child: Image.memory(
                        imageFile!,
                      ),
                    )
                  : Container(
                      width: 300,
                      height: 300,
                      color: Colors.grey[300]!,
                      child: const Icon(
                        Icons.image,
                        size: 100,
                      ),
                    ),
            ],
          ),
        ));
  }

  void getImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage != null) {
        imagePath = pickedImage.path;
        imageFile = await pickedImage.readAsBytes();
        setState(() {});
      }
    } catch (e) {
      imageFile = null;
      setState(() {});
    }
  }

  void saveImage() async {
    bool isGranted = await Permission.storage.status.isGranted;
    if (!isGranted) {
      isGranted = await Permission.storage.request().isGranted;
    }

    if (isGranted) {
      String directory = (await getExternalStorageDirectory())!.path;
      String fileName =
          DateTime.now().microsecondsSinceEpoch.toString() + ".png";
      controller.captureAndSave(directory, fileName: fileName);
    }
  }
}
