//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'dart:async';

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'crop_screen.dart';

class VideoEditorPage extends StatefulWidget {
  const VideoEditorPage({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<VideoEditorPage> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<VideoEditorPage> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  double _currentSpeed = 1;
  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;
  late VideoPlayerController _playerController;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));

    super.initState();
  }

  @override
  void dispose() {
    _exportingProgress.dispose();
    _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _openCropScreen() => Navigator.push(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              CropScreen(controller: _controller)));

  void _exportVideo() async {
    _exportingProgress.value = 0;
    _isExporting.value = true;
    await _controller.exportVideo(
      onProgress: (stats, value) => _exportingProgress.value = value,
      onError: (e, s) => _exportText = "Error on export video :(",
      onCompleted: (file) {
        _isExporting.value = false;
        if (!mounted) return;

        _playerController = VideoPlayerController.file(file);
        _playerController.setPlaybackSpeed(0.3);
        _playerController.initialize().then((value) async {
          setState(() {});
          _playerController.play();
          _playerController.setLooping(true);
          await showDialog(
            context: context,
            builder: (_) => Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: AspectRatio(
                  aspectRatio: _playerController.value.aspectRatio,
                  child: VideoPlayer(_playerController),
                ),
              ),
            ),
          );
          await _playerController.pause();
          _playerController.dispose();
        });

        _exportText = "Video success export!";
        setState(() => _exported = true);
        Future.delayed(const Duration(seconds: 2),
            () => setState(() => _exported = false));
      },
    );
  }

  void _exportCover() async {
    setState(() => _exported = false);
    await _controller.extractCover(
      onError: (e, s) => _exportText = "Error on cover exportation :(",
      onCompleted: (cover) {
        if (!mounted) return;

        _exportText = "Cover exported! ${cover.path}";
        showDialog(
          context: context,
          builder: (_) => Padding(
            padding: const EdgeInsets.all(30),
            child: Center(child: Image.memory(cover.readAsBytesSync())),
          ),
        );

        setState(() => _exported = true);
        Future.delayed(const Duration(seconds: 2),
            () => setState(() => _exported = false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF646161),
      body: _controller.initialized
          ? SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      TopButtonsRow(),
                      //_topNavBar(),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CropGridViewer(
                                    controller: _controller,
                                    showGrid: false,
                                  ),
                                  AnimatedBuilder(
                                    animation: _controller.video,
                                    builder: (_, __) => OpacityTransition(
                                      visible: !_controller.isPlaying,
                                      child: GestureDetector(
                                        onTap: _controller.video.play,
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.play_arrow,
                                              color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              _EditButtonsRowWidgets(),
                              Container(
                                height: 170,
                                margin: const EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: TabBarView(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: _trimSlider(),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _coverSelection(),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: _isExporting,
                                builder: (_, bool export, __) =>
                                    OpacityTransition(
                                  visible: export,
                                  child: AlertDialog(
                                    backgroundColor: Colors.white,
                                    title: ValueListenableBuilder(
                                      valueListenable: _exportingProgress,
                                      builder: (_, double value, __) => Text(
                                        "Exporting video ${(value * 100).ceil()}%",
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _openCropScreen,
                icon: const Icon(Icons.crop),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _exportCover,
                icon: const Icon(Icons.save_alt, color: Colors.white),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: _exportVideo,
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(
              children: [
                //Text(formatter(Duration(seconds: pos.toInt()))),
                const Expanded(child: SizedBox()),
                OpacityTransition(
                  visible: _controller.isTrimming,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatter(Duration(seconds: start.toInt()))),
                      const SizedBox(width: 10),
                      Text(formatter(Duration(seconds: end.toInt()))),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
          controller: _controller,
          height: height,
          horizontalMargin: height / 4,
        ),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
      //margin: EdgeInsets.symmetric(horizontal: height / 5),
      child: CoverSelection(
        controller: _controller,
        height: height,
        quantity: 8,
      ),
    );
  }
}

class TopButtonsRow extends StatelessWidget {
  const TopButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 16, right: 21, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton(
            onPressed: () => {},
            child: Text("Cancel",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                )),
          ),
          TextButton(
            onPressed: () => {},
            child: Text(
              "Done",
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFFFEDE34),
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _EditButtonsRowWidgets extends StatelessWidget {
  const _EditButtonsRowWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 27),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset("lib/assets/icons/split.svg",
                    color: Colors.yellow, semanticsLabel: '1'),
                onPressed: () {},
              ),
              Text(
                "Split",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset("lib/assets/icons/speed.svg",
                    color: Colors.yellow, semanticsLabel: '2'),
                onPressed: () {},
              ),
              Text(
                "Adjust Speed",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset("lib/assets/icons/mute.svg",
                    color: Colors.yellow, semanticsLabel: '3'),
                onPressed: () {},
              ),
              Text(
                "Volume",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
          Column(
            children: [
              IconButton(
                icon: SvgPicture.asset("lib/assets/icons/delete.svg",
                    color: Colors.yellow, semanticsLabel: '4'),
                onPressed: () {},
              ),
              Text(
                "Delete",
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: Colors.white,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
