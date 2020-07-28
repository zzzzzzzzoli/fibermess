import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:fibermess/pages/game_page/model/levels.dart';
import 'package:fibermess/secrets.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameBloc extends Bloc<GameEvent, GameState> {

  InterstitialAd _interstitialAd;
  int pausedSeconds = 0;
  int maxLevel = 1;

  double screenWidth;
  double screenHeight;
  int level;
  int horizontalCellCount;
  int verticalCellCount;
  double widgetSize;
  List<Cell> maze;
  int sourcesCount;
  int lightsCount;
  int lightsOnCount;
  int linksCount;
  int dummyCount;
  bool wrap;
  Set<int> sourceCoordinates = {};

  bool get isComplete => lightsCount == lightsOnCount;

  static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>['game', 'maze', 'logic', 'netwalk', 'colourshift', 'fibermess', 'single player'],
    testDevices: <String>['DAC6078EDDA37CBED75275C8CB871041'],
  );

  GameBloc({this.level = 1}) {
    getSavedMazeIfAny();
    _interstitialAd = createInterstitialAd()..load();
  }

  InterstitialAd createInterstitialAd() {
    return InterstitialAd(
      adUnitId: getLevelUpAdUnitId(),
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("InterstitialAd event $event");
        if (event == MobileAdEvent.clicked || event == MobileAdEvent.closed) {
          add(NewMazeEvent(level+1));
          _interstitialAd?.dispose();
          _interstitialAd = createInterstitialAd()..load();
        } else if (event == MobileAdEvent.failedToLoad) {
          Future.delayed(Duration(seconds: 5),
          () => _interstitialAd = createInterstitialAd()..load());
        }
      },
    );
  }

  @override
  GameState get initialState {
    return LoadingState();
  }

  @override
  Stream<GameState> mapEventToState(GameEvent event) async* {
    switch (event.runtimeType) {
      case ShowInterstitialAdEvent:
        bool isLoaded = false;
        try {
          isLoaded = await _interstitialAd.isLoaded();
        } catch (e) {
          _interstitialAd = createInterstitialAd()..load();
          print(e);
        }
        if (isLoaded) _interstitialAd.show();
        else add(NewMazeEvent(level+1));
        break;
      case SelectLevelEvent:
        int lvl = (event as SelectLevelEvent).selectedLevel;
        yield LevelSelectedState(levels[lvl], lvl);
        break;
      case NewMazeEvent:
        pausedSeconds = 0;
        _getLevelInfoForScreen((event as NewMazeEvent).level);
        maze = getMaze();
        yield MazeAvailableState(level);
        yield LoadedState(maze, horizontalCellCount, widgetSize, level);
        break;
      case MazeRestoredEvent:
        yield MazeAvailableState(level);
        yield LoadedState(maze, horizontalCellCount, widgetSize, level);
        break;
      case TurnCellRightEvent:
        var indices =
            turnAndGetIndicesToRecolor((event as TurnCellRightEvent).cellIndex);
        yield CellsNeedRepaintingState(maze, indices, level);
        if (isComplete) add(CompleteMazeEvent());
        break;
      case CompleteMazeEvent:
        setMaxLevel(level + 1);
        yield GameWonState(maze, horizontalCellCount, widgetSize, level);
        break;
      case GameMenuPausedEvent:
        yield GamePausedState(maze, horizontalCellCount, widgetSize, level);
        break;
      case GameMenuResumedEvent:
        yield GameResumedState(maze, horizontalCellCount, widgetSize, level);
        break;
      case ShuffleMazeEvent:
        shuffleAndRecolorMaze();
        yield LoadedState(maze, horizontalCellCount, widgetSize, level);
        break;
    }
  }

  void _getLevelInfoForScreen(int l) {
    if (screenWidth <= (screenHeight - 20)) {
      // portrait
      widgetSize = screenWidth / levels[l].width;
      horizontalCellCount = levels[l].width;
      verticalCellCount =
          (horizontalCellCount * (screenHeight - 20) / screenWidth).floor();
    } else {
      // landscape
      widgetSize = (screenHeight - 20) / levels[l].width;
      verticalCellCount = levels[l].width;
      horizontalCellCount =
          (verticalCellCount * screenWidth / (screenHeight - 20)).floor();
    }
    dummyCount = levels[l].dummies;
    sourcesCount = levels[l].sources;
    linksCount = levels[l].links;
    wrap = levels[l].wrap;
    level = l;
  }

  List<Cell> getMaze() {
    maze = List<Cell>(horizontalCellCount * verticalCellCount);
    var edges = List();
    var availableCellCount = maze.length;
    var remainingLinks = linksCount;
    sourceCoordinates = {};
    Set<int> dummyCoordinates = {};

    // picking colors for sources
    List<CellColor> sourceColors = List();
    sourceColors.add(CellColor.values[Random().nextInt(3)]);
    for (int i = 1; i < sourcesCount; i++) {
      int lastColorIndex = sourceColors[i - 1].index;
      int newColorIndex = lastColorIndex > 1 ? 0 : lastColorIndex + 1;
      sourceColors.add(CellColor.values[newColorIndex]);
    }
    // add sources
    while (sourceCoordinates.length < sourcesCount) {
      int source = Random().nextInt(horizontalCellCount * verticalCellCount);
      sourceCoordinates.add(source);
    }
    // add dummies
    while (dummyCoordinates.length < dummyCount) {
      int dummy = Random().nextInt(horizontalCellCount * verticalCellCount);
      if (!sourceCoordinates.contains(dummy)) {
        Set<int> surroundingCoordinates = {};
        for (Side side in Side.values) {
          surroundingCoordinates.add(calcStep(dummy, side));
          surroundingCoordinates.add(calcSteps(dummy, [side, turnSide(side)]));
        }
        if (surroundingCoordinates.union(dummyCoordinates).length ==
            surroundingCoordinates.length + dummyCoordinates.length) {
          dummyCoordinates.add(dummy);
          maze[dummy] = Cell.source({});
          availableCellCount--;
        }
      }
    }
    for (int source in sourceCoordinates) {
      maze[source] = Cell.source({sourceColors.last});
      sourceColors.removeLast();
      edges.add(source);
      availableCellCount--;
    }
    while (availableCellCount > 0) {
      // picking a random edge
      int edge = edges[Random().nextInt(edges.length)];
      // picking a random direction
      List directions = availableSides(edge);
      if (directions.length < 1) {
        edges.remove(edge);
      } else {
        var steps = directions[Random().nextInt(directions.length)];
        int nextCell = calcSteps(edge, steps);
        maze[nextCell] = Cell.through();
        availableCellCount--;
        connect(edge, steps);
        if (availableSides(nextCell).length > 0) {
          edges.add(nextCell);
        } else {
          // if a segment should have multiple sources we add it here
          if (remainingLinks > 0) {
            // finding already connected sources to pick different color
            var connectedSourceColors = <CellColor>{};
            var q = new Queue<int>();
            var seen = <int>{};
            q.add(nextCell);
            while (q.isNotEmpty && connectedSourceColors.length < 3) {
              int cellIndex = q.removeLast();
              if (!seen.contains(cellIndex) &&
                  maze[cellIndex].type == CellType.source) {
                seen.add(cellIndex);
                connectedSourceColors.addAll(maze[cellIndex].originalColor);
              } else {
                seen.add(cellIndex);
                for (Side side in maze[cellIndex].connections) {
                  int next = calcStep(cellIndex, side);
                  if (!seen.contains(next)) q.add(next);
                }
              }
            }
            // if already have all three base colors, not adding another source
            if (connectedSourceColors.length == 3) {
              // we close the end with a light
              closeOpenEdge(nextCell);
            } else {
              // we get a color not in the connected source colors
              var differentColor = CellColor.values
                  .toSet()
                  .difference(connectedSourceColors)
                  .first;
              maze[nextCell]
                ..type = CellType.source
                ..sourceSideColors = {
                  Side.up: {differentColor},
                  Side.down: {differentColor},
                  Side.left: {differentColor},
                  Side.right: {differentColor}
                }
                ..originalColor = {differentColor};
              remainingLinks--;
              sourceCoordinates.add(nextCell);
            }
          } else {
            // else we close it with a light
            closeOpenEdge(nextCell);
          }
        }
      }
    }
    for (int d in dummyCoordinates) maze[d] = Cell.hub();
    closeAllOpenEdges();
    colorLights();
    shuffle();
    return colorMaze();
  }

  void closeAllOpenEdges() {
    for (int i = 0; i < (horizontalCellCount * verticalCellCount); i++) {
      closeOpenEdge(i);
    }
  }

  void shuffle() {
    for (Cell cell in maze) {
      int turn = Random().nextInt(4);
      for (int i = 0; i < turn; i++) {
        cell.turn();
      }
    }
  }

  void shuffleAndRecolorMaze() {
    lightsOnCount = 0;
    for (Cell cell in maze) {
      cell.color = {};
      cell.bridgeColor = {};
      cell.sourceSideColors = {
        Side.up: {},
        Side.down: {},
        Side.left: {},
        Side.right: {},
      };
      int turn = Random().nextInt(4);
      for (int i = 0; i < turn; i++) {
        cell.turn();
      }
    }
    for (int source in sourceCoordinates) {
      for (Side s in maze[source].connections) {
        maze[source].sourceSideColors[s].addAll(maze[source].originalColor);
        addColorToCell(calcStep(source, s), oppositeSide(s),
            maze[source].originalColor.last);
      }
    }
  }

  void colorLights() {
    for (int source in sourceCoordinates) {
      for (Side s in maze[source].connections) {
        addOriginalColorIfLight(calcStep(source, s), oppositeSide(s),
            maze[source].originalColor.last);
      }
    }
  }

  void addOriginalColorIfLight(int cellCoordinate, Side from, CellColor color) {
    if (cellCoordinate >= 0) {
      Cell cell = maze[cellCoordinate];
      if (cell.type == CellType.end) {
        cell.originalColor.add(color);
      } else if (cell.type == CellType.through) {
        Set<Side> sidesToGo;
        if (cell.bridgeConnections.contains(from)) {
          sidesToGo = cell.bridgeConnections.difference({from});
        } else if (cell.connections.contains(from)) {
          sidesToGo = cell.connections.difference({from});
        }
        for (Side s in sidesToGo) {
          addOriginalColorIfLight(
              calcStep(cellCoordinate, s), oppositeSide(s), color);
        }
      }
    }
  }

  int calcSteps(int from, List<Side> steps) {
    int result = from;
    for (Side s in steps) {
      result = calcStep(result, s);
    }
    return result;
  }

  int calcStep(int from, Side step) {
    return staticCalcStep(
        from, step, horizontalCellCount, verticalCellCount, maze.length, wrap);
  }

  static int staticCalcStep(
      int from, Side step, int width, int height, int mazeLength, bool wrap) {
    switch (step) {
      case Side.left:
        if (from % width > 0) {
          return from - 1;
        } else if (wrap && from % width == 0) {
          return from + width - 1;
        }
        break;
      case Side.up:
        if (from >= width) {
          return from - width;
        } else if (wrap) {
          return from + (height - 1) * width;
        }
        break;
      case Side.right:
        if ((from + 1) % width != 0) {
          return from + 1;
        } else if (wrap) {
          return from + 1 - width;
        }
        break;
      case Side.down:
        if (from + width < mazeLength) {
          return from + width;
        } else if (wrap) {
          return from - (height - 1) * width;
        }
        break;
    }
    return -1; // invalid step
  }

  void connect(int edge, List<Side> sides) {
    maze[edge].connections.add(sides.first);
    int nxt = calcStep(edge, sides.first);
    if (sides.length == 1) {
      // connecting adjacent cell
      maze[nxt].connections.add(oppositeSide(sides.first));
    } else {
      // connecting to a cell on the other side of an adjacent one
      maze[nxt].bridgeConnections = {oppositeSide(sides.first), sides.last};
      maze[nxt].bridgeColor = {};
      int nxt2 = calcStep(nxt, sides.last);
      maze[nxt2].connections.add(oppositeSide(sides.last));
      maze[nxt2].color = {};
    }
    maze[nxt].color = {};
    maze[edge].color = {};
  }

  void closeOpenEdge(int edge) {
    if (maze[edge].connections.length == 1 &&
        maze[edge].type != CellType.source) {
      maze[edge]
        ..type = CellType.end
        ..originalColor = {};
    }
  }

  List<List<Side>> availableSides(int i) {
    List<List<Side>> result = [];
    for (Side s in Side.values) {
      int next = calcStep(i, s);
      if (next < 0) {
        continue;
      }
      int twoOver = calcStep(next, s);
      int corner1 = calcStep(next, turnSideInDirection(s, -1));
      int corner2 = calcStep(next, turnSideInDirection(s, 1));
      if (maze[next] == null) {
        result.add([s]);
      } else if (maze[next].type == CellType.through &&
          maze[next].connections.length == 2) {
        if (twoOver > 0 &&
            maze[twoOver] == null &&
            maze[next].connections.containsAll(
                {turnSideInDirection(s, 1), turnSideInDirection(s, -1)})) {
          result.add([s, s]);
        }
        if (corner1 > 0 &&
            maze[corner1] == null &&
            maze[next]
                .connections
                .containsAll({s, turnSideInDirection(s, 1)})) {
          result.add([s, turnSideInDirection(s, -1)]);
        }
        if (corner2 > 0 &&
            maze[corner2] == null &&
            maze[next]
                .connections
                .containsAll({s, turnSideInDirection(s, 1)})) {
          result.add([s, turnSideInDirection(s, 1)]);
        }
      }
    }
    return result;
  }

  List<Cell> colorMaze() {
    lightsCount = 0;
    lightsOnCount = 0;
    for (Cell c in maze) {
      if (c.type == CellType.end) lightsCount++;
    }
    // propagating colors from each source
    for (int source in sourceCoordinates) {
      for (Side s in maze[source].connections) {
        maze[source].sourceSideColors[s].addAll(maze[source].originalColor);
        addColorToCell(calcStep(source, s), oppositeSide(s),
            maze[source].originalColor.last);
      }
    }
    return maze;
  }

  void addColorToCell(int cellCoordinate, Side fromSide, CellColor color) {
    if (0 <= cellCoordinate && cellCoordinate < maze.length) {
      Queue queue = new Queue();
      Map<int, Set<Side>> seen = HashMap(); // avoiding loops
      queue.add([cellCoordinate, fromSide]);
      while (queue.isNotEmpty) {
        var popped = queue.removeLast();
        int index = popped[0];
        if (index >= 0) {
          Cell cell = maze[index];
          Side from = popped[1];
          if (!seen.containsKey(index) || !seen[index].contains(from)) {
            seen.putIfAbsent(index, () => {});
            seen[index].add(from);
            cell.sourceSideColors[from].add(color);
            if (cell.type != CellType.source) {
              Set<Side> sidesToVisit = {};
              if (cell.connections.contains(from)) {
                bool wasOn = cell.isOn;
                cell.color.add(color);
                if (wasOn && !cell.isOn) {
                  lightsOnCount--;
                }
                if (!wasOn && cell.isOn) {
                  lightsOnCount++;
                }
                sidesToVisit = cell.connections.difference({from});
              } else if (cell.bridgeConnections.contains(from)) {
                cell.bridgeColor.add(color);
                sidesToVisit = cell.bridgeConnections.difference({from});
              }
              for (Side s in sidesToVisit) {
                queue.add([calcStep(index, s), oppositeSide(s)]);
              }
            }
          }
        }
      }
    }
  }

  Set<int> turnAndGetIndicesToRecolor(int index) {
    Set<int> indicesToRecolor = {};
    Cell cell = maze[index];
    if (cell.connections.length == 0 || cell.connections.length == 4) {
      return indicesToRecolor; // cell with no connections or all four sides connected makes no difference when turned
    }

    bool wasOn = cell.isOn;
    if (cell.type == CellType.end) {
      // End/light has no outgoing light
      cell.turn();
      cell.color = cell.sourceSideColors[cell.connections.first];
      if (wasOn && !cell.isOn) {
        lightsOnCount--;
      }
      if (!wasOn && cell.isOn) {
        lightsOnCount++;
      }
      indicesToRecolor.add(index);

    } else {
      // Source and through have light going out
      // 1st remove all color from connecting sides
      for (Side s in cell.connections.union(cell.bridgeConnections)) {
        indicesToRecolor.addAll(
            getIndicesToRecolor(calcStep(index, s), oppositeSide(s), {}));
      }

      // 2nd we turn the cell and get the actual color
      cell.turn();

      if (cell.type == CellType.source) {
        for (Side s in cell.connections) {
          // adding original color again to the sides in case they were overwritten
          cell.sourceSideColors[s].addAll(cell.originalColor);
        }
      } else {
        cell.color = {};
        for (Side s in cell.connections) {
          cell.color.addAll(cell.sourceSideColors[s]);
        }
        cell.bridgeColor = {};
        for (Side s in cell.bridgeConnections) {
          cell.bridgeColor.addAll(cell.sourceSideColors[s]);
        }
      }
      indicesToRecolor.add(index);
      // 3rd propagating the actual color
      // from sources only original color goes out / special use of sourceSideColors
      if (cell.type == CellType.source) {
        for (Side s in cell.connections) {
          indicesToRecolor.addAll(getIndicesToRecolor(
              calcStep(index, s), oppositeSide(s), cell.originalColor));
        }
      } else {
        for (Side s in cell.connections) {
          Set<CellColor> outColor = {};
          // getting all the colors coming in from other connected sides
          for (Side side in cell.connections.difference({s})) {
            outColor.addAll(cell.sourceSideColors[side]);
          }
          indicesToRecolor.addAll(getIndicesToRecolor(
              calcStep(index, s), oppositeSide(s), outColor));
        }
        for (Side s in cell.bridgeConnections) {
          Set<CellColor> outColor = {};
          // getting all the colors coming in from other connected sides
          for (Side side in cell.bridgeConnections.difference({s})) {
            outColor.addAll(cell.sourceSideColors[side]);
          }
          indicesToRecolor.addAll(getIndicesToRecolor(
              calcStep(index, s), oppositeSide(s), outColor));
        }
      }
    }
    return indicesToRecolor;
  }

  Set<int> getIndicesToRecolor(int startIndex, Side fromSide, Set<CellColor> startColor) {
    Queue queue = new Queue();
    Set<int> indicesToRecolor = {};
    Map<int, Set<Side>> seen = HashMap(); // avoiding loops
    queue.add([startIndex, fromSide, startColor]);
    while (queue.isNotEmpty) {
      var val = queue.removeLast();
      int index = val[0];
      Side from = val[1];
      Set<CellColor> color = val[2];
      if (0 <= index &&
          (!seen.containsKey(index) || !seen[index].contains(from)) &&
          !SetEquality().equals(maze[index].sourceSideColors[from], color)) {
        // only need to recolor if new colors are different
        seen.putIfAbsent(index, () => {});
        seen[index].add(from);
        Cell cell = maze[index];
        cell.sourceSideColors[from] = Set.of(color);
        if (cell.type == CellType.source) {
          cell.sourceSideColors[from].addAll(
              cell.originalColor); // adding original color that was overwritten
          indicesToRecolor.add(index);
        } else if (cell.connections.contains(from)) {
          bool wasOn = cell.isOn;
          cell.color = {};
          for (Side s in cell.connections) {
            cell.color.addAll(cell.sourceSideColors[s]);
          }
          indicesToRecolor.add(index);
          if (wasOn && !cell.isOn) {
            lightsOnCount--;
          }
          if (!wasOn && cell.isOn) {
            lightsOnCount++;
          }
          for (Side side in cell.connections) {
            Set<CellColor> outColors = {};
            for (Side s in cell.connections.difference({side})) {
              outColors.addAll(cell.sourceSideColors[s]);
            }
            queue.add([calcStep(index, side), oppositeSide(side), outColors]);
          }
        } else if (cell.bridgeConnections.contains(from)) {
          cell.bridgeColor = {};
          for (Side s in cell.bridgeConnections) {
            cell.bridgeColor.addAll(cell.sourceSideColors[s]);
          }
          indicesToRecolor.add(index);
          for (Side side in cell.bridgeConnections) {
            Set<CellColor> outColors = {};
            for (Side s in cell.bridgeConnections.difference({side})) {
              outColors.addAll(cell.sourceSideColors[s]);
            }
            queue.add([calcStep(index, side), oppositeSide(side), outColors]);
          }
        }
      }
    }
    return indicesToRecolor;
  }

  Future<void> saveMaze() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var mazeJson = jsonEncode(maze.map((e) => e.toJson()).toList());
    prefs.setString("maze", mazeJson);
    prefs.setInt("level", level);
    prefs.setInt("width", horizontalCellCount);
    prefs.setInt("seconds", pausedSeconds);
    prefs.setInt("lights", lightsCount);
    prefs.setInt("lightson", lightsOnCount);
    prefs.setInt("links", linksCount);
    prefs.setInt("dummies", dummyCount);
    prefs.setBool("wrap", wrap);
    prefs.setString(
        "sources", jsonEncode(sourceCoordinates.toList(growable: false)));
  }

  void setMazeDimensions(double width, double height) {
    this.screenWidth = width;
    this.screenHeight = height;
    if (horizontalCellCount != null && horizontalCellCount > 0) {
      widgetSize = screenWidth / horizontalCellCount;
      add(MazeRestoredEvent());
    }
  }

  Future<void> getSavedMazeIfAny() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("maze")) {
      maze = List.from(jsonDecode(prefs.get("maze")))
          .map((e) => Cell.fromJson(e))
          .toList(growable: false);
      level = prefs.get("level");
      horizontalCellCount = prefs.get("width");
      verticalCellCount = maze.length ~/ horizontalCellCount;
      pausedSeconds = prefs.get("seconds");
      lightsCount = prefs.get("lights");
      lightsOnCount = prefs.get("lightson");
      linksCount = prefs.get("links");
      dummyCount = prefs.get("dummies");
      wrap = prefs.get("wrap");
      sourceCoordinates = Set.from(jsonDecode(prefs.get("sources")));
      if (screenWidth != null) {
        widgetSize = screenWidth / horizontalCellCount;
        add(MazeRestoredEvent());
      }
    }
    if (prefs.containsKey("maxLevel")) {
      maxLevel = prefs.get("maxLevel");
    }
  }

  Future<void> setMaxLevel(int newMaxLevel) async {
    if (maxLevel < newMaxLevel) {
      maxLevel = newMaxLevel;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt("maxLevel", maxLevel);
    }
  }
}
