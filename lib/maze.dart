import 'dart:math';
import 'cell.dart';

class MazeGenerator {

  final int width;
  final int height;
  final int sources;
  final bool wrap;
  final int links;

  int _availableCellCount;
  List<int> _edges;
  List<Cell> _maze;
  Set<int> _sourceCoordinates = {};
  int _remainingLinks;

  MazeGenerator({this.width, this.height, this.sources, this.links = 0, this.wrap = false});

  List<List<Cell>> getMaze() {

    _maze = List<Cell>(width * height);
    _edges = List();
    _availableCellCount = _maze.length;
    _remainingLinks = links;

    // picking colors for sources
    List<CellColor> sourceColors = List();
    sourceColors.add(CellColor.values[Random().nextInt(3)]);
    for (int i = 1; i < sources; i++) {
      int lastColorIndex = sourceColors[i-1].index;
      int newColorIndex = lastColorIndex > 1 ? 0 : lastColorIndex + 1;
      sourceColors.add(CellColor.values[newColorIndex]);
    }
    // add sources
    while (_sourceCoordinates.length < sources - links) {
      int source = Random().nextInt(width * height);
      _sourceCoordinates.add(source);
    }
    for (int source in _sourceCoordinates) {
      _maze[source] = Cell.source({sourceColors.last});
      sourceColors.removeLast();
      _edges.add(source);
      _availableCellCount--;
    }
    while (_availableCellCount > 0) {
      // picking a random edge
      int edge = _edges.elementAt(Random().nextInt(_edges.length));
      // picking a random direction
      List directions = availableSides(edge);
      if (directions.length < 1) {
        _edges.remove(edge);
      } else {
        var steps = directions.elementAt(Random().nextInt(directions.length));
        int nextCell = calcSteps(edge, steps);
        _maze[nextCell] = Cell.through();
        _availableCellCount--;
        connect(edge, steps);
        if (availableSides(nextCell).length > 0) {
          _edges.add(nextCell);
        } else {
          // if a segment should have multiple sources we add it here
          // else we close it with a light  
          if (_remainingLinks > 0) {
            _maze[nextCell]
                ..type = CellType.source
                ..originalColor = {sourceColors.last};
            sourceColors.removeLast();
            _remainingLinks--;
            _sourceCoordinates.add(nextCell);
          } else {
            closeOpenEdge(nextCell);
          }
        }
      }
    }
    closeAllOpenEdges();
    colorLights();
    shuffle();
    return MazeColorMixer(width, height, wrap).colorMaze(_maze);
  }

  void closeAllOpenEdges() {
    for (int i = 0; i < (width * height); i++) {
      closeOpenEdge(i);
    }
  }

  void shuffle() {
    for (Cell cell in _maze) {
      int turn = Random().nextInt(4);
      for (int i = 0; i < turn; i++) {
        cell.turn();
      }
    }
  }

  void colorLights() {
    for (int source in _sourceCoordinates) {
      for (Side s in _maze[source].connections) {
        addOriginalColorIfLight(calcStep(source, s), s.opposite(), _maze[source].originalColor.last);
      }
    }
  }

