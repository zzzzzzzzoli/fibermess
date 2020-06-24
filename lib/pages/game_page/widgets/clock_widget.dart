import 'dart:async';
import 'dart:ui';

import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClockWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<ClockWidget> with WidgetsBindingObserver {
  int seconds = 0;
  String timeString = '00:00';
  Timer timer;
  GameBloc bloc;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      condition: (oldState, newState) {
        if (newState is GameResumedState) {
          _startTimer();
        } else if ((oldState is GameWonState || oldState is MazeAvailableState)
            && newState is LoadedState) {
          timeString = '00:00';
          seconds = 0;
          _startTimer();
        } else if (newState is GamePausedState
            || newState is GameWonState) {
          _stopTimer();
        }
        return false;
      },
      builder: (context, state) {
        return Container(
          width: 75,
          child:
          Text(timeString, style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            decoration: TextDecoration.none,
            fontFamily: 'AudioWide',),),
        );
      },
    );
  }

  @override
  void initState() {
    bloc = BlocProvider.of<GameBloc>(context);
    seconds = bloc.pausedSeconds;
    _buildTimeString();
    _startTimer();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void _startTimer() {
    if (timer == null || !timer.isActive) {
      timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    }
  }

  void _stopTimer() {
    if (timer != null && timer.isActive)
      timer.cancel();
  }

  void _getTime() {
    setState(() {
      seconds++;
      _buildTimeString();
    });
  }

  void _buildTimeString()  {
    String secs = '${seconds%60}';
    if (secs.length < 2) secs = secs.padLeft(2 , '0');
    String minutes = '${seconds~/60}';
    if (minutes.length < 2) minutes = minutes.padLeft(2 , '0');
    timeString = '$minutes:$secs';
  }

  @override
  void deactivate() {
    bloc.pausedSeconds = seconds;
    super.deactivate();
  }

  @override
  void dispose() {
    timer.cancel();
    timer = null;
    bloc.saveMaze();
    bloc = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      if (timer != null) timer.cancel();
      if (bloc != null) bloc.saveMaze();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }

}
