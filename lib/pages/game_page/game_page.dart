import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'widgets/game_widget.dart';

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return BlocProvider(
              create: (_) => GameBloc.init(constraints.maxWidth, constraints.maxHeight, 20),
              child: GameWidget(),
            );
          }),);
  }

}