import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:fibermess/pages/game_page/bloc/states.dart';
import 'package:fibermess/common/widgets/fibermess_dialog_widget.dart';
import 'package:fibermess/pages/main_menu_page/widgets/fibermess_logo_widget.dart';
import 'package:fibermess/pages/main_menu_page/widgets/new_game_popup_content_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class MainMenuPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // setting screen size for bloc
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var padding = MediaQuery.of(context).padding;
    BlocProvider.of<GameBloc>(context)
        .setMazeDimensions(width, height - padding.top - padding.bottom);

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        FibermessLogoWidget(),
        SizedBox(
          width: 1,
          height: 1,
        ),
        BlocBuilder<GameBloc, GameState>(
          condition: (oldState, newState) => newState is MazeAvailableState,
          builder: (context, state) => buildButtonGroup(context),
        )
      ],
    );
  }

  Widget buildButtonGroup(BuildContext context) {
    List<Widget> columnChildren = [];
    if (BlocProvider.of<GameBloc>(context).maze != null) {
      columnChildren.addAll([
        FibermessButton(
          text: FlutterI18n.translate(context, "button.label.resumeGame"),
          onPressed: () {
            BlocProvider.of<GameBloc>(context).add(GameMenuResumedEvent());
            Navigator.pushNamed(context, '/game');
          },
        ),
        SizedBox(
          height: 20,
        ),
      ]);
    }
    columnChildren.add(FibermessButton(
        text: FlutterI18n.translate(context, "button.label.newGame"),
        onPressed: () {
          var maxLevel = BlocProvider.of<GameBloc>(context).maxLevel;
          BlocProvider.of<GameBloc>(context).add(SelectLevelEvent(maxLevel));
          Navigator.of(context)
              .push(FibermessDialog(child: NewGamePopupContentWidget()));
        }));

    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: columnChildren,
      ),
    );
  }
}

