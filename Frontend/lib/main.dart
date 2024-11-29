import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MaterialApp(
    home: Login(),
    debugShowCheckedModeBanner: false,
  ));
}
