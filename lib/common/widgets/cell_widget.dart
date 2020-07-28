import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/cell.dart';
import 'package:fibermess/pages/tutorial_page/bloc/bloc.dart';
import 'package:fibermess/pages/tutorial_page/bloc/states.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CellWidget extends StatelessWidget {

  final double size;
  final int cellIndex;
  final bool isTutorial;

  const CellWidget({Key key, @required this.size, @required this.cellIndex, this.isTutorial = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isTutorial) {
      return buildTutorialCellWidget();
    } else {
      return buildGameCellWidget();
    }
  }

  BlocBuilder<TutorialBloc, TutorialState> buildTutorialCellWidget() {
    return BlocBuilder<TutorialBloc, TutorialState>(
      builder: (BuildContext context, TutorialState state) {
        return buildWidget(state.maze[cellIndex]);
      },
    );
  }

  BlocBuilder<GameBloc, GameState> buildGameCellWidget() {
    return BlocBuilder<GameBloc, GameState>(
      condition: (GameState oldState, GameState newState) {
        if (newState is CellsNeedRepaintingState) return newState.indices.contains(cellIndex);

        if (newState is GamePausedState || newState is GameResumedState || newState is GameWonState) {
          return false;
        }
        Cell oldCell, newCell;
        if (newState is LoadedState) newCell = newState.maze[cellIndex];
        if (oldState is LoadedState) oldCell = oldState.maze[cellIndex];
        if (oldState is CellsNeedRepaintingState) oldCell = oldState.maze[cellIndex];
        if (newState is GameWonState) newCell = newState.maze[cellIndex];
        if (oldState is GameWonState) oldCell = oldState.maze[cellIndex];
        return oldCell != newCell && newCell != null;
      },
      builder: (_, gameState) {
        Cell cell;
        if (gameState is LoadedState) cell = gameState.maze[cellIndex];
        if (gameState is GameWonState) cell = gameState.maze[cellIndex];
        if (gameState is CellsNeedRepaintingState) cell = gameState.maze[cellIndex];
        if (gameState is GamePausedState) cell = gameState.maze[cellIndex];
        if (gameState is GameResumedState) cell = gameState.maze[cellIndex];
        if (cell != null) return buildWidget(cell);
        else return buildErrorCell();
      },
    );
  }
  
  Widget buildWidget(Cell cell) {
    if (cell.type == CellType.source) {
      return CustomPaint(
        painter: SourcePainter(cell: cell),
        size: Size(size, size),
      );
    } else if (cell.type == CellType.end) {
      return CustomPaint(
        painter: EndPainter(cell.color, cell.originalColor, cell.connections.first, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if (cell.bridgeConnections.isEmpty) { // cell.type == CellType.through
      if (cell.connections.length == 2) {
        if (cell.connections.containsAll({Side.up, Side.down})) {
          return CustomPaint(
            painter: StraightPainter(false, cell.color, cell.sourceSideColors),
            size: Size(size, size),
          );
        } else if (cell.connections.containsAll({Side.left, Side.right})) {
          return CustomPaint(
            painter: StraightPainter(true, cell.color, cell.sourceSideColors),
            size: Size(size, size),
          );
        } else {
          return CustomPaint(
            painter: CurvePainter(cell.connections, cell.color, cell.sourceSideColors),
            size: Size(size, size),
          );
        }
      } else if (cell.connections.length == 3) {
        Set<Side> s = Side.values.toSet();
        Side flatSide = s.difference(cell.connections).first;
        return CustomPaint(
          painter: TriPainter(cell.color, flatSide, cell.sourceSideColors),
          size: Size(size, size),
        );
      } else {
        return CustomPaint(
          painter: HubPainter(cell.color, cell.sourceSideColors),
          size: Size(size, size),
        );
      }
    } else if (cell.connections.containsAll({Side.up, Side.down})
        && cell.bridgeConnections.containsAll({Side.left, Side.right})) {
      return CustomPaint(
        painter: CrossedPainter(cell.bridgeColor, cell.color, false, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.left, Side.right})
        && cell.bridgeConnections.containsAll({Side.up, Side.down})) {
      return CustomPaint(
        painter: CrossedPainter(cell.color, cell.bridgeColor, true, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.down, Side.left})
        && cell.bridgeConnections.containsAll({Side.up, Side.right})) {
      return CustomPaint(
        painter: XCrossedPainter(cell.color, cell.bridgeColor, false, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.up, Side.right})
        && cell.bridgeConnections.containsAll({Side.down, Side.left})){
      return CustomPaint(
        painter: XCrossedPainter(cell.bridgeColor, cell.color, false, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if ((cell.connections.containsAll({Side.up, Side.left})
        && cell.bridgeConnections.containsAll({Side.down, Side.right}))) {
      return CustomPaint(
        painter: XCrossedPainter(cell.color, cell.bridgeColor, true, cell.sourceSideColors),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.down, Side.right})
        && cell.bridgeConnections.containsAll({Side.up, Side.left})) {
      return CustomPaint(
        painter: XCrossedPainter(cell.bridgeColor, cell.color, true, cell.sourceSideColors),
        size: Size(size, size),
      );
    }
    return buildErrorCell();
  }

  Container buildErrorCell() => Container(color: Colors.red, width: size, height: size,);
  
}

abstract class FiberPainter extends CustomPainter {
  Map<Side, Set<CellColor>> sideColorMap;

  FiberPainter(this.sideColorMap);

  void deb(Canvas canvas, Size size, Map<Side, Set<CellColor>> sideColors) {
    return;
    var paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.grey;

    var paint2 = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.black;

    canvas.drawCircle(Offset(size.width / 2 - size.width / 10, size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(Offset(size.width / 2 - size.width / 10, size.width / 10),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width / 2, size.width / 10), size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 2, size.width / 10), size.width / 30 + 1, paint);
    canvas.drawCircle(Offset(size.width / 2 + size.width / 10, size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(Offset(size.width / 2 + size.width / 10, size.width / 10),
        size.width / 30 + 1, paint);

    canvas.drawCircle(
        Offset(size.width / 2 - size.width / 10, size.height - size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 2 - size.width / 10, size.height - size.width / 10),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width / 2, size.height - size.width / 10), size.width / 30,
        paint2);
    canvas.drawCircle(Offset(size.width / 2, size.height - size.width / 10),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width / 2 + size.width / 10, size.height - size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 2 + size.width / 10, size.height - size.width / 10),
        size.width / 30 + 1, paint);

    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2 - size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2 - size.width / 10),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2), size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2), size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2 + size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width / 10, size.height / 2 + size.width / 10),
        size.width / 30 + 1, paint);

    canvas.drawCircle(
        Offset(size.width - size.width / 10, size.height / 2 - size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width - size.width / 10, size.height / 2 - size.width / 10),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width - size.width / 10, size.height / 2), size.width / 30,
        paint2);
    canvas.drawCircle(Offset(size.width - size.width / 10, size.height / 2),
        size.width / 30 + 1, paint);
    canvas.drawCircle(
        Offset(size.width - size.width / 10, size.height / 2 + size.width / 10),
        size.width / 30, paint2);
    canvas.drawCircle(
        Offset(size.width - size.width / 10, size.height / 2 + size.width / 10),
        size.width / 30 + 1, paint);

    if (sideColors[Side.up].contains(CellColor.red)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.red.color;
      canvas.drawCircle(
          Offset(size.width / 2 - size.width / 10, size.width / 10),
          size.width / 30, paint);
    }
    if (sideColors[Side.up].contains(CellColor.green)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.green.color;
      canvas.drawCircle(
          Offset(size.width / 2, size.width / 10), size.width / 30, paint);
    }
    if (sideColors[Side.up].contains(CellColor.blue)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.blue.color;
      canvas.drawCircle(
          Offset(size.width / 2 + size.width / 10, size.width / 10),
          size.width / 30, paint);
    }

    if (sideColors[Side.down].contains(CellColor.red)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.red.color;
      canvas.drawCircle(Offset(
          size.width / 2 - size.width / 10, size.height - size.width / 10),
          size.width / 30, paint);
    }
    if (sideColors[Side.down].contains(CellColor.green)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.green.color;
      canvas.drawCircle(Offset(size.width / 2, size.height - size.width / 10),
          size.width / 30, paint);
    }
    if (sideColors[Side.down].contains(CellColor.blue)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.blue.color;
      canvas.drawCircle(Offset(
          size.width / 2 + size.width / 10, size.height - size.width / 10),
          size.width / 30, paint);
    }

    if (sideColors[Side.right].contains(CellColor.red)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.red.color;
      canvas.drawCircle(Offset(
          size.width - size.width / 10, size.height / 2 - size.width / 10),
          size.width / 30, paint);
    }
    if (sideColors[Side.right].contains(CellColor.green)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.green.color;
      canvas.drawCircle(Offset(size.width - size.width / 10, size.height / 2),
          size.width / 30, paint);
    }
    if (sideColors[Side.right].contains(CellColor.blue)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.blue.color;
      canvas.drawCircle(Offset(
          size.width - size.width / 10, size.height / 2 + size.width / 10),
          size.width / 30, paint);
    }

    if (sideColors[Side.left].contains(CellColor.red)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.red.color;
      canvas.drawCircle(
          Offset(size.width / 10, size.height / 2 - size.width / 10),
          size.width / 30, paint);
    }
    if (sideColors[Side.left].contains(CellColor.green)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.green.color;
      canvas.drawCircle(
          Offset(size.width / 10, size.height / 2), size.width / 30, paint);
    }
    if (sideColors[Side.left].contains(CellColor.blue)) {
      paint.style = PaintingStyle.fill;
      paint.color = CellColor.blue.color;
      canvas.drawCircle(
          Offset(size.width / 10, size.height / 2 + size.width / 10),
          size.width / 30, paint);
    }
  }
}

