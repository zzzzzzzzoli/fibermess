import 'package:fibermess/common/widgets/fibermess_button_widget.dart';
import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/bloc/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameWonPopupWidget extends StatelessWidget {

  final int nextLevel;

  const GameWonPopupWidget({
    Key key, @required this.nextLevel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
                border: Border.all(color: Color(0xff01ff00)),
                color: Color(0xff01ff00),
                borderRadius: BorderRadius.all(Radius.circular(3))),
            child: Text(
              'Completed',
              style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'AudioWide',
                  decoration: TextDecoration.none),
            ),
          ),
          SizedBox(height: 50),
          FibermessButton(
              text: 'Next level',
              onPressed: () {
                BlocProvider.of<GameBloc>(context).add(ShowInterstitialAdEvent());
//                BlocProvider.of<GameBloc>(context).add(NewMazeEvent(nextLevel));
                Navigator.popUntil(context, ModalRoute.withName('/game'));
              }
          )
        ],
      ),
    );
  }
}