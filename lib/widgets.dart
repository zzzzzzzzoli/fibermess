import 'dart:math';
import 'dart:ui';

import 'package:fibermess/cell.dart';
import 'package:flutter/material.dart';

class CellWidget extends StatelessWidget {

  final Cell cell;
  final double size;

  const CellWidget({Key key, this.cell, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cell.type == CellType.source) {
      return CustomPaint(
        painter: SourcePainter(cell: cell),
        size: Size(size, size),
      );
    } else if (cell.type == CellType.end) {
      return CustomPaint(
        painter: EndPainter(cell.color, cell.originalColor, cell.connections.first),
        size: Size(size, size),
      );
    } else if (cell.bridgeConnections == null || cell.bridgeConnections.isEmpty) {
      if (cell.connections.length == 2) {
        if (cell.connections.containsAll({Side.up, Side.down})) {
          return CustomPaint(
            painter: StraightPainter(false, cell.color),
            size: Size(size, size),
          );
        } else if (cell.connections.containsAll({Side.left, Side.right})) {
          return CustomPaint(
            painter: StraightPainter(true, cell.color),
            size: Size(size, size),
          );
        } else {
          return CustomPaint(
            painter: CurvePainter(cell.connections, cell.color),
            size: Size(size, size),
          );
        }
      } else if (cell.connections.length == 3) {
        Set<Side> s = Side.values.toSet();
        Side flatSide = s.difference(cell.connections).first;
        return CustomPaint(
          painter: TriPainter(cell.color, flatSide),
          size: Size(size, size),
        );
      } else {
        return CustomPaint(
          painter: HubPainter(cell.color),
          size: Size(size, size),
        );
      }
    } else if (cell.connections.containsAll({Side.up, Side.down})
        && cell.bridgeConnections.containsAll({Side.left, Side.right})) {
      return CustomPaint(
        painter: CrossedPainter(cell.bridgeColor, cell.color, false),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.left, Side.right})
        && cell.bridgeConnections.containsAll({Side.up, Side.down})) {
      return CustomPaint(
        painter: CrossedPainter(cell.color, cell.bridgeColor, true),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.down, Side.left})
        && cell.bridgeConnections.containsAll({Side.up, Side.right})) {
      return CustomPaint(
        painter: XCrossedPainter(cell.color, cell.bridgeColor, false),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.up, Side.right})
        && cell.bridgeConnections.containsAll({Side.down, Side.left})){
      return CustomPaint(
        painter: XCrossedPainter(cell.bridgeColor, cell.color, false),
        size: Size(size, size),
      );
    } else if ((cell.connections.containsAll({Side.up, Side.left})
        && cell.bridgeConnections.containsAll({Side.down, Side.right}))) {
      return CustomPaint(
        painter: XCrossedPainter(cell.color, cell.bridgeColor, true),
        size: Size(size, size),
      );
    } else if (cell.connections.containsAll({Side.down, Side.right})
        && cell.bridgeConnections.containsAll({Side.up, Side.left})) {
      return CustomPaint(
        painter: XCrossedPainter(cell.bridgeColor, cell.color, true),
        size: Size(size, size),
      );
    }
    return Container(color: Colors.red, width: 65, height: 65,); // error
  }
}

class EndPainter extends CustomPainter {

  Set<CellColor> colorIn;
  Set<CellColor> bulbColor;
  Side side;

  EndPainter(this.colorIn, this.bulbColor, this.side);

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

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is EndPainter) || (
        oldDelegate is EndPainter && (
            oldDelegate.colorIn != this.colorIn ||
                oldDelegate.bulbColor != this.bulbColor ||
                oldDelegate.side != this.side
        ));
  }
}

class SourcePainter extends CustomPainter {

  Set<CellColor> originalColor;
  Set<Side> sides;
  Map<Side, Set<CellColor>> sideColors;

  SourcePainter({Cell cell}) :
        originalColor = cell.originalColor,
        sides = cell.connections,
        sideColors = cell.sourceSideColors;

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
      if (sideColors[side] == null) {
        sideColors[side] = {CellColor.gray};
      }
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is SourcePainter) || (
        oldDelegate is SourcePainter && (
            oldDelegate.sideColors != this.sideColors || // TODO: test this
                oldDelegate.originalColor != this.originalColor ||
                oldDelegate.sides != this.sides
        ));
  }
}


class TriPainter extends CustomPainter {

  Set<CellColor> color;
  Side flatSide;

  TriPainter(this.color, this.flatSide);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is TriPainter) || (
        oldDelegate is TriPainter && (
            oldDelegate.color != this.color ||
                oldDelegate.flatSide != this.flatSide
        ));
  }
}

class CurvePainter extends CustomPainter {

  Set<CellColor> color;
  Set<Side> connections;

  CurvePainter(this.connections, this.color);

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

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CurvePainter) || (
        oldDelegate is CurvePainter && (
            oldDelegate.color != this.color ||
                oldDelegate.connections != this.connections
        ));
  }


}

class XCrossedPainter extends CustomPainter {

  Set<CellColor> color0;
  Set<CellColor> color1;
  bool variant;

  XCrossedPainter(this.color0, this.color1, this.variant);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CrossedPainter)
        || (oldDelegate is CrossedPainter &&
            (oldDelegate.color0 != this.color0
                || oldDelegate.color1 != this.color1 ||
                oldDelegate.variant != this.variant));
  }
}

class CrossedPainter extends CustomPainter {

  Set<CellColor> color0;
  Set<CellColor> color1;
  bool variant;

  CrossedPainter(this.color0, this.color1, this.variant);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is CrossedPainter)
        || (oldDelegate is CrossedPainter &&
            (oldDelegate.color0 != this.color0
                || oldDelegate.color1 != this.color1 ||
                oldDelegate.variant != this.variant));
  }
}

class HubPainter extends CustomPainter {

  Set<CellColor> cellColor;

  HubPainter(this.cellColor);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is HubPainter) ||
        (oldDelegate is HubPainter && oldDelegate.cellColor != this.cellColor);
  }
}

class StraightPainter extends CustomPainter {

  bool isHorizontal;
  Set<CellColor> cellColor;

  StraightPainter(this.isHorizontal, this.cellColor);

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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return !(oldDelegate is StraightPainter)
        || (oldDelegate is StraightPainter
            && (oldDelegate.isHorizontal != this.isHorizontal
                || oldDelegate.cellColor != this.cellColor
            ));
  }

}


class BlurWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.2),
        ),),
    );
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
      case CellColor.gray:
        return Color(0xff606060);
    }
    return Color(0xff800080);
  }
}
