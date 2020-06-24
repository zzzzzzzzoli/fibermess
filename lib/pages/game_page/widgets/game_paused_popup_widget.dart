import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class GamePausedPopupWidget extends StatelessWidget {
  const GamePausedPopupWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Color(0xff01ff00)),
            borderRadius: BorderRadius.all(Radius.circular(3))),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    FlutterI18n.translate(context, "text.paused"),
                    style: TextStyle(
                        fontSize: 36,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    FlutterI18n.plural(context, "text.level.count", BlocProvider.of<GameBloc>(context).level),
                    style: TextStyle(
                        fontSize: 24,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${FlutterI18n.translate(context, "text.width")}: ${BlocProvider.of<GameBloc>(context).horizontalCellCount}',
                    style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${FlutterI18n.translate(context, "text.sources")}: ${BlocProvider.of<GameBloc>(context).lightsCount}',
                    style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${FlutterI18n.translate(context, "text.links")}: ${BlocProvider.of<GameBloc>(context).linksCount}',
                    style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    '${FlutterI18n.translate(context, "text.dummies")}: ${BlocProvider.of<GameBloc>(context).dummyCount}',
                    style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(
                    BlocProvider.of<GameBloc>(context).wrap
                        ? '${FlutterI18n.translate(context, "text.wrap")} ${FlutterI18n.translate(context, "text.enabled")}'
                        : '${FlutterI18n.translate(context, "text.wrap")} ${FlutterI18n.translate(context, "text.disabled")}',
                    style: TextStyle(
                        fontSize: 20,
                        decoration: TextDecoration.none,
                        fontFamily: 'AudioWide',
                        color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                FibermessButton(
                    text: FlutterI18n.translate(context, "button.label.shuffle"),
                    onPressed: () => BlocProvider.of<GameBloc>(context)
                        .add(ShuffleMazeEvent())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}