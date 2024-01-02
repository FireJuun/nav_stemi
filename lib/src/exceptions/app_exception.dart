import 'package:nav_stemi/nav_stemi.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
/// Base class for client-side errors
sealed class AppException implements Exception {
  AppException(this.code, this.message);
  final String code;
  final String message;

  @override
  String toString() => message;
}

/// Auth
class LoginProcessCancelledException extends AppException {
  LoginProcessCancelledException()
      : super('login-process-cancelled', 'Login process cancelled'.hardcoded);
}
