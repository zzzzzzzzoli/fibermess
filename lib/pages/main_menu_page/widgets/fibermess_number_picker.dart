import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Created by Marcin Szałek

class NumberPicker extends StatelessWidget {
  ///height of every list element for normal number picker
  ///width of every list element for horizontal number picker
  static const double kDefaultItemExtent = 50.0;

  ///width of list view for normal number picker
  ///height of list view for horizontal number picker
  static const double kDefaultListViewCrossAxisSize = 100.0;

  ///constructor for integer number picker
  NumberPicker({
    Key key,
    @required int initialValue,
    @required this.minValue,
    @required this.maxValue,
    @required this.onChanged,
    this.itemExtent = kDefaultItemExtent,
    this.listViewWidth = kDefaultListViewCrossAxisSize,
    this.zeroPad = false,
    this.highlightSelectedValue = true,
    this.decoration,
  })  : assert(initialValue != null),
        assert(minValue != null),
        assert(maxValue != null),
        assert(maxValue > minValue),
        assert(initialValue >= minValue && initialValue <= maxValue),
        decimalPlaces = 0,
        intScrollController = ScrollController(
          initialScrollOffset:
          (initialValue - minValue) * itemExtent,
        ),
        listViewHeight = 2 * itemExtent,
        integerItemCount = maxValue - minValue + 1,
        super(key: key);

  ///called when selected value changes
  final ValueChanged<num> onChanged;

  ///min value user can pick
  final int minValue;

  ///max value user can pick
  final int maxValue;

  ///inidcates how many decimal places to show
  /// e.g. 0=>[1,2,3...], 1=>[1.0, 1.1, 1.2...]  2=>[1.00, 1.01, 1.02...]
  final int decimalPlaces;

  ///height of every list element in pixels
  final double itemExtent;

  ///height of list view in pixels
  final double listViewHeight;

  ///width of list view in pixels
  final double listViewWidth;

  ///ScrollController used for integer list
  final ScrollController intScrollController;

  ///Currently selected integer value
  int selectedIntValue;

  ///If currently selected value should be highlighted
  final bool highlightSelectedValue;

  ///Decoration to apply to central box where the selected value is placed
  final Decoration decoration;

  ///Pads displayed integer values up to the length of maxValue
  final bool zeroPad;

  ///Amount of items
  final int integerItemCount;

  //
  //----------------------------- PUBLIC ------------------------------
  //

  /// Used to animate integer number picker to new selected value
  void animateInt(int valueToSelect) {
    animateIntToIndex(valueToSelect - minValue);
  }

  /// Used to animate integer number picker to new selected index
  void animateIntToIndex(int index) {
    _animate(intScrollController, index * itemExtent);
  }

  //
  //----------------------------- VIEWS -----------------------------
  //

  ///main widget
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return _integerListView(themeData);
  }

  Widget _integerListView(ThemeData themeData) {
    var listItemCount = integerItemCount + 1;
    return Listener(
      onPointerUp: (ev) {
        ///used to detect that user stopped scrolling
        if (intScrollController.position.activity is HoldScrollActivity) {
          animateInt(selectedIntValue);
        }
      },
      child: new NotificationListener(
        child: new Container(
          height: listViewHeight,
          width: listViewWidth,
          child: Stack(
            children: <Widget>[
              ScrollConfiguration(
                behavior: NoGlowScrollBehavior(),
                child: ListView.builder(
                  controller: intScrollController,
                  itemExtent: itemExtent,
                  itemCount: listItemCount,
                  cacheExtent: _calculateCacheExtent(listItemCount),
                  itemBuilder: (BuildContext context, int index) {
                    final int value = _intValueFromIndex(index);

                    bool isExtra = index > listItemCount - 2;

                    return isExtra
                        ? Container() //empty first and last element
                        : Container(
                      alignment: Alignment.center,
                          child: Text(
                            getDisplayedValue(value),
                            style: TextStyle(
                                fontFamily: 'Audiowide',
                                decoration: TextDecoration.none,
                                fontSize: 40,
                                color: Colors.white),
                          ),
                        );
                  },
                ),
              ),
              _NumberPickerSelectedItemDecoration(
                itemExtent: itemExtent,
                decoration: decoration == null ? BoxDecoration(border: Border.all(color: Colors.white)) : decoration,
              ),
            ],
          ),
        ),
        onNotification: _onIntegerNotification,
      ),
    );
  }

  String getDisplayedValue(int value) {
    final text = zeroPad
        ? value.toString().padLeft(maxValue.toString().length, '0')
        : value.toString();
    return text;
  }

  //
  // ----------------------------- LOGIC -----------------------------
  //

  int _intValueFromIndex(int index) {
    return minValue + index;
  }

  bool _onIntegerNotification(Notification notification) {
    if (notification is ScrollNotification) {
      //calculate
      int intIndexOfMiddleElement =
      (notification.metrics.pixels / itemExtent).round();
      intIndexOfMiddleElement =
            intIndexOfMiddleElement.clamp(0, integerItemCount - 1);

      int intValueInTheMiddle = _intValueFromIndex(intIndexOfMiddleElement);

      if (_userStoppedScrolling(notification, intScrollController)) {
        //center selected value
        animateIntToIndex(intIndexOfMiddleElement);
      }

      //update selection
      if (intValueInTheMiddle != selectedIntValue) {
        onChanged(intValueInTheMiddle);
        selectedIntValue = intValueInTheMiddle;
      }
    }
    return true;
  }

  ///There was a bug, when if there was small integer range, e.g. from 1 to 5,
  ///When user scrolled to the top, whole listview got displayed.
  ///To prevent this we are calculating cacheExtent by our own so it gets smaller if number of items is smaller
  double _calculateCacheExtent(int itemCount) {
    double cacheExtent = 250.0; //default cache extent
    if ((itemCount - 2) * kDefaultItemExtent <= cacheExtent) {
      cacheExtent = ((itemCount - 3) * kDefaultItemExtent);
    }
    return cacheExtent;
  }

  ///When overscroll occurs on iOS,
  ///we can end up with value not in the range between [minValue] and [maxValue]
  ///To avoid going out of range, we change values out of range to border values.
  int _normalizeMiddleValue(int valueInTheMiddle, int min, int max) {
    return math.max(math.min(valueInTheMiddle, max), min);
  }

  ///indicates if user has stopped scrolling so we can center value in the middle
  bool _userStoppedScrolling(
      Notification notification,
      ScrollController scrollController,
      ) {
    return notification is UserScrollNotification &&
        notification.direction == ScrollDirection.idle &&
        scrollController.position.activity is! HoldScrollActivity;
  }

  ///scroll to selected value
  _animate(ScrollController scrollController, double value) {
    scrollController.animateTo(value,
        duration: new Duration(seconds: 1), curve: new ElasticOutCurve());
  }
}

class _NumberPickerSelectedItemDecoration extends StatelessWidget {
  final double itemExtent;
  final Decoration decoration;

  const _NumberPickerSelectedItemDecoration(
      {Key key,
        @required this.itemExtent,
        @required this.decoration})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new IgnorePointer(
        child: new Container(
          width: double.infinity,
          height: itemExtent,
          decoration: decoration,
        ),
      ),
    );
  }
}
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