class EndPainter extends FiberPainter {

  Set<CellColor> colorIn;
  Set<CellColor> bulbColor;
  Side side;

  EndPainter(this.colorIn, this.bulbColor, this.side, sideColors) : super(sideColors);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8 / 65 * size.width;
    final myPaint0 = Paint()
      ..color = mixColors(colorIn).color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    switch (side) {
      case Side.left:
        canvas.drawLine(
            Offset(0, size.height / 2),
            Offset(size.width / 2 - strokeWidth, size.height / 2),
            myPaint0);
        break;
      case Side.up:
        canvas.drawLine(
            Offset(size.width / 2, 0),
            Offset(size.width / 2, size.height / 2 - strokeWidth),
            myPaint0);
        break;
      case Side.right:
        canvas.drawLine(
            Offset(size.width / 2 + strokeWidth, size.height / 2),
            Offset(size.width, size.height / 2),
            myPaint0);
        break;
      case Side.down:
        canvas.drawLine(
            Offset(size.width / 2, size.height / 2 + strokeWidth),
            Offset(size.width / 2, size.height),
            myPaint0);
        break;
    }

    if (mixColors(colorIn) == mixColors(bulbColor)) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          strokeWidth * 1.5,
          Paint()
            ..style = PaintingStyle.fill
            ..color = mixColors(colorIn).color
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2));

    } else {
      canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          strokeWidth,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.grey[800]
      );
    }
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        strokeWidth,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth / 2
          ..color = mixColors(bulbColor).color
    );

    deb(canvas, size, sideColorMap);

  }


  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is EndPainter) || (
        oldDelegate is EndPainter && (
            !SetEquality().equals(oldDelegate.colorIn, this.colorIn) ||
                !SetEquality().equals(oldDelegate.bulbColor, this.bulbColor) ||
                oldDelegate.side != this.side
        ));
  }
}

