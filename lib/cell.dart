class Cell {

  CellType type;

  Set<Side> connections;
  Set<Side> bridgeConnections;

  Set<CellColor> color;
  Set<CellColor> bridgeColor;

  Set<CellColor> originalColor;

  Map<Side, Set<CellColor>> sourceSideColors = {
    Side.up : {CellColor.gray},
    Side.down : {CellColor.gray},
    Side.left : {CellColor.gray},
    Side.right : {CellColor.gray},
  };

  Cell({this.type, this.connections, this.bridgeConnections, this.color,
    this.bridgeColor, this.originalColor, this.sourceSideColors});

  Cell.source(Set<CellColor> originalColor) {
    this.type = CellType.source;
    this.connections = {};
    this.sourceSideColors = {};
    this.originalColor = originalColor;
  }

  Cell.through() {
    this.type = CellType.through;
    this.connections = {};
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

}


// ignore: missing_return
CellColor mixColors(Set<CellColor> baseColors) {
  baseColors = baseColors.difference({CellColor.gray});
  switch (baseColors.length) {
    case 0:
      return CellColor.gray;
    case 1:
      return baseColors.first;
    case 2:
      if (baseColors.contains(CellColor.blue)) {
        if (baseColors.contains(CellColor.red)) {
          return CellColor.magenta; // blue + red
        } else {
          return CellColor.cyan; // blue + green
        }
      } else {
        return CellColor.yellow; // red + green
      }
      break;
    case 3:
      return CellColor.white; // red + green + blue
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
  white,
  gray
}

enum CellType {
  source,
  through,
  end
}
