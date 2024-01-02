import 'package:flutter/foundation.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_logger.g.dart';

/// Original source: Andrea Bizzotto
/// https://github.com/bizz84/complete-flutter-course
class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    // * This can be replaced with a call to a crash reporting tool of choice
    debugPrint('$error, $stackTrace');
  }

  void logAppException(AppException exception) {
    // * This can be replaced with a call to a crash reporting tool of choice
    debugPrint('$exception');
  }
}

@riverpod
ErrorLogger errorLogger(ErrorLoggerRef ref) {
  return ErrorLogger();
}
