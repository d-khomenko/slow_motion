import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:path/path.dart' as path;
import 'custom_video_edit_factory.dart';

Future<File> getPart(String filePath) async {
  final c = Completer<File>();
  File result;
  final folderPath = path.dirname("$filePath");

  ///double length = await lengthOfVideo(filePath);

  CustomVideoEditFactory videoEditFactory =
      new CustomVideoEditFactory(inputPath: filePath);

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
    ..cutByTime(5, 10)
    //..changeSpeed(2)

    // 设置输出文件的宽高
    // Set the width and height of the output file
    ..setOutputVideoSale(1080, 1920)
    // 设置超时时间（仅限获取文件信息时生效）
    // Set the timeout period (valid only when the file information is obtained)
    // 设置输出文件名称
    // Set the output file name
    ..setOutputName('speed')
    // 设置文件的输出目录
    // Set the output directory of the file
    ..setOutputPath(folderPath);

  // Execute video editing commands
  videoEditFactory.executeAsync(executeCallback: (Session session) async {
    await videoEditFactory.getOutputFile(session).then((value) {
      result = value;
      print(result.path);
      c.complete(result);
    });
  });

  return c.future;
}

Future<double> lengthOfVideo(String filePath) async {
  CustomVideoEditFactory timeVideoEditFactory =
      new CustomVideoEditFactory(inputPath: filePath);
  double duration;
  final c = Completer<double>();

  await timeVideoEditFactory.getMediaInfo(executeCallback: (Session session) {
    MediaInformationSession mediaInformationSession =
        session as MediaInformationSession;
    MediaInformation? mediaInformation =
        mediaInformationSession.getMediaInformation();
    final stringDuration = mediaInformation?.getDuration();
    final t = double.tryParse(stringDuration ?? "") ?? 0;
    duration = t;
    c.complete(duration);
  });

  return c.future;
}

Future<File> setSpeedForPartOfVideo(double speed, File file) {
  final filePath = file.path;
  final folderPath = path.dirname("$filePath");
  File resultPart;
  final c = Completer<File>();

  CustomVideoEditFactory videoEditFactory =
      new CustomVideoEditFactory(inputPath: filePath);

  videoEditFactory
    ..setType('mov')
    ..changeSpeed(2)
    ..setOutputName('speeeeeed')
    ..setOutputPath(folderPath);

  videoEditFactory.executeAsync(executeCallback: (Session session) async {
    await videoEditFactory.getOutputFile(session).then((value) {
      resultPart = value;
      c.complete(resultPart);
    });
  });

  return c.future;
}
