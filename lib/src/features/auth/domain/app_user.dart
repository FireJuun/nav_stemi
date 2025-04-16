import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;

sealed class AppUser {}

class GoogleAppUser extends AppUser {
  GoogleAppUser({required this.user, required this.client});

  final GoogleSignInAccount user;
  final auth.AuthClient client;
}
