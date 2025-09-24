import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          child: Consumer(
            builder: (context, ref, child) {
              final authState = ref.watch(authStateChangesProvider).value;

              return IconButton(
                icon: authState != null
                    ? const Icon(Icons.account_circle)
                    : const Icon(Icons.account_circle_outlined),
                onPressed: authState != null
                    ? () => showDialog<void>(
                          context: context,
                          builder: (context) => const UserProfileDialog(),
                        )
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
