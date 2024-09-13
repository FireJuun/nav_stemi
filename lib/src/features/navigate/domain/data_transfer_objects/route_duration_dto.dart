import 'package:duration/duration.dart';

class RouteDurationDto {
  const RouteDurationDto() : super();

  /// Route duration is provided in '__s' format,
  /// where '__' is the number of seconds.
  /// This method converts the route duration to seconds.
  Duration? routeDurationToSeconds(String? routeDuration) {
    if (routeDuration == null) {
      return null;
    } else {
      final seconds = int.tryParse(routeDuration.split('s').first);
      if ((seconds == null) || (seconds < 0)) {
        return null;
      } else {
        return Duration(seconds: seconds);
      }
    }
  }

  /// Route duration is provided in '__s' format,
  /// where '__' is the number of seconds.
  /// This method converts the route duration to a formatted string.
  String routeDurationToFormattedString(String? routeDuration) {
    final duration = routeDurationToSeconds(routeDuration);
    if (duration == null) {
      return '--';
    }
    return prettyDuration(duration, abbreviated: true, delimiter: ' ');
  }

  String routeDurationToMinsString(String? routeDuration) {
    final duration = routeDurationToSeconds(routeDuration);
    if (duration == null) {
      return '--';
    }

    return '${duration.inMinutes} min';
  }
}
