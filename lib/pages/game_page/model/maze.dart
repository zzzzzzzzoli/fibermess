//import 'dart:collection';
//
//import 'package:collection/collection.dart';
//import 'dart:math';
//import 'cell.dart';
//import 'levels.dart';
//
//class MazeGenerator {
//
//  final int width;
//  final int height;
//  final int sourcesCount;
//  final bool wrap;
//  final int linksCount;
//
//  int _availableCellCount;
//  List<int> _edges;
//  List<Cell> _maze;
//  Set<int> _sourceCoordinates = {};
//  int _remainingLinks;
//
//  MazeGenerator.custom({this.width, this.height, this.sourcesCount, this.linksCount = 0, this.wrap = false});
//
//  MazeGenerator(Level level) :
//    this.width = level.width,
//    this.height = level.height,
//    this.sourcesCount = level.sources,
//    this.linksCount = level.links,
//    this.wrap = level.wrap;
//
//
//}
//
//class MazeColorMixer {
//
//  Function equalSets = const DeepCollectionEquality().equals;
//
//  List<Cell> maze;
//  final int width;
//  final int height;
//  final bool wrap;
//  bool complete = false;
//  int lightsOn;
//  int lights;
//
//  MazeColorMixer.custom(this.width, this.height, this.wrap);
//
//  MazeColorMixer(Level level) :
//      this.width = level.width,
//      this.height = level.height,
//      this.wrap = level.wrap;
//
//  List<Cell> colorMaze(List<Cell> cells) {
//    maze = cells;
//    // identifying sources and lights
//    lights = 0;
//    lightsOn = 0;
//    List<int> sources = [];
//    for (int i = 0; i < maze.length; i++) {
//      if (maze[i].type == CellType.source) {
//        sources.add(i);
//      } else if (maze[i].type == CellType.end) {
//        lights++;
//      }
//    }
//    // propagating colors from each source
//    for (int source in sources) {
//      for (Side s in maze[source].connections) {
//        maze[source].sourceSideColors[s].addAll(maze[source].originalColor);
//        addColorToCell(calcStep(source, s), oppositeSide(s), maze[source].originalColor.last);
//      }
//    }
//    complete = lights == lightsOn;
//    return maze;
//  }
//
//  void addColorToCell(int cellCoordinate, Side from, CellColor color) {
//    if (0 <= cellCoordinate && cellCoordinate < maze.length) {
//      Cell cell = maze[cellCoordinate];
//      cell.sourceSideColors[from].add(color);
//      if (cell.type == CellType.source) {
//        return;
//      }
//      Set<Side> sidesToVisit = {};
//      if (cell.connections.contains(from)) {
//        cell.color.add(color);
//        lightsOn += cell.isOn ? 1 : 0;
//        sidesToVisit = cell.connections.difference({from});
//      } else if (cell.bridgeConnections.contains(from)) {
//        cell.bridgeColor.add(color);
//        sidesToVisit = cell.bridgeConnections.difference({from});
//      }
//      for (Side s in sidesToVisit) {
//        addColorToCell(calcStep(cellCoordinate, s), oppositeSide(s), color);
//      }
//    }
//  }
//
//  List<Cell> turnAndRecolorMaze(int index, Set<int> indicesToBeRepainted) {
//    Cell cell = maze[index];
//    if (cell.connections.length == 0 || cell.connections.length == 4) {
//      return maze; // cell with no connections or all four sides connected makes no difference when turned
//    }
//    indicesToBeRepainted.add(index);
//    bool wasOn = cell.isOn;
//    if (cell.type == CellType.end) {
//      // End/light has no outgoing light
//      cell.turn();
//      cell.color = cell.sourceSideColors[cell.connections.first];
//      if (wasOn && !cell.isOn) lightsOn--;
//      if (!wasOn && cell.isOn) lightsOn++;
//
//    } else {
//      // Source and through have light going out
//      // 1st remove all color from connecting sides
//      for (Side s in cell.connections.union(cell.bridgeConnections)) {
//        recolorMaze(calcStep(index, s), oppositeSide(s), {}, indicesToBeRepainted);
//      }
//
//      // 2nd we turn the cell and get the actual color
//      cell.turn();
//
//      if (cell.type == CellType.source) {
//        for (Side s in cell.connections) {
//          // adding original color again to the sides in case they were overwritten
//          cell.sourceSideColors[s].addAll(cell.originalColor);
//        }
//      } else {
//        cell.color = {};
//        for (Side s in cell.connections) {
//          cell.color.addAll(cell.sourceSideColors[s]);
//        }
//        cell.bridgeColor = {};
//        for (Side s in cell.bridgeConnections) {
//          cell.bridgeColor.addAll(cell.sourceSideColors[s]);
//        }
//      }
//
//      // 3rd propagating the actual color
//      // from sources only original color goes out / special use of sourceSideColors
//      if (cell.type == CellType.source) {
//        for (Side s in cell.connections) {
//          recolorMaze(calcStep(index, s), oppositeSide(s), cell.originalColor, indicesToBeRepainted);
//        }
//      } else {
//        for (Side s in cell.connections) {
//          Set<CellColor> outColor = {};
//          // getting all the colors coming in from other connected sides
//          for (Side side in cell.connections.difference({s})) {
//            outColor.addAll(cell.sourceSideColors[side]);
//          }
//          recolorMaze(calcStep(index, s), oppositeSide(s), outColor, indicesToBeRepainted);
//        }
//        for (Side s in cell.bridgeConnections) {
//          Set<CellColor> outColor = {};
//          // getting all the colors coming in from other connected sides
//          for (Side side in cell.bridgeConnections.difference({s})) {
//            outColor.addAll(cell.sourceSideColors[side]);
//          }
//          recolorMaze(calcStep(index, s), oppositeSide(s), outColor, indicesToBeRepainted);
//        }
//      }
//    }
//
//    complete = lights == lightsOn;
//    return maze;
//  }
//
//  void recolorMaze(int index, Side from, Set<CellColor> color, Set<int> indicesToBeRepainted) {
//    if (0 <= index && // valid index
//        !equalSets(maze[index].sourceSideColors[from], color)) { // only need to recolor if new colors are different
//      indicesToBeRepainted.add(index);
//      Cell cell = maze[index];
//      cell.sourceSideColors[from] = Set.of(color);
//      if (cell.type == CellType.source) {
//        cell.sourceSideColors[from].addAll(cell.originalColor); // adding original color that was overwritten
//      } else if (cell.connections.contains(from)) {
//        bool wasOn = cell.isOn;
//        cell.color = {};
//        for (Side s in cell.connections) {
//          cell.color.addAll(cell.sourceSideColors[s]);
//        }
//        if (wasOn && !cell.isOn) lightsOn--;
//        if (!wasOn && cell.isOn) lightsOn++;
//        for (Side side in cell.connections) {
//          Set<CellColor> outColors = {};
//          for (Side s in cell.connections.difference({side})) {
//            outColors.addAll(cell.sourceSideColors[s]);
//          }
//          recolorMaze(calcStep(index, side), oppositeSide(side), outColors, indicesToBeRepainted);
//        }
//
//      } else if (cell.bridgeConnections.contains(from)) {
//        cell.bridgeColor = {};
//        for (Side s in cell.bridgeConnections) {
//          cell.bridgeColor.addAll(cell.sourceSideColors[s]);
//        }
//        for (Side side in cell.bridgeConnections) {
//          Set<CellColor> outColors = {};
//          for (Side s in cell.bridgeConnections.difference({side})) {
//            outColors.addAll(cell.sourceSideColors[s]);
//          }
//          recolorMaze(calcStep(index, side), oppositeSide(side), outColors, indicesToBeRepainted);
//        }
//      }
//    }
//  }
//
//  int calcStep(int from, Side step) {
//    return MazeGenerator.staticCalcStep(from, step, width, height, maze.length, wrap);
//  }
//
//}
