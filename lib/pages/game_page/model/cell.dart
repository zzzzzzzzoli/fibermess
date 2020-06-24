import 'package:json_annotation/json_annotation.dart';

import 'package:flutter/foundation.dart';

part 'cell.g.dart';

@JsonSerializable(nullable: true)
class Cell {

  CellType type;

  Set<Side> connections = {};
  Set<Side> bridgeConnections = {};

  Set<CellColor> color = {};
  Set<CellColor> bridgeColor = {};

  Set<CellColor> originalColor;

  Map<Side, Set<CellColor>> sourceSideColors = {
    Side.up : {},
    Side.down : {},
    Side.left : {},
    Side.right : {},
  };

  Map<String, dynamic> toJson() => _$CellToJson(this);
  factory Cell.fromJson(Map<String, dynamic> json) => _$CellFromJson(json);

  Cell({this.type, this.connections, this.bridgeConnections, this.color,
    this.bridgeColor, this.originalColor, this.sourceSideColors});

  Cell.source(Set<CellColor> originalColor) {
    this.type = CellType.source;
    this.connections = {};
    this.sourceSideColors = {
      Side.up : Set.of(originalColor),
      Side.down : Set.of(originalColor),
      Side.left : Set.of(originalColor),
      Side.right : Set.of(originalColor)
    };
    this.originalColor = originalColor;
  }

  Cell.through() {
    this.type = CellType.through;
  }

  Cell.hub() {
    this.type = CellType.through;
    this.connections = {Side.left, Side.up, Side.right, Side.down};
  }

  bool get isOn {
    if (type == CellType.end &&
        mixColors(color) == mixColors(originalColor)) {
      return true;
    } else {
      return false;
    }
  }

  void turn() {
    var temp = <Side>{};
    for (Side s in connections) {
      temp.add(turnSide(s));
    }
    connections = temp;
    if (bridgeConnections != null) {
      temp = {};
      for (Side s in bridgeConnections) {
        temp.add(turnSide(s));
      }
      bridgeConnections = temp;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Cell &&
              runtimeType == other.runtimeType &&
              type == other.type &&
              setEquals(connections, other.connections) &&
              setEquals(bridgeConnections, other.bridgeConnections) &&
              setEquals(color, other.color) &&
              setEquals(bridgeColor, other.bridgeColor) &&
              setEquals(originalColor, other.originalColor) &&
              mapEquals(sourceSideColors, other.sourceSideColors);

  @override
  int get hashCode =>
      type.hashCode ^
      connections.hashCode ^
      bridgeConnections.hashCode ^
      color.hashCode ^
      bridgeColor.hashCode ^
      originalColor.hashCode ^
      sourceSideColors.hashCode;

}


CellColor mixColors(Set<CellColor> baseColors) {
  switch (baseColors.length) {
    case 1:
      return baseColors.first;
    case 2:
      if (baseColors.contains(CellColor.blue)) {
        if (baseColors.contains(CellColor.red)) {
          return CellColor.magenta; // blue + red
        }
        return CellColor.cyan; // blue + green
      }
      return CellColor.yellow; // red + green
    case 3:
      return CellColor.white; // red + green + blue
    default:
      return null;
  }
}

enum Side {
  left,
  up,
  right,
  down
}

Side turnSide(Side side) {
  return turnSideInDirection(side, 0);
}


Side oppositeSide(Side side) {
  int opp = side.index + 2;
  if (opp > 3) {
    opp -= 4;
  }
  return Side.values[opp];
}

Side turnSideInDirection(Side side, int direction) {
  if (direction >= 0) {
    if (side.index < 3) {
      return Side.values[side.index + 1];
    } else {
      return Side.left;
    }
  } else {
    if (side.index > 0) {
      return Side.values[side.index - 1];
    } else {
      return Side.down;
    }
  }
}

enum CellColor {
  blue,
  green,
  red,
  cyan,
  yellow,
  magenta,
  white
}

enum CellType {
  source,
  through,
  end
}
