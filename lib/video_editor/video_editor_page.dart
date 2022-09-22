//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  _onButtonTap() {
    final fileName = widget.file.path.split('/').last;
    //print(fileName);
    //print(fileName);

    FFmpegKit.execute('-i $fileName -c:v mpeg4 file2.mp4')
        .then((session) async {
      final returnCode = await session.getReturnCode();
      final startTime = session.getStartTime();
      //final anotherValue = session.

      if (ReturnCode.isSuccess(returnCode)) {
        final a = 123;
      } else if (ReturnCode.isCancel(returnCode)) {
        final b = 2;
      } else {
        // ERROR

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.lightBlue,
            ),
          ),
          ElevatedButton(
              onPressed: _onButtonTap, child: Text("Do some with video")),
        ],
      ),
    );
  }
}
