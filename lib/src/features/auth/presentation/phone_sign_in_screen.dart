import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/src/routing/export.dart';

/// Dedicated phone authentication screen using firebase_ui_auth
class PhoneSignInScreen extends StatelessWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SignInScreen(
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
        // For wider screens (web/desktop)
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.security,
                size: 120,
                color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 24),
              Text(
                'Secure Phone Authentication',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
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
            ],
          ),
        );
      },
    );
  }
}
