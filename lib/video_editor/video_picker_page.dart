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
      //backgroundColor: const Color(0xFF646161),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 100, left: 66, right: 65),
              child: const Text(
                "New Project 1",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32.0,
                ),
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.all(44.0),
              child: TextButton(
                onPressed: _pickVideo,
                child: _ChooseGalleryButtonWidget(),
              ),
            ),
            SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChooseGalleryButtonWidget extends StatelessWidget {
  const _ChooseGalleryButtonWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      child: Ink(
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 202, 10),
                Color.fromARGB(255, 255, 170, 0)
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(15.0)),
        child: Container(
          constraints: BoxConstraints(maxWidth: 900.0, minHeight: 50.0),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Choose from gallery",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 17),
              ),
              SizedBox(
                width: 18,
              ),
              Icon(Icons.image_outlined, color: Colors.black)
            ],
          ),
        ),
      ),
    );
  }
}
