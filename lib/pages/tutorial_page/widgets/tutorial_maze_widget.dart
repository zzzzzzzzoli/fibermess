import 'package:fibermess/common/widgets/cell_widget.dart';
import 'package:fibermess/pages/tutorial_page/bloc/bloc.dart';
import 'package:fibermess/pages/tutorial_page/bloc/events.dart';
import 'package:fibermess/pages/tutorial_page/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TutorialMazeWidget extends StatelessWidget {

  final TutorialState state;
  final double cellSize;

  const TutorialMazeWidget({Key key, @required this.state, @required this.cellSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var rowWidgets = <Widget>[];
    for (int i = 0; i < state.maze.length; i += state.horizontalCellCount) {
      var cellWidgetsInARow = <Widget>[];
      for (int j = i; j < i + state.horizontalCellCount; j++) {
        cellWidgetsInARow.add(GestureDetector(
          child: CellWidget(
            cellIndex: j,
            size: cellSize,
            isTutorial: true,
          ),
          onTap: () =>
              BlocProvider.of<TutorialBloc>(context).add(TutorialTurnCellEvent(j)),
        ));
      }
      rowWidgets.add(Row(children: cellWidgetsInARow, mainAxisSize: MainAxisSize.min));
    }
    return Container(
      decoration: BoxDecoration(border: Border.all(width: 1, color: Colors.white60)),
        child: Column(children: rowWidgets)
    );
  }

}