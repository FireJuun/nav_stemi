import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Can create a setting to show or hide this, based on user preference.
const _showStemiChecklist = true;

class AddDataScreen extends ConsumerWidget {
  const AddDataScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check authentication status
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // If not authenticated, show an embedded login prompt
          // This mirrors the pattern used in NavScreenGoogle when no destination is selected
          return Material(
            color: Theme.of(context).colorScheme.surface,
            child: const AddDataLoginPrompt(),
          );
        }

        // Show normal content when logged in
        return const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: AddDataScrollview(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Authentication error')),
    );
  }
}

/// Embedded login prompt shown when a user tries to access the AddDataScreen
/// while not logged in. Mirrors the pattern used in NavScreenGoogle.
class AddDataLoginPrompt extends ConsumerWidget {
  const AddDataLoginPrompt({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: colorScheme.primary,
          ),
          gapH24,
          Text(
            'Authentication Required'.hardcoded,
            style: textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          gapH16,
          Text(
            'You need to be logged in to add patient data'.hardcoded,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          gapH32,
          FilledButton.icon(
            onPressed: () {
              ref.read(authRepositoryProvider).signIn();
            },
            icon: const Icon(Icons.login),
            label: Text('Sign In'.hardcoded),
          ),
          gapH16,
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Go Back'.hardcoded),
          ),
        ],
      ),
    );
  }
}

class AddDataScrollview extends StatelessWidget {
  const AddDataScrollview({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        /// LayoutBuilder is used so that when the keyboard shows up,
        /// the app will automatically resize the checklist field.
        /// Otherwise, there's no space to see what you're typing.
        final checklistHeight = constraints.maxHeight * 0.25;
        return Column(
          children: [
            const DestinationInfo(),
            const EtaWidget(),
            const Divider(thickness: 2),
            const Expanded(child: AddDataTabs()),
            if (_showStemiChecklist) ...[
              gapH8,
              SizedBox(
                height: checklistHeight,
                child: const Checklist(),
              ),
            ],
          ],
        );
      },
    );
  }
}