class SourcePainter extends FiberPainter {

  Set<CellColor> originalColor;
  Set<Side> sides;
  Map<Side, Set<CellColor>> sideColors;

  SourcePainter({Cell cell}) :
        originalColor = cell.originalColor,
        sides = cell.connections,
        sideColors = cell.sourceSideColors, super(cell.sourceSideColors);

  @override
  void paint(Canvas canvas, Size size) {
    double sourceWidth = 8 / 65 * size.width;
    final myPaint0 = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = sourceWidth
      ..color = mixColors(originalColor).color;
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width/2, size.height/2),
            width: sourceWidth * 2,
            height: sourceWidth * 2),
        myPaint0);

    for (Side side in sides) {
      final myPaint1 = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = sourceWidth
        ..color = mixColors(sideColors[side]).color;
      switch (side) {
        case Side.left:
          canvas.drawLine(
              Offset(0, size.height / 2),
              Offset(size.width / 2 - sourceWidth * 1.25, size.height / 2),
              myPaint1);
          break;
        case Side.up:
          canvas.drawLine(
              Offset(size.width / 2, 0),
              Offset(size.width / 2, size.height / 2 - sourceWidth * 1.25),
              myPaint1);
          break;
        case Side.right:
          canvas.drawLine(
              Offset(size.width / 2 + sourceWidth * 1.25, size.height / 2),
              Offset(size.width, size.height / 2),
              myPaint1);
          break;
        case Side.down:
          canvas.drawLine(
              Offset(size.width / 2, size.height / 2 + sourceWidth * 1.25),
              Offset(size.width / 2, size.height),
              myPaint1);
          break;
      }
    }

    deb(canvas, size, sideColors);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is SourcePainter) || (
        oldDelegate is SourcePainter && (
            !MapEquality().equals(oldDelegate.sideColors, this.sideColors) ||
                !SetEquality().equals(oldDelegate.originalColor, this.originalColor) ||
                !SetEquality().equals(oldDelegate.sides, this.sides)
        ));
  }
}


