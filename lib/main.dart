import 'package:fibermess/maze.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'cell.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibermess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(init_cells: generateMaze()),
    );
  }
}

List<List<Cell>> recolorMaze(List<List<Cell>> maze, bool wrap) {
  return MazeColorMixer(6, 8, true).recolorMaze(maze);
}

generateMaze() {
  return MazeGenerator(width: 6, height: 8, sources: 4, links: 2, wrap: true).getMaze();
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.init_cells}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final List<List<Cell>> init_cells;
  double widgetSize;

  @override
  _MyHomePageState createState() => _MyHomePageState(init_cells);
}

class _MyHomePageState extends State<MyHomePage> {
  List<List<Cell>> cells;
  double widgetSize;
  _MyHomePageState(this.cells);

  void _turnCell(Cell cell) {
    setState(() {
      cell.turn();
      cells = recolorMaze(cells, true);
    });
  }

  void _newMaze() {
    setState(() {
      cells = generateMaze();
    });
  }

  @override
  Widget build(BuildContext context) {
    double widgetSize = MediaQuery.of(context).size.width/6;
    return Container(
      color: Colors.black,
      child: SafeArea(child: Column(
        children: <Widget>[
          getMaze(cells, widgetSize),
          RaisedButton(
            child: Text('NEW MAZE'),
            onPressed: _newMaze,
          )
        ],
      )),
    );
  }

  Widget getMaze(List<List<Cell>> cells, double widgetSize) {
    var rowWidgets = <Widget>[];
    for (List<Cell> row in cells) {
      var cellWidgets = <Widget>[];
      for (Cell cell in row) {
        cellWidgets.add(GestureDetector(
          child: CellWidget(cell: cell, size: widgetSize),
          onTap: () => _turnCell(cell),
        ));
      }
      rowWidgets.add(Row(children: cellWidgets));
    }
    return Container(child: Column(children: rowWidgets), color: Colors.black,);
  }
}
