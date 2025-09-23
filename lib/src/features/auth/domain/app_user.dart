import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:http/http.dart' as http;

sealed class AppUser {
  const AppUser({required this.uid});

  final String uid;

  List<Object?> get props => [uid, uid];
}

final class FirebaseAppUser extends AppUser {
  const FirebaseAppUser({required super.uid, this.displayName});

  final String? displayName;

  @override
  List<Object?> get props => [uid, displayName];
}

class GoogleAppUser extends AppUser {
  GoogleAppUser({required this.user, required this.client})
      : super(uid: user.id);

  final GoogleSignInAccount user;
  final auth.AuthClient client;
}

class ServiceAccountUser extends AppUser {
  ServiceAccountUser({
    required this.email,
    required this.client,
  }) : super(uid: '');

  final String email;
  final http.Client client;
}

/// Fake app user for staging environment
///
/// This user implementation doesn't communicate with any real services
/// and is used only for testing and demo purposes
class FakeAppUser extends AppUser {
  FakeAppUser({
    required this.email,
  }) : super(uid: '');

  final String email;
}
