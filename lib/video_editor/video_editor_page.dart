//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
// ignore_for_file: unused_local_variable

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:flutter/material.dart';
//import 'package:video_edit_factory/video_edit_factory.dart';
import 'package:video_edit_factory/video_factory/video_edit_factory.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_manipulation/video_manipulation.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  List<String> videos = [];

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    // videos = await splitVideoToParts(
    //   durationOfPartInSeconds: 3,
    //   video: widget.file,
    // );
    // final tryToSpeed = videos.first;
    // log(tryToSpeed);
    //await changeSpeed(speed: 2, path: "part2.mov");
    log(videos.toString());
    VideoManipulation.generateVideo([widget.file.path], "zdarova", 30, 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}

Future<double> lengthOfVideo(String filePath) async {
  VideoEditFactory timeVideoEditFactory =
      new VideoEditFactory(inputPath: filePath);
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

Future<List<String>> splitVideoToParts({
  required int durationOfPartInSeconds,
  required File video,
}) async {
  const millisecondsInSec = 1000;

  List<String> videosNames = [];

  final length = await lengthOfVideo(video.path);
  final countOfParts = length ~/ durationOfPartInSeconds;
  final duration = millisecondsInSec * durationOfPartInSeconds;

  for (var i = 0; i < countOfParts; i++) {
    final Trimmer _trimmer = Trimmer();
    await _trimmer.loadVideo(videoFile: video);
    await _trimmer.saveTrimmedVideo(
      videoFileName: "part$i",
      startValue: (i * duration).toDouble(),
      endValue: (i * duration + duration).toDouble(),
      outputFormat: FileFormat.mov,
      onSave: (outputPath) {
        log(outputPath.toString());
        videosNames.add(outputPath ?? "");
      },
    );
    _trimmer.dispose();
  }
  return videosNames;
}

Future<String> changeSpeed({
  required double speed,
  required String path,
}) async {
  const millisecondsInSec = 1000;
  final c = Completer<String>();

  final length = await lengthOfVideo(path);
  final video = File(path);
  String resultVideoPath = "";
  final Trimmer _trimmer = Trimmer();
  await _trimmer.loadVideo(videoFile: video);
  await _trimmer.saveTrimmedVideo(
    videoFileName: "speedi",
    startValue: 0,
    endValue: length,
    outputFormat: FileFormat.mov,
    ffmpegCommand: 'setpts=0.5*PTS',
    onSave: (outputPath) {
      log(outputPath.toString());
      resultVideoPath = outputPath ?? "io";
      c.complete(outputPath);
    },
  );

  return c.future;
}
