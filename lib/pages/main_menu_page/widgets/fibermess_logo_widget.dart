import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class FibermessLogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(FlutterI18n.translate(context, "appName"), style: TextStyle(fontFamily: 'Audiowide')),
        Positioned.fill(child:
        BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 20,
              sigmaY: 20,
            ),
            child: Container(color: Colors.black.withOpacity(0),)
        ),
        ),
        Text(FlutterI18n.translate(context, "appName"), style: TextStyle(fontFamily: 'Audiowide')),
      ],
    );
  }
}