String timerIntToString(int? timerInt) {
  if (timerInt == null) {
    return '----';
  }

  final duration = Duration(seconds: timerInt);
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  final twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours == 0) {
    return '$twoDigitMinutes:$twoDigitSeconds';
  } else {
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
  }
}

Duration timerIntAsDuration(int? timerInt) {
  return Duration(seconds: timerInt ?? 0);
}
