/// Abstract date provider to allow date injection for unit testing.
abstract class DateProvider {
  DateTime get now;
  String get currentDateIso => dateToIso(now);

  static String dateToIso(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static DateTime parseIso(String iso) {
    return DateTime.parse(iso);
  }
}

/// Production DateProvider returning current local device date.
class LocalDateProvider implements DateProvider {
  const LocalDateProvider();

  @override
  DateTime get now {
    final dt = DateTime.now();
    return DateTime(dt.year, dt.month, dt.day);
  }

  @override
  String get currentDateIso => DateProvider.dateToIso(now);
}

/// Test DateProvider allowing mock date injection.
class TestDateProvider implements DateProvider {
  DateTime _currentDate;

  TestDateProvider(DateTime initialDate)
      : _currentDate = DateTime(initialDate.year, initialDate.month, initialDate.day);

  void setDate(DateTime date) {
    _currentDate = DateTime(date.year, date.month, date.day);
  }

  void advanceDays(int days) {
    _currentDate = _currentDate.add(Duration(days: days));
  }

  @override
  DateTime get now => _currentDate;

  @override
  String get currentDateIso => DateProvider.dateToIso(_currentDate);
}
