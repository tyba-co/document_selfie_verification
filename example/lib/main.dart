import 'package:flutter/material.dart';
import 'camera_app.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MaterialApp(
    home: CameraApp(),
  ));
}