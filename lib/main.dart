import 'package:fibermess/maze.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cell.dart';
import 'widgets.dart';
import 'levels.dart';

void main() => runApp(Fibermess());

class Fibermess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibermess',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  double widgetSize;
  MazeWidget mazeWidget;
  _MyHomePageState();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: SafeArea(child: new LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return MazeWidget(constraints.maxWidth, constraints.maxHeight);
          }),),);
  }
}

class MazeWidget extends StatefulWidget {

  final double screenWidth;
  final double screenHeight;
  final int level;

  MazeWidget(this.screenWidth, this.screenHeight, {this.level = 0});

  @override
  State<StatefulWidget> createState() => _MazeState();

}

class _MazeState extends State<MazeWidget> {

  List<Cell> maze;
  MazeColorMixer colorMixer;
  int level;
  int width;
  int height;
  double widgetSize;

  void _nextMaze() {
    setState(() {
      level++;
      _getMaze();
    });
  }

  @override
  Widget build(BuildContext context) {
    var rowWidgets = <Widget>[];
    for (int i = 0; i < maze.length; i += width) {
      var cellWidgets = <Widget>[];
      for (Cell cell in maze.sublist(i, i + width)) {
        cellWidgets.add(GestureDetector(
          child: CellWidget(
              cell: cell,
              size: widgetSize),
          onTap: () => _turnCell(cell),
        ));
      }
      rowWidgets.add(Row(children: cellWidgets));
    }
    var mazeWidget = Container(
      child: Column(children: rowWidgets), color: Colors.black,);
    if (colorMixer.complete) {
      return Stack(
        alignment: AlignmentDirectional.center,
        children: <Widget>[
          mazeWidget,
          BlurWidget(),
          Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Congrats',
                    style: TextStyle(color: Colors.red, backgroundColor: Colors.lightGreenAccent, decoration: TextDecoration.none),
                  ),
                ),
                RaisedButton(
                  child: Text('Next level'),
                  onPressed: _nextMaze,
                )
              ],),
          )
        ],);
    }
    return mazeWidget;
  }

  @override
  void initState() {
    level = widget.level;
    _getMaze();
    super.initState();
  }

  Level _getLevelForScreen(int l) {
    if (widget.screenWidth <= widget.screenHeight) {
      widgetSize = widget.screenWidth / levels[l].width;
      width = levels[l].width;
      height = (width * widget.screenHeight / widget.screenWidth).floor();
      var lvl = Level(width, levels[l].sources, levels[l].links, levels[l].wrap, height: height);
      return lvl;
    } else {
      widgetSize = widget.screenHeight / levels[l].width;
      height = levels[l].width;
      width = (height * widget.screenWidth / widget.screenHeight).floor();
      var lvl = Level(width, levels[l].sources, levels[l].links, levels[l].wrap, height: height);
      return lvl;
    }
  }

  void _getMaze() {
    Level lvl = _getLevelForScreen(level);
    maze = MazeGenerator(lvl).getMaze();
    colorMixer = MazeColorMixer(lvl);
    maze = colorMixer.colorMaze(maze);
  }

  void _turnCell(Cell cell) {
    setState(() {
      cell.turn();
      maze = colorMixer.colorMaze(maze);
    });
  }
}
