import 'package:intl/intl.dart';

abstract final class DateKeys {
  static String dateKey(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  static String donemKey(DateTime dt) => DateFormat('yyyy-MM').format(dt);
}
