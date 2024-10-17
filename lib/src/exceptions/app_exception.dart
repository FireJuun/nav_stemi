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

class LoginFailedException extends AppException {
  LoginFailedException() : super('login-failed', 'Login failed'.hardcoded);
}

class LogoutFailedException extends AppException {
  LogoutFailedException() : super('logout-failed', 'Logout failed'.hardcoded);
}

/// Navigation Exceptions
class RouteInformationNotAvailableException extends AppException {
  RouteInformationNotAvailableException()
      : super(
          'route-information-not-available',
          'Route information not available'.hardcoded,
        );
}

class NextClosestRouteNotAvailableException extends AppException {
  NextClosestRouteNotAvailableException()
      : super(
          'no-next-closest-route-available',
          'No next closest route available'.hardcoded,
        );
}

class ConvertMetersToMilesException extends AppException {
  ConvertMetersToMilesException()
      : super(
          'convert-meters-to-miles-failed',
          'Unable to convert distance from meters to miles'.hardcoded,
        );
}

class NoNearbyEdsAvailableException extends AppException {
  NoNearbyEdsAvailableException()
      : super('no-nearby-eds-available', 'No nearby EDS available'.hardcoded);
}

class NoPCICentersAvailableException extends AppException {
  NoPCICentersAvailableException()
      : super('no-pci-centers-available', 'No PCI centers available'.hardcoded);
}
