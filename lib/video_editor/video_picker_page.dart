//-------------------//
//PICKUP VIDEO SCREEN//
//-------------------//
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import 'video_editor_page.dart';

class VideoPickerPage extends StatefulWidget {
  const VideoPickerPage({Key? key}) : super(key: key);

  @override
  State<VideoPickerPage> createState() => _VideoPickerPageState();
}

class _VideoPickerPageState extends State<VideoPickerPage> {
  final ImagePicker _picker = ImagePicker();
  String _batteryPercentage = "battery percentage";

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
            Text(
              "$_batteryPercentage",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
              ),
            ),
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text("Pick Video From Gallery"),
            ),
            ElevatedButton(
                onPressed: _getBatteryInformation,
                child: const Text("get Battery Info"))
          ],
        ),
      ),
    );
  }

  static const batteryChannel = const MethodChannel('battery');

  Future<void> _getBatteryInformation() async {
    String batteryPercentage;
    try {
      var result = await batteryChannel.invokeMethod('getBatteryLevel');
      batteryPercentage = 'battery lvl at $result';
    } on PlatformException catch (e) {
      batteryPercentage = "failed to get battery level ${e.message}";
    } catch (e) {
      batteryPercentage = "no implementation for this platform";
    }

    setState(() {
      _batteryPercentage = batteryPercentage;
    });
  }
}
