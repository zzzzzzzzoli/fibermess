import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/pages/game_page/model/levels.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

import 'fibermess_number_picker.dart';

class NewGamePopupContentWidget extends StatelessWidget {
  const NewGamePopupContentWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameBloc, GameState>(
      condition: (prev, curr) {
        return curr is LevelSelectedState;
      },
      builder: (BuildContext context, GameState state) {
        Level level = (state as LevelSelectedState).selectedLevel;
        return Center(
          child: Container(
              constraints: BoxConstraints(minWidth: 200),
              decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(color: Color(0xff01ff00)),
                  borderRadius: BorderRadius.all(Radius.circular(3))),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NumberPicker(
                          initialValue:
                          BlocProvider.of<GameBloc>(context).maxLevel,
                          minValue: 1,
                          maxValue: BlocProvider.of<GameBloc>(context).maxLevel,
                          onChanged: (selectedLevel) =>
                              BlocProvider.of<GameBloc>(context)
                                  .add(SelectLevelEvent(selectedLevel))),
                    ),
                    Text('${FlutterI18n.translate(context, "text.width")}: ${level.width}',
                        style: TextStyle(
                            fontFamily: 'Audiowide',
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                    Text('${FlutterI18n.translate(context, "text.sources")}: ${level.sources}',
                        style: TextStyle(
                            fontFamily: 'Audiowide',
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                    Text('${FlutterI18n.translate(context, "text.links")}: ${level.links}',
                        style: TextStyle(
                            fontFamily: 'Audiowide',
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                    Text('${FlutterI18n.translate(context, "text.dummies")}: ${level.dummies}',
                        style: TextStyle(
                            fontFamily: 'Audiowide',
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                    Text('${FlutterI18n.translate(context, "text.wrap")}: ${level.wrap
                        ? FlutterI18n.translate(context, "text.enabled") :
                    FlutterI18n.translate(context, "text.disabled")}',
                        style: TextStyle(
                            fontFamily: 'Audiowide',
                            color: Colors.white,
                            decoration: TextDecoration.none,
                            fontSize: 20)),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                      child: FibermessButton(
                        text: FlutterI18n.translate(context, "button.label.play"),
                        onPressed: () {
                          BlocProvider.of<GameBloc>(context)
                              .add(NewMazeEvent(state.level));
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/game', ModalRoute.withName('/'));
                        },
                      ),
                    )
                  ],
                ),
              )),
        );
      },
    );
  }
}