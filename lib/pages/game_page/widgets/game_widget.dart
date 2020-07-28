import 'package:fibermess/common/widgets/fibermess_dialog_widget.dart';
import 'package:fibermess/pages/game_page/widgets/maze_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_paused_popup_widget.dart';
import 'game_won_widget.dart';
import 'statusbar_widget.dart';

class GameWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<GameBloc, GameState>(condition: (oldState, newState) {
        if (newState is GamePausedState) {
          Navigator.of(context).push(FibermessDialog(
              child: GamePausedPopupWidget(),
              onDismissed: () => BlocProvider.of<GameBloc>(context)
                  .add(GameMenuResumedEvent())));
          return false;
        } else if (newState is GameWonState) {
          Navigator.of(context).push(FibermessDialog(
            child: GameWonPopupWidget(nextLevel: newState.level + 1),
          ));
          return false;
        }
        return !(newState is CellsNeedRepaintingState);
      }, builder: (_, gameState) {
        if (gameState is GameResumedState) {
          return MazeWithStatusBarWidget(
              maze: gameState.maze,
              horizontalCellCount: gameState.horizontalCellCount,
              cellSize: gameState.cellSize);
        } else if (gameState is LoadedState) {
          return MazeWithStatusBarWidget(
              maze: gameState.maze,
              horizontalCellCount: gameState.horizontalCellCount,
              cellSize: gameState.cellSize);
        }
        return Center(child: CircularProgressIndicator());
      }),
    );
  }

}

class MazeWithStatusBarWidget extends StatelessWidget {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;
  final bool needClock;

  const MazeWithStatusBarWidget(
      {Key key,
      @required this.maze,
      @required this.horizontalCellCount,
      @required this.cellSize,
      this.needClock = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StatusBarWidget(needClock: needClock),
        Positioned(
          top: 20,
          bottom: 0,
          right: 0,
          left: 0,
          child: MazeWidget(
            maze: maze,
            horizontalCellCount: horizontalCellCount,
            cellSize: cellSize,
          ),
        ),
      ],
    );
  }
}
