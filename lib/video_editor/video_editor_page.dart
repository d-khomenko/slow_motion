//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//

import 'dart:io';
import 'package:flutter/material.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  _onButtonTap() {}

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
