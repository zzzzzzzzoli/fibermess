import 'package:flutter/material.dart';

class FibermessButton extends StatelessWidget {

  final Function onPressed;
  final String text;
  final double fontSize;
  final double padding;
  final double maxHeight;

  const FibermessButton({Key key, this.onPressed, this.text,
    this.fontSize = 25.0, this.padding = 20.0, this.maxHeight = double.maxFinite}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (maxHeight < double.maxFinite)
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        child: OutlineButton(
            textColor: Color(0xff01ff00),
            borderSide: BorderSide(color: Color(0xff01ff00)),
            padding: EdgeInsets.all(padding),
            onPressed: onPressed,
            child: Text(text,
                style: TextStyle(fontFamily: 'Audiowide', fontSize: fontSize)),
        ),
      );
    else
      return OutlineButton(
      textColor: Color(0xff01ff00),
      borderSide: BorderSide(color: Color(0xff01ff00)),
      padding: EdgeInsets.all(padding),
      onPressed: onPressed,
      child: Text(text,
          style: TextStyle(fontFamily: 'Audiowide', fontSize: fontSize)),

    );
  }

}