  void addOriginalColorIfLight(int cellCoordinate, Side from, CellColor color) {
    if (cellCoordinate >= 0) {
      Cell cell = _maze[cellCoordinate];
      if (cell.type != CellType.source) {
        if (cell.type == CellType.end) {
          cell.originalColor.add(color);
        }
        Set<Side> sidesToGo;
        if (cell.bridgeConnections != null
            && cell.bridgeConnections.contains(from)) {
          sidesToGo = cell.bridgeConnections.difference({from});
        } else {
          sidesToGo = cell.connections.difference({from});
        }
        for (Side s in sidesToGo) {
          addOriginalColorIfLight(calcStep(cellCoordinate, s), s.opposite(), color);
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
        if (from + width < _maze.length) {
          return from + width;
        } else if (wrap) {
          return from - (height - 1) * width;
        }
        break;
    }
    return -1; // invalid step
  }

  void connect(int edge, List<Side> sides) {
    _maze[edge].connections.add(sides.first);
    int nxt = calcStep(edge, sides.first);
    if (sides.length == 1) {
      _maze[nxt].connections.add(sides.first.opposite());
    } else {
      _maze[nxt].bridgeConnections = {sides.first.opposite(), sides[1]};
      _maze[nxt].bridgeColor = {CellColor.gray};
      int nxt2 = calcStep(nxt, sides[1]);
      _maze[nxt2].connections.add(sides[1].opposite());
      _maze[nxt2].color = {CellColor.gray};
    }
    _maze[nxt].color = {CellColor.gray};
    _maze[edge].color = {CellColor.gray};
  }


  void closeOpenEdge(int edge) {
    if (_maze[edge].connections.length == 1
          && _maze[edge].type != CellType.source) {
      _maze[edge]
        ..type = CellType.end
        ..originalColor = {CellColor.gray}
      ;
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
      int corner1 = calcStep(next, s.turn(-1));
      int corner2 = calcStep(next, s.turn(1));
      if (_maze[next] == null) {
        result.add([s]);
      } else if (_maze[next].type == CellType.through &&
          _maze[next].connections.length == 2) {
        if (twoOver > 0 && _maze[twoOver] == null &&
            _maze[next].connections.containsAll({s.turn(1), s.turn(-1)})) {
          result.add([s, s]);
        }
        if (corner1 > 0 && _maze[corner1] == null &&
            _maze[next].connections.containsAll({s, s.turn(1)})) {
          result.add([s, s.turn(-1)]);
        }
        if (corner2 > 0 && _maze[corner2] == null &&
            _maze[next].connections.containsAll({s, s.turn(-1)})) {
          result.add([s, s.turn(1)]);
        }
      }
    }
    return result;
  }

}

class MazeColorMixer {

  List<Cell> _maze;
  int _width; // TODO: make this final
  final int _height;
  final bool _wrap;
  bool complete = false;
  int _lights = 0;
  int _lightsOn = 0;


  MazeColorMixer(this._width, this._height, this._wrap);

  List<List<Cell>> colorMaze(List<Cell> cells) {
    _maze = cells;
    // color all cells gray
    for (Cell cell in _maze) {
      cell.color = {CellColor.gray};
      cell.bridgeColor = {CellColor.gray};
      if (cell.type == CellType.source) {
        cell.sourceSideColors = {
          Side.up: {CellColor.gray},
          Side.down: {CellColor.gray},
          Side.left: {CellColor.gray},
          Side.right: {CellColor.gray},
        };
      }
    }
    // identifying sources and lights
    List<int> sources = [];
    for (int i = 0; i < _maze.length; i++) {
      if (_maze[i].type == CellType.source) {
        sources.add(i);
      } else if (_maze[i].type == CellType.end) {
        _lights++;
      }
    }
    // propagating colors from the sources
    for (int source in sources) {
      for (Side s in _maze[source].connections) {
        if (_maze[source].sourceSideColors[s] == null) {
          _maze[source].sourceSideColors[s] = {CellColor.gray};
        }
        _maze[source].sourceSideColors[s].add(
            _maze[source].originalColor.last // sources have only base colors 
        );
        addColorToCell(calcStep(source, s), s.opposite(), _maze[source].originalColor.last);
      }
    }
    complete = _lights == _lightsOn;
    return getCellMatrix();
  }

  List<List<Cell>> getCellMatrix() {
    List<List<Cell>> newMatrix = [];
    for (int i = 0; i < _maze.length; i += _width) {
      newMatrix.add(List.from(_maze.sublist(i, i+_width)));
    }
    return newMatrix;
  }

  List<List<Cell>> recolorMaze(List<List<Cell>> matrix) { // TODO: eliminate parameter
    _width = matrix[0].length;
    _maze = [];
    for (List<Cell> row in matrix) {
      _maze.addAll(row);
    }
    return colorMaze(_maze);
  }


  void addColorToCell(int cellCoordinate, Side from, CellColor color) {
    if (0 <= cellCoordinate && cellCoordinate < _maze.length) {
      Cell cell = _maze[cellCoordinate];
      if (cell.connections.contains(from)) {
        if (cell.type == CellType.source) {
          cell.sourceSideColors[from].add(color);
        } else {
          cell.color.add(color);
          _lightsOn += cell.isOn ? 1 : 0;
          Set<Side> sidesToVisit = cell.connections.difference({from});
          for (Side s in sidesToVisit) {
            int nxt = calcStep(cellCoordinate, s);
            if (nxt < 0) { continue; } // invalid step
            if ((_maze[nxt].connections.contains(s.opposite()) &&
                !_maze[nxt].color.contains(color)) ||
                (_maze[nxt].bridgeConnections != null &&
                    _maze[nxt].bridgeConnections.contains(s.opposite()) &&
                    !_maze[nxt].bridgeColor.contains(color))
            ) {
              addColorToCell(nxt, s.opposite(), color);
            }
          }
        }
      } else if (cell.bridgeConnections != null && cell.bridgeConnections.contains(from)) {
        cell.bridgeColor ??= {};
        cell.bridgeColor.add(color);
        Set<Side> sidesToVisit = cell.bridgeConnections.difference({from});
        for (Side s in sidesToVisit) {
          addColorToCell(calcStep(cellCoordinate, s), s.opposite(), color);
        }
      }
    }
  }

  int calcStep(int from, Side step) {
    switch (step) {
      case Side.left:
        if (from % _width > 0) {
          return from - 1;
        } else if (_wrap && from % _width == 0) {
          return from + _width - 1;
        }
        break;
      case Side.up:
        if (from >= _width) {
          return from - _width;
        } else if (_wrap) {
          return from + (_height - 1) * _width;
        }
        break;
      case Side.right:
        if ((from + 1) % _width != 0) {
          return from + 1;
        } else if (_wrap) {
          return from + 1 - _width;
        }
        break;
      case Side.down:
        if (from + _width < _maze.length) {
          return from + _width;
        } else if (_wrap) {
          return from - (_height - 1) * _width;
        }
        break;
    }
    return -1;
  }


}

extension on Side {
  Side opposite() {
    int opp = index + 2;
    if (opp > 3) {
      opp -= 4;
    }
    return Side.values[opp];
  }
  Side turn(int direction) {
    if (direction >= 0) {
      if (this.index < 3) {
        return Side.values[index + 1];
      } else {
        return Side.left;
      }
    } else {
      if (this.index > 0) {
        return Side.values[index - 1];
      } else {
        return Side.down;
      }
    }
  }
}