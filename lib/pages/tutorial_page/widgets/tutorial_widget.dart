import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/tutorial_page/bloc/bloc.dart';
import 'package:fibermess/pages/tutorial_page/bloc/events.dart';
import 'package:fibermess/pages/tutorial_page/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'tutorial_maze_widget.dart';

class TutorialWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TutorialBloc(),
      child: _TutorialWidget(),
    );
  }
}

class _TutorialWidget extends StatelessWidget {
  const _TutorialWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: BlocProvider.of<TutorialBloc>(context),
      builder: (BuildContext context, TutorialState state) {
        if (state is FinishedTutorialState) {
          WidgetsBinding.instance.addPostFrameCallback((_){
            Navigator.pop(context);
          });
          return Container();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(FlutterI18n.translate(context, state.text),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Audiowide',
                      fontSize: 30,
                      decoration: TextDecoration.none,
                      color: Colors.white70)),
            ),
            TutorialMazeWidget(state: state, cellSize: 100),
            FibermessButton(
              text: FlutterI18n.translate(context, state.buttonText),
              onPressed: state.isComplete
                  ? () => BlocProvider.of<TutorialBloc>(context)
                      .add(TutorialNextPageEvent(state.nextState))
                  : null,
            )
          ],
        );
      },
    );
  }
}
