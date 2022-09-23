//-------------------//
//PICKUP VIDEO SCREEN//
//-------------------//
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'video_editor_page.dart';

class VideoPickerPage extends StatefulWidget {
  const VideoPickerPage({Key? key}) : super(key: key);

  @override
  State<VideoPickerPage> createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage> {
  final ImagePicker _picker = ImagePicker();

  void _pickVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (mounted && file != null) {
      Navigator.push(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) =>
                  VideoEditorPage(file: File(file.path))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF646161),
      appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Image / Video Picker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Click on Pick Video to select video",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("Pick Video From Gallery"),
            ),
          ],
        ),
      ),
    );
  }
}
