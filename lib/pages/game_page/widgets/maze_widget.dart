import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:flutter/material.dart';
import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/widgets/cell_widget.dart';
import 'gesture_transformable_widget.dart';

class MazeWidget extends StatelessWidget {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;

  const MazeWidget(
      {Key key,
        @required this.maze,
        @required this.horizontalCellCount,
        @required this.cellSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowWidgets = <Widget>[];
    for (int i = 0; i < maze.length; i += horizontalCellCount) {
      var cellWidgetsInARow = <Widget>[];
      for (int j = i; j < i + horizontalCellCount; j++) {
        cellWidgetsInARow.add(GestureDetector(
          child: CellWidget(
            cellIndex: j,
            size: cellSize,
          ),
          onTap: () =>
              BlocProvider.of<GameBloc>(context).add(TurnCellRightEvent(j)),
        ));
      }
      rowWidgets.add(Row(children: cellWidgetsInARow));
    }
    var width = BlocProvider.of<GameBloc>(context).screenWidth;
    var height = BlocProvider.of<GameBloc>(context).screenHeight;
    return GestureTransformable(
      size: Size(width, height),
      boundaryRect: Rect.fromLTWH(0, 0, width, height),
      child: Column(
        children: rowWidgets,
      ),
    );
  }
}
