import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class CurrentTimeDisplay extends StatefulWidget {
  const CurrentTimeDisplay({Key? key}) : super(key: key);

  @override
  _CurrentTimeDisplayState createState() => _CurrentTimeDisplayState();
}

class _CurrentTimeDisplayState extends State<CurrentTimeDisplay> {
  late String currentTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });
  }

  String _getCurrentTime() {
    return DateFormat('HH:mm:ss').format(DateTime.now());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          const Text(
            'Update Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            currentTime,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
