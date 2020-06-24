import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:fibermess/pages/game_page/model/levels.dart';

abstract class GameState {
  final int level;

  GameState(this.level);
}

class LoadingState extends GameState {
  LoadingState() : super(0);
}

class LoadedState extends GameState {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;

  LoadedState(this.maze, this.horizontalCellCount, this.cellSize, int level) : super(level);

}

class GameWonState extends GameState {
  final List<Cell> maze;

  final int horizontalCellCount;
  final double cellSize;

  GameWonState(this.maze, this.horizontalCellCount, this.cellSize, int level) : super(level);
}

class CellsNeedRepaintingState extends GameState {
  final List<Cell> maze;
  final Set<int> indices;

  CellsNeedRepaintingState(this.maze, this.indices, int level) : super(level);
}

class GamePausedState extends GameState {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;

  GamePausedState(this.maze, this.horizontalCellCount, this.cellSize, int level) : super(level);

}

class GameResumedState extends GameState {
  final List<Cell> maze;
  final int horizontalCellCount;
  final double cellSize;
  GameResumedState(this.maze, this.horizontalCellCount, this.cellSize, int level) : super(level);

}

class MazeAvailableState extends GameState {
  MazeAvailableState(int level) : super(level);
}

class LevelSelectedState extends GameState {
  final Level selectedLevel;
  LevelSelectedState(this.selectedLevel, int level) : super(level);
}