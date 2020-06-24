import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'clock_widget.dart';

class StatusBarWidget extends StatelessWidget {
  final bool needClock;

  const StatusBarWidget({Key key, this.needClock}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          FibermessButton(
            text: FlutterI18n.translate(context, "button.label.menu"),
            onPressed: () => BlocProvider.of<GameBloc>(context).add(GameMenuPausedEvent()),
            fontSize: 15.0,
            padding: 0,
            maxHeight: 18,
          ),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: BlocBuilder<GameBloc, GameState>(
              builder: (_, gameState) {
                var level = BlocProvider.of<GameBloc>(context).level;
                return Text('${FlutterI18n.plural(context, "text.level.count", level)}',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontFamily: 'AudioWide'),
                );
              },
            ),
          ),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: BlocBuilder<GameBloc, GameState>(
              builder: (_, gameState) {
                var total = BlocProvider.of<GameBloc>(context).lightsCount;
                var on = BlocProvider.of<GameBloc>(context).lightsOnCount;
                return Text(
                  '$on/$total',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.none,
                      fontFamily: 'AudioWide'),
                );
              },
            ),
          ),
          Spacer(),
          FittedBox(
            fit: BoxFit.fitHeight,
            child: needClock
                ? ClockWidget()
                : Text('00:00', style: TextStyle(
                color: Colors.white,
                decoration: TextDecoration.none,
                fontFamily: 'AudioWide'),),
          )
        ],
      ),
    );
  }
}
