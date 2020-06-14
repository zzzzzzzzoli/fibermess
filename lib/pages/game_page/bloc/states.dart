import 'package:fibermess/pages/game_page/model/cell.dart';

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

class CellNeedsRepaintingState extends GameState {
  final Cell cell;
  final int cellIndex;

  CellNeedsRepaintingState(this.cell, this.cellIndex, int level) : super(level);
}