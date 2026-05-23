import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'features/shell/app_gate.dart';
import 'theme/el_emegi_theme.dart';

class ElEmegiApp extends StatelessWidget {
  const ElEmegiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'El Emeği 360',
      debugShowCheckedModeBanner: false,
      locale: const Locale('tr', 'TR'),
      supportedLocales: const [Locale('tr', 'TR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ElEmegiTheme.dark(),
      darkTheme: ElEmegiTheme.dark(),
      themeMode: ThemeMode.dark,
      home: const AppGate(),
    );
  }
}
