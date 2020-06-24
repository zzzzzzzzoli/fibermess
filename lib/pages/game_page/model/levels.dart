class Level {
  final int width;
  final int sources;
  final int links;
  final bool wrap;
  final int dummies;

  Level(this.width, this.sources, this.links, this.wrap, this.dummies);

}

final List<Level> levels = [
  Level(2, 1, 0, false, 0),
  Level(2, 1, 0, false, 0),
  Level(3, 1, 0, false, 0),
  Level(4, 1, 0, false, 0),
  Level(4, 2, 0, false, 0),
  Level(4, 2, 0, false, 0),
  Level(4, 2, 1, false, 0),
  Level(5, 3, 1, false, 0),
  Level(5, 3, 1, false, 0),
  Level(5, 3, 1, false, 0),
  Level(6, 4, 1, false, 0),
  Level(6, 4, 2, false, 0),
  Level(6, 4, 2, false, 0),
  Level(7, 5, 2, false, 0),
  Level(7, 5, 2, false, 0),
  Level(7, 5, 2, false, 0),
  Level(8, 6, 2, false, 0),
  Level(8, 6, 2, false, 0),
  Level(8, 6, 3, false, 0),
  Level(8, 7, 3, false, 0),
  Level(9, 7, 3, true, 0),
  Level(9, 7, 3, true, 1),
  Level(10, 8, 3, true, 2),
  Level(10, 8, 3, true, 3),
  Level(10, 8, 4, true, 0),
  Level(11, 9, 4, true, 0),
  Level(11, 9, 4, true, 0),
  Level(11, 9, 4, true, 0),
  Level(11, 10, 4, true, 0),
  Level(11, 10, 4, true, 0),
  Level(12, 10, 5, true, 0),
  Level(12, 11, 5, true, 0),
  Level(12, 11, 5, true, 0),
  Level(12, 11, 5, true, 0),
  Level(12, 12, 5, true, 0),
  Level(13, 12, 5, true, 0),
  Level(13, 12, 6, true, 0),
  Level(13, 13, 6, true, 0),
  Level(13, 13, 6, true, 0),
  Level(13, 13, 6, true, 0),
  Level(14, 14, 6, true, 0),
  Level(14, 14, 6, true, 0),
  Level(14, 14, 7, true, 0),
  Level(14, 15, 7, true, 0),
  Level(15, 15, 7, true, 0),
  Level(15, 15, 7, true, 0),
  Level(15, 16, 7, true, 0),
  Level(15, 16, 7, true, 0),
  Level(15, 16, 8, true, 0),
  Level(15, 17, 8, true, 0),
  Level(16, 17, 8, true, 0),
  Level(16, 17, 8, true, 0),
  Level(16, 18, 8, true, 0),
  Level(16, 18, 8, true, 0),
];