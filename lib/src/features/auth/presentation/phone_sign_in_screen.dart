import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Dedicated phone authentication screen using firebase_ui_auth
class PhoneSignInScreen extends StatelessWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
      // TODO(FireJuun): re-implement 'register' if email/pw auth is enabled
      showAuthActionSwitch: false,
      headerBuilder: (context, constraints, shrinkOffset) => const AuthLogo(),
      subtitleBuilder: (context, action) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your phone number is used only for authentication '
            'and will not be shared.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
      ),
      actions: [
        VerifyPhoneAction((context, action) {
          context.goNamed(AppRoute.phoneInput.name, extra: action);
        }),
        AuthStateChangeAction<AuthState>((context, state) {
          final user = switch (state) {
            SignedIn(user: final user) => user,
            CredentialLinked(user: final user) => user,
            UserCreated(credential: final cred) => cred.user,
            _ => null,
          };

          debugPrint('User signed in: ${user?.uid}');
        }),
      ],
      sideBuilder: (context, shrinkOffset) {
        // For wider screens (landscape)
        return const Center(child: AuthLogo(width: 256));
      },
    );
  }
}
