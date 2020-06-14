import 'package:fibermess/pages/game_page/model/levels.dart';

abstract class GameEvent {}

class NewMazeEvent extends GameEvent {
  final int level;

  NewMazeEvent(this.level);
}

class TurnCellLeftEvent extends GameEvent {
  final int cellIndex;

  TurnCellLeftEvent(this.cellIndex);
}

class TurnCellRightEvent extends GameEvent {
  final int cellIndex;

  TurnCellRightEvent(this.cellIndex);
}

class CompleteMazeEvent extends GameEvent {}
