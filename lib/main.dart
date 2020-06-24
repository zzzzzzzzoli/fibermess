import 'dart:async';

import 'package:fibermess/pages/game_page/bloc/bloc.dart';
import 'package:fibermess/pages/game_page/widgets/game_widget.dart';
import 'package:fibermess/pages/main_menu_page/main_menu_page.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  Crashlytics.instance.enableInDevMode = true;
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
        useCountryCode: false,
        decodeStrategies: [JsonDecodeStrategy()],
        fallbackFile: 'en',
        basePath: 'assets/i18n',),
  );
  WidgetsFlutterBinding.ensureInitialized();
  await flutterI18nDelegate.load(null);
  runZoned(() {
    runApp(Fibermess(flutterI18nDelegate));
  }, onError: Crashlytics.instance.recordError);

}

class Fibermess extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;

  const Fibermess(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return BlocProvider(
        create: (_) => GameBloc(level: 20),
        child: Container(
            color: Colors.black,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
                title: "Fibermess",
                initialRoute: '/',
                routes: {
                  '/': (context) => MainMenuPage(),
                  '/game': (context) => GameWidget()
                },
              localizationsDelegates: [
                flutterI18nDelegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate
              ],
            )));
  }
}
