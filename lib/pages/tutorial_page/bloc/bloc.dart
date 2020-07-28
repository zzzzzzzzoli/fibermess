import 'dart:collection';

import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fibermess/pages/tutorial_page/bloc/events.dart';
import 'package:fibermess/pages/tutorial_page/bloc/states.dart';

class TutorialBloc extends Bloc<TutorialEvent, TutorialState> {

  @override
  TutorialState get initialState => FirstPageTutorialState();

  @override
  Stream<TutorialState> mapEventToState(TutorialEvent event) async* {
    switch (event.runtimeType) {
      case TutorialTurnCellEvent:
        int index = (event as TutorialTurnCellEvent).cellIndex;
        state.maze[index].turn();
        colorMaze(state);
        yield TutorialState.fromState(state);
        break;
      case TutorialNextPageEvent:
        yield (event as TutorialNextPageEvent).state;
        break;
    }
  }

  void colorMaze(TutorialState state) {
    unColorMaze(state);
    // propagating colors from each source
    for (int source in state.sourceCoordinates) {
      for (Side s in state.maze[source].connections) {
        state.maze[source].sourceSideColors[s].addAll(state.maze[source].originalColor);
        addColorToCell(calcStep(source, s, state), oppositeSide(s),
            state.maze[source].originalColor.last, state);
      }
    }
  }

  void unColorMaze(TutorialState state) {
    for (int i=0; i<state.maze.length; i++) {
      state.maze[i].color = {};
      state.maze[i].bridgeColor = {};
      if (state.maze[i].type == CellType.source) {
        state.maze[i].sourceSideColors = {
          Side.up: {state.maze[i].originalColor.first},
          Side.down: {state.maze[i].originalColor.first},
          Side.left: {state.maze[i].originalColor.first},
          Side.right: {state.maze[i].originalColor.first},
        };
      } else {
        state.maze[i].sourceSideColors = {
          Side.up: {},
          Side.down: {},
          Side.left: {},
          Side.right: {},
        };
      }
    }
    state.lightsOnCount = 0;
  }

  void addColorToCell(int cellCoordinate, Side fromSide, CellColor color, TutorialState state) {
    if (0 <= cellCoordinate && cellCoordinate < state.maze.length) {
      Queue queue = new Queue();
      Map<int, Set<Side>> seen = HashMap(); // avoiding loops
      queue.add([cellCoordinate, fromSide]);
      while (queue.isNotEmpty) {
        var popped = queue.removeLast();
        int index = popped[0];
        if (index >= 0) {
          Cell cell = state.maze[index];
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
                  state.lightsOnCount--;
                }
                if (!wasOn && cell.isOn) {
                  state.lightsOnCount++;
                }
                sidesToVisit = cell.connections.difference({from});
              } else if (cell.bridgeConnections.contains(from)) {
                cell.bridgeColor.add(color);
                sidesToVisit = cell.bridgeConnections.difference({from});
              }
              for (Side s in sidesToVisit) {
                queue.add([calcStep(index, s, state), oppositeSide(s)]);
              }
            }
          }
        }
      }
    }
  }

  int calcSteps(int from, List<Side> steps, TutorialState state) {
    int result = from;
    for (Side s in steps) {
      result = calcStep(result, s, state);
    }
    return result;
  }

  int calcStep(int from, Side step, TutorialState state) {
    return staticCalcStep(
        from, step, state.horizontalCellCount,
        state.maze.length ~/ state.horizontalCellCount,
        state.maze.length, state.wrap);
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

}