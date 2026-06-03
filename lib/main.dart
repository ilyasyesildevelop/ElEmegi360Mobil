import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/remote/firebase_bootstrap.dart';
import 'services/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    initializeDateFormatting('tr_TR'),
    FirebaseBootstrap.initialize(),
    LocalNotificationService.instance.initialize(),
  ]);
  runApp(const ElEmegiApp());
}
