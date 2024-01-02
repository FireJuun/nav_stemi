/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
///
/// a small helper function to return a Future with a configurable delay
// ignore: avoid_positional_boolean_parameters
Future<void> delay(bool addDelay, [int milliseconds = 2000]) {
  if (addDelay) {
    return Future.delayed(Duration(milliseconds: milliseconds));
  } else {
    return Future.value();
  }
}