class TriPainter extends FiberPainter {

  Set<CellColor> color;
  Side flatSide;

  TriPainter(this.color, this.flatSide, sideColors) : super(sideColors);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 / 65 * size.width
      ..color = mixColors(color).color;
    if (flatSide == Side.left || flatSide == Side.right) {
      canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          myPaint);
      if (flatSide == Side.left) {
        canvas.drawLine(
            Offset(size.width / 2, size.height / 2),
            Offset(size.width, size.height / 2),
            myPaint);
      } else {
        canvas.drawLine(
            Offset(0, size.height / 2),
            Offset(size.width / 2, size.height / 2),
            myPaint);
      }
    } else {
      canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          myPaint);
      if (flatSide == Side.up) {
        canvas.drawLine(
            Offset(size.width / 2, size.height / 2),
            Offset(size.width / 2, size.height),
            myPaint);
      } else {
        canvas.drawLine(
            Offset(size.width / 2, 0),
            Offset(size.width / 2, size.height / 2),
            myPaint);
      }
    }
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is TriPainter) || (
        oldDelegate is TriPainter && (
            !SetEquality().equals(oldDelegate.color, this.color) ||
                oldDelegate.flatSide != this.flatSide
        ));
  }
}

class CurvePainter extends FiberPainter {

  Set<CellColor> color;
  Set<Side> connections;

  CurvePainter(this.connections, this.color, sc) : super(sc);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 / 65 * size.width
      ..color = mixColors(color).color;
    if (connections.contains(Side.left)) {
      if (connections.contains(Side.down)) {
        canvas.drawArc(Rect.fromLTWH(-size.width/2, size.height/2, size.width, size.height),
            1.5 * pi, pi/2, false, myPaint);
      } else {
        canvas.drawArc(Rect.fromLTWH(-size.width/2, -size.height/2, size.width, size.height),
            2 * pi, pi/2, false, myPaint);
      }
    } else if (connections.contains(Side.up)) {
      canvas.drawArc(Rect.fromLTWH(size.width/2, -size.height/2, size.width, size.height),
          0.5 * pi, pi/2, false, myPaint);
    } else {
      canvas.drawArc(Rect.fromLTWH(size.width/2, size.height/2, size.width, size.height),
          pi, pi/2, false, myPaint);
    }
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CurvePainter) || (
        oldDelegate is CurvePainter && (
            !SetEquality().equals(oldDelegate.color, this.color) ||
                oldDelegate.connections != this.connections
        ));
  }


}

class XCrossedPainter extends FiberPainter {

  Set<CellColor> color0;
  Set<CellColor> color1;
  bool variant;

  XCrossedPainter(this.color0, this.color1, this.variant, sc) : super(sc);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint0 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 / 65 * size.width
      ..color = mixColors(color0).color;
    final myPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 / 65 * size.width
      ..color = mixColors(color1).color;

    if (variant) {
      canvas.drawArc(Rect.fromLTWH(-size.width/2, -size.height/2, size.width, size.height),
          0, pi/2, false, myPaint0);
      canvas.drawArc(Rect.fromLTWH(size.width/2, size.height/2, size.width, size.height),
          pi, pi/2, false, myPaint1);
    } else {
      canvas.drawArc(Rect.fromLTWH(
          -size.width / 2, size.height / 2, size.width, size.height),
          pi * 1.5, pi / 2, false, myPaint0);
      canvas.drawArc(Rect.fromLTWH(
          size.width / 2, -size.height / 2, size.width, size.height),
          pi * 0.5, pi / 2, false, myPaint1);
    }
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CrossedPainter)
        || (oldDelegate is CrossedPainter && (
            !SetEquality().equals(oldDelegate.color0, this.color0) ||
                !SetEquality().equals(oldDelegate.color1, this.color1) ||
                oldDelegate.variant != this.variant));
  }
}

