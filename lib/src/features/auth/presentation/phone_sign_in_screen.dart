import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Dedicated phone authentication screen using firebase_ui_auth
class PhoneSignInScreen extends StatelessWidget {
  const PhoneSignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SignInScreen(
        // TODO(FireJuun): re-implement 'register' if email/pw auth is enabled
        showAuthActionSwitch: false,
        headerMaxExtent: 256,
        headerBuilder: (context, constraints, shrinkOffset) => const Column(
          children: [
            Expanded(child: AuthLogo()),
            AuthLogoSubtitle(),
          ],
        ),
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
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                AuthLogo(),
                AuthLogoSubtitle(),
              ],
            ),
          );
        },
      ),
    );
  }
}
