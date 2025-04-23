import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import 'package:http/http.dart' as http;

sealed class AppUser {}

class GoogleAppUser extends AppUser {
  GoogleAppUser({required this.user, required this.client});

  final GoogleSignInAccount user;
  final auth.AuthClient client;
}

class ServiceAccountUser extends AppUser {
  ServiceAccountUser({
    required this.email,
    required this.client,
  });

  final String email;
  final http.Client client;
}
