import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/maze.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'clock_widget.dart';



class StatusBarWidget extends StatelessWidget {

  final int level;

  const StatusBarWidget({Key key, @required this.level}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          RaisedButton(child: Text('New Maze'), onPressed: () {
            BlocProvider.of<GameBloc>(context).add(NewMazeEvent(level));
          },),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: Text('Level $level',
              style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
            ),
          ),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: BlocBuilder<GameBloc, GameState>(
              builder: (_, gameState) {
                var total = BlocProvider.of<GameBloc>(context).lightsCount;
                var on = BlocProvider.of<GameBloc>(context).lightsOnCount;
                return Text('$on/$total',
                  style: TextStyle(color: Colors.white, decoration: TextDecoration.none),
                );
              },
            ),
          ),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: ClockWidget(),
          )
        ],
      ),
    );
  }

}