//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:flutter/material.dart';
//import 'package:video_edit_factory/video_edit_factory.dart';
import 'package:path/path.dart' as path;
import 'package:slow_motion/video_editor/custom_video_edit_factory.dart';

import 'crop.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  @override
  void initState() {
    super.initState();
    final filePath = widget.file.path;
    final newFile = getPart(filePath);
  }

  void videoEdit(String filePath) {
    CustomVideoEditFactory videoEditFactory =
        new CustomVideoEditFactory(inputPath: filePath);

    final folderPath = path.dirname("$filePath");

    // 获取媒体文件信息
    videoEditFactory.getMediaInfo(executeCallback: (Session session) {
      MediaInformationSession mediaInformationSession =
          session as MediaInformationSession;

      MediaInformation? mediaInformation =
          mediaInformationSession.getMediaInformation();
    });

    videoEditFactory
      // 设置视频比特率
      // Set video bit rate
      ..setBitRate(8)
      // 设置视频帧数
      // Set the number of video frames
      ..setOutPutFPS(30)
      // 设置输出文件的大小
      // Set the size of the output file
      ..setOutputVideoSize(100)
      // 设置输出格式
      // Set output format
      ..setType('mov')
      // 剪切视频指定区间（单位：秒）
      // Cut video specified interval (unit: second)
      ..cutByDoubleTime(0, 2.5)
      // 设置输出文件的宽高
      // Set the width and height of the output file
      ..setOutputVideoSale(1080, 1920)
      // 设置超时时间（仅限获取文件信息时生效）
      // Set the timeout period (valid only when the file information is obtained)
      // 设置输出文件名称
      // Set the output file name
      ..setOutputName('cropped25s')
      // 设置文件的输出目录
      // Set the output directory of the file
      ..setOutputPath(folderPath);

    File videoFile;
    // 执行视频编辑命令
    // Execute video editing commands
    videoEditFactory.executeAsync(executeCallback: (Session session) async {
      await videoEditFactory
          .getOutputFile(session)
          .then((value) => videoFile = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
