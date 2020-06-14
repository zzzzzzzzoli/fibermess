import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blur_widget.dart';
import 'cell_widget.dart';
import 'statusbar_widget.dart';

class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      condition: (GameState oldState, GameState newState) =>
        !(newState is CellNeedsRepaintingState),
    builder: (_, gameState) {
      if (gameState is GameWonState) {
        return Stack(
          alignment: AlignmentDirectional.center,
          children: <Widget>[
            buildMazeWidgetWithStatusBar(gameState.maze, gameState.horizontalCellCount, gameState.cellSize, gameState.level),
            BlurWidget(),
            buildCongratsPopup(context, gameState.level)
          ],);
      } else if (gameState is LoadedState) {
        return buildMazeWidgetWithStatusBar(gameState.maze, gameState.horizontalCellCount, gameState.cellSize, gameState.level);
      }

      return Center(child: CircularProgressIndicator());
    });
  }

  Widget buildCongratsPopup(BuildContext context, int level) {
    return Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Congrats',
                    style: TextStyle(color: Colors.red, backgroundColor: Colors.lightGreenAccent, decoration: TextDecoration.none),
                  ),
                ),
                RaisedButton(
                  child: Text('Next level'),
                  onPressed: () =>
                      BlocProvider.of<GameBloc>(context).add(NewMazeEvent(level+1)),
                )
              ],),
          );
  }
  
  Widget buildMazeWidgetWithStatusBar(List<Cell> maze, int horizontalCellCount, double cellSize, int level) {
    return Column(children: [
      StatusBarWidget(level: level),
      MazeWidget(maze: maze, horizontalCellCount: horizontalCellCount, cellSize: cellSize,),
    ],
    );
  }
}

class MazeWidget extends StatelessWidget {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;

  const MazeWidget({Key key, @required this.maze, @required this.horizontalCellCount, @required this.cellSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowWidgets = <Widget>[];
    for (int i = 0; i < maze.length; i += horizontalCellCount) {
      var cellWidgetsInARow = <Widget>[];
      for (int j=i; j<i + horizontalCellCount; j++) {
        cellWidgetsInARow.add(
            GestureDetector(
              child: CellWidget(
                cellIndex: j,
                size: cellSize,),
              onTap: () => BlocProvider.of<GameBloc>(context).add(TurnCellRightEvent(j)),
//              onDoubleTap: () => BlocProvider.of<GameBloc>(context).add(TurnCellLeftEvent(j)),
            )
        );
      }
      rowWidgets.add(Row(children: cellWidgetsInARow));
    }
    return Container(
      child: Column(children: rowWidgets), color: Colors.black,);

  }
}


//
//class _GameState extends State<GameWidget> {
//
//  List<Cell> maze;
//  List<Widget> cellWidgets;
//  Widget mazeWidget;
//  StatusBarWidget statusBarWidget;
//  ClockWidget clockWidget;
//  Set<int> indicesToBeRepainted = {};
//  MazeColorMixer colorMixer;
//  int level;
//  int horizontalCellCount;
//  int verticalCellCount;
//  double widgetSize;
//
//  @override
//  void initState() {
//    level = widget.startLevel;
//    _getMaze();
//    clockWidget = ClockWidget();
//    statusBarWidget = StatusBarWidget(colorMixer: colorMixer, level: level, clockWidget: clockWidget,);
//    super.initState();
//  }
//
//  void _getMaze() {
//    Level lvl = _getLevelForScreen(level);
//    maze = MazeGenerator(lvl).getMaze();
//    colorMixer = MazeColorMixer(lvl);
//    maze = colorMixer.colorMaze(maze);
//  }
//
//  void _nextMaze() {
//    setState(() {
//      level++;
//      cellWidgets = null;
//      _getMaze();
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    if (cellWidgets == null) { // no widgets build yet
//      cellWidgets = [];
//      for (int i = 0; i < maze.length; i++) {
//        cellWidgets.add(GestureDetector(
//          child: CellWidget(
//            cell: maze[i],
//            size: widgetSize,),
//          onTap: () => _turnCell(i),
//        ));
//      }
//    } else {
//      for (int i in indicesToBeRepainted) {
//        cellWidgets[i] = GestureDetector(
//          child: CellWidget(
//            cell: maze[i],
//            size: widgetSize,),
//          onTap: () => _turnCell(i),
//        );
//      }
//      indicesToBeRepainted = {};
//    }
//    var rowWidgets = <Widget>[];
//    rowWidgets.add(statusBarWidget);
//    for (int i = 0; i < maze.length; i += horizontalCellCount) {
//      var cellWidgetsInARow = <Widget>[];
//      for (int j=i; j<i + horizontalCellCount; j++) {
//        cellWidgetsInARow.add(cellWidgets[j]);
//      }
//      rowWidgets.add(Row(children: cellWidgetsInARow));
//    }
//    mazeWidget = Container(
//      child: Column(children: rowWidgets), color: Colors.black,);
//
//    if (colorMixer.complete) {
//
//    }
//    return mazeWidget;
//
//  }
//
//  void _turnCell(int index) {
//    setState(() {
//      maze = colorMixer.turnAndRecolorMaze(index, indicesToBeRepainted);
//    });
//  }
//
////  void resetMaze() {
////    _getMaze();
////  }
//}