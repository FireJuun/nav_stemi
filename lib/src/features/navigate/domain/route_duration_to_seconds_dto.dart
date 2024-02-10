import 'package:duration/duration.dart';

class RouteDurationToSecondsDto {
  /// Route duration is provided in '__s' format,
  /// where '__' is the number of seconds.
  /// This method converts the route duration to seconds.
  Duration routeDurationToSeconds(String? routeDuration) {
    if (routeDuration == null) {
      return Duration.zero;
    }

    final seconds = int.parse(routeDuration.split('s').first);
    return Duration(seconds: seconds);
  }

  /// Route duration is provided in '__s' format,
  /// where '__' is the number of seconds.
  /// This method converts the route duration to a formatted string.
  String routeDurationToFormattedString(String? routeDuration) {
    final duration = routeDurationToSeconds(routeDuration);
    return prettyDuration(duration, abbreviated: true, delimiter: ' ');
  }
}
