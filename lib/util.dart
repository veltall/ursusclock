class Utilities {
  static DateTime modifyDateTime(
    DateTime original, {
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    if (original.isUtc) {
      return DateTime.utc(
        year ?? original.year,
        month ?? original.month,
        day ?? original.day,
        hour ?? original.hour,
        minute ?? original.minute,
        second ?? original.second,
        millisecond ?? original.millisecond,
        microsecond ?? original.microsecond,
      );
    } else {
      return DateTime(
        year ?? original.year,
        month ?? original.month,
        day ?? original.day,
        hour ?? original.hour,
        minute ?? original.minute,
        second ?? original.second,
        millisecond ?? original.millisecond,
        microsecond ?? original.microsecond,
      );
    }
  }

  static DateTime roundToHour(DateTime original, {required hour}) {
    return modifyDateTime(
      original,
      year: original.year,
      month: original.month,
      day: original.day,
      hour: hour,
      minute: 0,
      second: 0,
      millisecond: 0,
      microsecond: 0,
    );
  }
}

// void main(List<String> args) {
//   var now = DateTime.now().add(const Duration(hours: 2));
//   print(now.hour);
//   print(now.toUtc().hour);
// }
