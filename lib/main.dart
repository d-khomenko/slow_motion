import 'package:flutter/material.dart';
import 'package:slow_motion/video_editor/video_picker_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Video Editor Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
        textTheme: const TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
        ).apply(
          bodyColor: Color.fromARGB(255, 32, 25, 25),
          displayColor: Colors.white,
        ),
      ),
      home: const VideoPickerPage(),
    );
  }
}
