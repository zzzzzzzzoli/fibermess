import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

class ClockWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClockWidgetState();

}

class _ClockWidgetState extends State<ClockWidget> with WidgetsBindingObserver {

  int seconds = 0;
  String timeString = '00:00';
  Timer timer;

  @override
  Widget build(BuildContext context) {
    return Text(timeString, style: TextStyle(color: Colors.white, decoration: TextDecoration.none, fontFeatures: [FontFeature.tabularFigures()]));
  }

  @override
  void initState() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void stop() {
    timer.cancel();
  }

  void _getTime() {
    setState(() {
      seconds++;
      String secs = '${seconds%60}';
      if (secs.length < 2) secs = secs.padLeft(2 , '0');
      String minutes = '${seconds~/60}';
      if (minutes.length < 2) minutes = minutes.padLeft(2 , '0');

      timeString = '$minutes:$secs';
    });
  }

  @override
  void dispose() {
    timer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && timer != null) {
      timer.cancel();
    }
    if (state == AppLifecycleState.resumed &&
        (timer == null || !timer.isActive)) {
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    }
  }


}
