import 'package:fibermess/pages/game_page/game_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


void main() => runApp(Fibermess());

class Fibermess extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fibermess',
      home: SafeArea(child: GamePage()),
    );
  }
}

