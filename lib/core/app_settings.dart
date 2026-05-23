import 'package:flutter/material.dart';

/// Uygulama ayarları — yalnızca koyu tema.
final class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final AppSettings instance = AppSettings._();

  static const ThemeMode themeMode = ThemeMode.dark;
}
