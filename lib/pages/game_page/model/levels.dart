class Level {
  final int width;
  int height;
  final int sources;
  final int links;
  final bool wrap;

  Level(this.width, this.sources, this.links, this.wrap, {this.height});

}

final List<Level> levels = [
  Level(2, 1, 0, false),
  Level(2, 1, 0, false),
  Level(3, 1, 0, false),
  Level(4, 1, 0, false),
  Level(4, 2, 0, false),
  Level(4, 2, 0, false),
  Level(4, 2, 1, false),
  Level(5, 3, 1, false),
  Level(5, 3, 1, false),
  Level(5, 3, 1, false),
  Level(6, 4, 1, false),
  Level(6, 4, 2, false),
  Level(6, 4, 2, false),
  Level(7, 5, 2, false),
  Level(7, 5, 2, false),
  Level(7, 5, 2, false),
  Level(8, 6, 2, false),
  Level(8, 6, 2, false),
  Level(8, 6, 3, false),
  Level(8, 7, 3, false),
  Level(9, 7, 3, true),
  Level(9, 7, 3, true),
  Level(10, 8, 3, true),
  Level(10, 8, 3, true),
  Level(10, 8, 4, true),
  Level(11, 9, 4, true),
  Level(11, 9, 4, true),
  Level(11, 9, 4, true),
  Level(11, 10, 4, true),
  Level(11, 10, 4, true),
  Level(12, 10, 5, true),
  Level(12, 11, 5, true),
  Level(12, 11, 5, true),
  Level(12, 11, 5, true),
  Level(12, 12, 5, true),
  Level(13, 12, 5, true),
  Level(13, 12, 6, true),
  Level(13, 13, 6, true),
  Level(13, 13, 6, true),
  Level(13, 13, 6, true),
  Level(14, 14, 6, true),
  Level(14, 14, 6, true),
  Level(14, 14, 7, true),
  Level(14, 15, 7, true),
  Level(15, 15, 7, true),
  Level(15, 15, 7, true),
  Level(15, 16, 7, true),
  Level(15, 16, 7, true),
  Level(15, 16, 8, true),
  Level(15, 17, 8, true),
  Level(16, 17, 8, true),
  Level(16, 17, 8, true),
  Level(16, 18, 8, true),
  Level(16, 18, 8, true),
];