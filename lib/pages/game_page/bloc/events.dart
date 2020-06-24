import 'package:fibermess/pages/game_page/model/levels.dart';

abstract class GameEvent {}

class NewMazeEvent extends GameEvent {
  final int level;

  NewMazeEvent(this.level);
}

class MazeRestoredEvent extends GameEvent {}

class TurnCellLeftEvent extends GameEvent {
  final int cellIndex;

  TurnCellLeftEvent(this.cellIndex);
}

class TurnCellRightEvent extends GameEvent {
  final int cellIndex;

  TurnCellRightEvent(this.cellIndex);
}

class CompleteMazeEvent extends GameEvent {}

class GameMenuPausedEvent extends GameEvent {}

class GameMenuResumedEvent extends GameEvent {}

class ShuffleMazeEvent extends GameEvent {}

class MazeAvailableEvent extends GameEvent {}

class SelectLevelEvent extends GameEvent {
  final int selectedLevel;

  SelectLevelEvent(this.selectedLevel);

}