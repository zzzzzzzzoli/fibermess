import 'package:fibermess/pages/tutorial_page/bloc/states.dart';

abstract class TutorialEvent {}

class TutorialTurnCellEvent extends TutorialEvent {
  final int cellIndex;

  TutorialTurnCellEvent(this.cellIndex);
}

class TutorialNextPageEvent extends TutorialEvent {
  final TutorialState state;

  TutorialNextPageEvent(this.state);
}