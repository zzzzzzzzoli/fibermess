import 'dart:ui';

import 'package:flutter/material.dart';

class FibermessDialog extends PopupRoute<Null> {

  final Widget child;
  Function onDismissed;

  FibermessDialog({@required this.child, this.onDismissed});

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => "Close";

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      new FrostTransition(
        animation: Tween(
          begin: 0.0,
          end: 1.0,
        ).animate(animation),
        child: child,
      );

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return child;
  }

  @override
  Future<RoutePopDisposition> willPop() {
    onDismissed?.call();
    return super.willPop();
  }


}

class FrostTransition extends AnimatedWidget {
  final Widget child;
  final Animation<double> animation;
  final double maxSigma;

  FrostTransition({this.animation, this.child, this.maxSigma = 5}) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return new BackdropFilter(
      filter: new ImageFilter.blur(
          sigmaX: animation.value * maxSigma, sigmaY: animation.value * maxSigma),
      child: Opacity(opacity: animation.value, child: child)
    );
  }
}
