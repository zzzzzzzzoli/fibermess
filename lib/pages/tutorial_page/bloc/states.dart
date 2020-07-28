import 'package:fibermess/pages/game_page/model/cell.dart';

class TutorialState {
  final String text;
  final Set<int> sourceCoordinates;
  final int horizontalCellCount;
  final int lightsCount;
  final bool wrap;
  final TutorialState nextState;
  final String buttonText;
  List<Cell> maze;
  int lightsOnCount;

  get isComplete => lightsCount == lightsOnCount;

  TutorialState(
      this.text,
      this.maze,
      this.horizontalCellCount,
      this.sourceCoordinates,
      this.lightsCount,
      this.wrap,
      this.nextState,
      this.buttonText,
      {this.lightsOnCount});

  factory TutorialState.fromState(TutorialState state) {
    return new TutorialState(
        state.text,
        state.maze,
        state.horizontalCellCount,
        state.sourceCoordinates,
        state.lightsCount,
        state.wrap,
        state.nextState,
        state.buttonText,
        lightsOnCount: state.lightsOnCount);
  }
}

class FirstPageTutorialState extends TutorialState {
  FirstPageTutorialState()
      : super(
            "text.tutorial.1",
            List.of([
              Cell(type: CellType.source, connections: {
                Side.left
              }, originalColor: {
                CellColor.green
              }, sourceSideColors: {
                Side.up: {CellColor.green},
                Side.down: {CellColor.green},
                Side.left: {CellColor.green},
                Side.right: {CellColor.green}
              }),
              Cell(type: CellType.end, originalColor: {
                CellColor.green
              }, color: {}, connections: {
                Side.left
              }, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, bridgeConnections: {})
            ], growable: false),
            2,
            {0},
            1,
            false,
            SecondPageTutorialState(),
            'button.label.next');
}

class SecondPageTutorialState extends TutorialState {
  SecondPageTutorialState()
      : super(
            "text.tutorial.2",
            List.of([
              Cell(type: CellType.source, connections: {
                Side.up
              }, originalColor: {
                CellColor.red
              }, sourceSideColors: {
                Side.up: {CellColor.red},
                Side.down: {CellColor.red},
                Side.left: {CellColor.red},
                Side.right: {CellColor.red}
              }),
              Cell(type: CellType.through, color: {}, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, connections: {
                Side.left,
                Side.right,
                Side.down
              }, bridgeConnections: {}),
              Cell(type: CellType.end, originalColor: {
                CellColor.red,
                CellColor.green,
                CellColor.blue
              }, color: {}, connections: {
                Side.left
              }, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, bridgeConnections: {}),
              Cell(type: CellType.source, connections: {
                Side.up
              }, originalColor: {
                CellColor.blue
              }, sourceSideColors: {
                Side.up: {CellColor.blue},
                Side.down: {CellColor.blue},
                Side.left: {CellColor.blue},
                Side.right: {CellColor.blue}
              }),
              Cell(type: CellType.through, color: {}, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, connections: {
                Side.left,
                Side.right,
                Side.up
              }, bridgeConnections: {}),
              Cell(type: CellType.source, connections: {
                Side.right
              }, originalColor: {
                CellColor.green
              }, sourceSideColors: {
                Side.up: {CellColor.green},
                Side.down: {CellColor.green},
                Side.left: {CellColor.green},
                Side.right: {CellColor.green}
              }),
            ], growable: false),
            3,
            {0, 3, 5},
            1,
            false,
            ThirdPageTutorialState(),
            'button.label.next');
}

class ThirdPageTutorialState extends TutorialState {
  ThirdPageTutorialState()
      : super("text.tutorial.3",
            List.of([
              Cell(type: CellType.source, connections: {
                Side.up
              }, originalColor: {
                CellColor.red
              }, sourceSideColors: {
                Side.up: {CellColor.red},
                Side.down: {CellColor.red},
                Side.left: {CellColor.red},
                Side.right: {CellColor.red}
              }),
              Cell(type: CellType.through, color: {}, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, connections: {
                Side.left,
                Side.down
              }, bridgeConnections: {
                Side.up,
                Side.right
              }),
              Cell(type: CellType.end, originalColor: {
                CellColor.red
              }, color: {}, connections: {
                Side.down
              }, sourceSideColors: {
                Side.up: {},
                Side.down: {},
                Side.left: {},
                Side.right: {}
              }, bridgeColor: {}, bridgeConnections: {}),
            ], growable: false),
            3,
            {0},
            1,
            true,
            FinishedTutorialState(),
            'button.label.finish');
}

class FinishedTutorialState extends TutorialState {

  FinishedTutorialState() : super('', [], 0, {}, 0, false, null, '');

}
