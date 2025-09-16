import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Widget that displays different UI based on login status
/// Shows an upward arrow with text when logged out
/// Shows a button to view prior encounters when logged in
class LoginStatusIndicator extends ConsumerWidget {
  const LoginStatusIndicator({
    required this.onShowEncountersPressed,
    super.key,
  });

  final VoidCallback onShowEncountersPressed;

  static const Key viewPriorEncountersButtonKey =
      Key('view_prior_encounters_button');

  static const Key loginActionsKey = Key('login_actions');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final textTheme = Theme.of(context).textTheme;

    final isUserLoggedIn = authState.whenOrNull(
          data: (user) => user != null,
        ) ??
        false;

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16, right: 16),
        child: isUserLoggedIn
            ? FilledButton.icon(
                key: viewPriorEncountersButtonKey,
                onPressed: onShowEncountersPressed,
                icon: const Icon(Icons.history),
                label: Text('View Prior Encounters'.hardcoded),
              )
            : Column(
                key: loginActionsKey,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(
                      Icons.arrow_upward,
                      size: 28,
                    ),
                  ),
                  gapH8,
                  Text(
                    'Login for full features'.hardcoded,
                    style:
                        textTheme.bodySmall!.apply(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
      ),
    );
  }
}
