import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _toolbarHeight = 76.0;

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // Watch environment configuration
    final environmentConfig = ref.watch(appEnvironmentConfigProvider);

    // Watch authentication state changes to update UI based on login status
    final authState = ref.watch(authStateChangesProvider);

    return AppBar(
      toolbarHeight: _toolbarHeight,
      automaticallyImplyLeading: false,
      backgroundColor: environmentConfig.when(
        data: (config) => config.getAppBarColor(),
        loading: () => Colors.transparent,
        error: (_, __) => Colors.transparent,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.close,
                    // TODO(FireJuun): Incorporate into app theme
                    color: colorScheme.onPrimary,
                  ),
                  Text(
                    'Exit'.hardcoded,
                    style: textTheme.titleMedium
                        // TODO(FireJuun): Incorporate into app theme
                        ?.apply(color: colorScheme.onPrimary),
                  ),
                ],
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const Flexible(
            flex: 2,
            child: CountUpTimerView(height: _toolbarHeight - 8),
          ),
        ],
      ),
      actions: [
        // FHIR sync status indicator
        authState.when(
          data: (user) {
            if (user != null) {
              return const FhirSyncStatusIndicator();
            } else {
              return const SizedBox.shrink();
            }
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        // Profile icon button
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: authState.when(
              data: (user) => user != null
                  ? const Icon(Icons.account_circle)
                  : const Icon(Icons.account_circle_outlined),
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(Icons.error_outline),
            ),
            onPressed: () => _showAuthDialog(context, ref),
          ),
        ),
      ],
    );
  }

  void _showAuthDialog(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authStateChangesProvider);
    final user = authState.valueOrNull;

    if (user == null) {
      // Navigate to phone input page instead of showing dialog
      context.goNamed(AppRoute.phoneInput.name);
    } else {
      // Show profile/logout dialog for authenticated users
      showDialog<void>(
        context: context,
        builder: (context) => const AuthDialog(),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}

/// Dialog for authentication actions (login/logout)
class AuthDialog extends ConsumerWidget {
  const AuthDialog({this.onClose, super.key});

  /// Optional callback when the dialog is closed
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('Account'.hardcoded),
      content: authState.when(
        data: (user) {
          if (user != null) {
            var displayName = 'User';
            if (user is GoogleAppUser) {
              displayName = user.user.displayName ?? 'Google User';
            } else if (user is FirebaseAppUser) {
              displayName = user.displayName ?? 'Phone User';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Signed in as: $displayName'.hardcoded),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  ),
                  onPressed: () {
                    ref.read(authRepositoryProvider).signOut();
                    Navigator.of(context).pop();
                    onClose?.call();
                  },
                  child: Text('Sign Out'.hardcoded),
                ),
              ],
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('You are not signed in'.hardcoded),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.goNamed(AppRoute.phoneInput.name);
                  },
                  child: Text('Sign In'.hardcoded),
                ),
              ],
            );
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Text('Error: $error'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onClose?.call();
          },
          child: Text('Close'.hardcoded),
        ),
      ],
    );
  }
}