class CrossedPainter extends FiberPainter {

  Set<CellColor> color0;
  Set<CellColor> color1;
  bool variant;

  CrossedPainter(this.color0, this.color1, this.variant, sc) : super(sc);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8 / 65 * size.width;
    final myPaint0 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = mixColors(color0).color;
    final myPaint1 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = mixColors(color1).color;
    if (!variant) {
      canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          myPaint0);
      canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height / 2 - strokeWidth),
          myPaint1);
      canvas.drawLine(
          Offset(size.width / 2, size.height / 2 + strokeWidth),
          Offset(size.width / 2, size.height),
          myPaint1);
    } else {
      canvas.drawLine(
          Offset(0, size.height / 2),
          Offset((size.width / 2) - strokeWidth, size.height / 2),
          myPaint0);
      canvas.drawLine(
          Offset((size.width / 2) + strokeWidth, size.height / 2),
          Offset(size.width, size.height / 2),
          myPaint0);
      canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          myPaint1);
    }
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CrossedPainter)
        || (oldDelegate is CrossedPainter && (
            !SetEquality().equals(oldDelegate.color0, this.color0) ||
                !SetEquality().equals(oldDelegate.color1, this.color1) ||
                oldDelegate.variant != this.variant));
  }
}

class HubPainter extends FiberPainter {

  Set<CellColor> cellColor;

  HubPainter(this.cellColor, sc) : super(sc);

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 8 / 65 * size.width;
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = mixColors(cellColor).color;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        strokeWidth, myPaint);
    canvas.drawLine(
        Offset(0, size.height / 2),
        Offset((size.width / 2) - strokeWidth / 2, size.height / 2),
        myPaint);
    canvas.drawLine(
        Offset((size.width / 2) + strokeWidth / 2, size.height / 2),
        Offset(size.width, size.height / 2),
        myPaint);
    canvas.drawLine(
        Offset(size.width / 2, 0),
        Offset(size.width / 2, (size.height / 2) - strokeWidth / 2),
        myPaint);
    canvas.drawLine(
        Offset(size.width / 2, (size.height / 2) + strokeWidth / 2),
        Offset(size.width / 2, size.height),
        myPaint);
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is HubPainter) ||
        (oldDelegate is HubPainter &&
            !SetEquality().equals(oldDelegate.cellColor, this.cellColor));
  }
}

class StraightPainter extends FiberPainter {

  bool isHorizontal;
  Set<CellColor> cellColor;

  StraightPainter(this.isHorizontal, this.cellColor, sc) : super(sc);

  @override
  void paint(Canvas canvas, Size size) {
    final myPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8 / 65 * size.width
      ..color = mixColors(cellColor).color;
    if (isHorizontal) {
      canvas.drawLine(
          Offset(0, size.height / 2),
          Offset(size.width, size.height / 2),
          myPaint);
    } else {
      canvas.drawLine(
          Offset(size.width / 2, 0),
          Offset(size.width / 2, size.height),
          myPaint);
    }
    deb(canvas, size, sideColorMap);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is StraightPainter)
        || (oldDelegate is StraightPainter && (
            oldDelegate.isHorizontal != this.isHorizontal ||
                !SetEquality().equals(oldDelegate.cellColor, this.cellColor)
        ));
  }

}


extension on CellColor {
  Color get color {
    switch (this) {
      case CellColor.blue:
        return Color(0xff1700ff);
      case CellColor.green:
        return Color(0xff01ff00);
      case CellColor.red:
        return Color(0xffff0100);
      case CellColor.cyan:
        return Color(0xff02ffff);
      case CellColor.yellow:
        return Color(0xfffeff00);
      case CellColor.magenta:
        return Color(0xffff00ff);
      case CellColor.white:
        return Color(0xffffffff);
      default:
        return Color(0xff606060);
    }
  }
}
