//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'package:path/path.dart' as p;
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:ffmpeg_kit_flutter/media_information.dart';
import 'package:ffmpeg_kit_flutter/media_information_session.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_edit_factory/video_factory/video_edit_factory.dart';
import 'package:video_trimmer/video_trimmer.dart';

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
    print(widget.file.path);
    print(p.absolute(widget.file.path));
    print(await _localPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: changeSpeedVideo,
              child: const Text("change speed video (platform version)"),
            ),
            ElevatedButton(
              onPressed: () {
                changeSpeed(path: widget.file.path, speed: 3.0);
              },
              child: Text("change speed video ffmpeg"),
            ),
            ElevatedButton(
              onPressed: (() => print(_localPath)),
              child: Text("get path"),
            )
          ],
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static const videoChannel = const MethodChannel('video_manipulation');

  Future<String> changeSpeedVideo() async {
    final outputPath = await videoChannel.invokeMethod("generateVideo", [
      [
        widget.file.path,
      ],
      "speeedy.mov",
      24,
      2.0
    ]);
    return outputPath;
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
    final c = Completer<String>();
    log(path);
    final length = await lengthOfVideo(path);
    final video = File(path);
    String resultVideoPath = "";
    final Trimmer _trimmer = Trimmer();
    await _trimmer.loadVideo(videoFile: video);
    await _trimmer.saveTrimmedVideo(
      videoFileName: "speedi",
      startValue: 0,
      endValue: length * 100 - 0.5,
      outputFormat: FileFormat.mov,
      ffmpegCommand: 'setpts=0.5*PTS',
      customVideoFormat: ".mov",
      onSave: (outputPath) {
        log(outputPath.toString());
        resultVideoPath = outputPath ?? "io";
        c.complete(outputPath);
      },
    );

    return c.future;
  }
}
