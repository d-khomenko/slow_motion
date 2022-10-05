import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:flutter/material.dart';

//-------------------//
//VIDEO EDITOR SCREEN//
//-------------------//
import 'dart:async';
import 'dart:io';
import 'package:helpers/helpers/transition.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';
import 'crop_screen.dart';

class ChangeSpeedScreen extends StatefulWidget {
  const ChangeSpeedScreen({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  State<ChangeSpeedScreen> createState() => _VideoEditorPageState();
}

class _VideoEditorPageState extends State<ChangeSpeedScreen> {
  final _exportingProgress = ValueNotifier<double>(0.0);
  final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  var data = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0];

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
      // preset: VideoExportPreset.medium,
      // customInstruction: "-crf 17",
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
    List<Color> gradientColors = [
      Color(0xFF4A452D),
      Color(0xFF2C2B2B),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF2C2B2B),
      body: _controller.initialized
          ? SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _topNavBar(),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: TabBarView(
                                  physics: const NeverScrollableScrollPhysics(),
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
                                                child: const Icon(
                                                    Icons.play_arrow,
                                                    color: Colors.black),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    CoverViewer(controller: _controller)
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  color: Color(0xFF2C2B2B),
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 78.0),
                                        child: Container(
                                          height: 220,
                                          //width: MediaQuery.of(context).size.width,
                                          child: Sparkline(
                                            max: 2.0,
                                            min: 0.0,
                                            data: data,
                                            useCubicSmoothing: true,
                                            cubicSmoothingFactor: 0.15,
                                            averageLine: true,
                                            averageLabel: false,
                                            pointsMode: PointsMode.all,
                                            lineColor: Color(0xFFFEDE34),
                                            fillMode: FillMode.below,
                                            pointSize: 10.0,
                                            pointColor: Colors.white,
                                            fillGradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: gradientColors),
                                          ),
                                        ),
                                      ),
                                      SliderTheme(
                                        data: SliderThemeData(
                                          trackHeight: 1.0,
                                        ),
                                        child: Slider(
                                          inactiveColor: Colors.grey,
                                          activeColor: Colors.amber,
                                          value: _currentSpeed,
                                          min: 0,
                                          max: 2,
                                          divisions: 20,
                                          onChanged: (newSpeed) => {
                                            setState(
                                              () {
                                                _currentSpeed = newSpeed;
                                                final occuredValue =
                                                    newSpeed + 0.25;
                                                _controller.video
                                                    .setPlaybackSpeed(
                                                        occuredValue);
                                                final indexSpot =
                                                    _findSpotForChange();
                                                //graphicSpots[indexSpot] =
                                                //    FlSpot(indexSpot * 5, newSpeed);
                                              },
                                            )
                                          },
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("123"),
                                          Text("123"),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              _customSnackBar(),
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
          : const Center(child: CircularProgressIndicator()),
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
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(formatter(Duration(seconds: start.toInt()))),
                  const SizedBox(width: 10),
                  Text(formatter(Duration(seconds: end.toInt()))),
                ]),
              )
            ]),
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
            child: TrimTimeline(
                controller: _controller,
                margin: const EdgeInsets.only(top: 10))),
      )
    ];
  }

  Widget _coverSelection() {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: height / 5),
        child: CoverSelection(
          controller: _controller,
          height: height,
          quantity: 8,
        ));
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  int _findSpotForChange() {
    final part = _controller.maxTrim / 16;
    final attitude = _controller.trimPosition / part;

    return (attitude % 16).truncate();
  }
}
