import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Main navigation screen that displays different content based on selection
class NavScreen extends StatelessWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        // Make sure we have the initial position, authentication state, and active destination
        final positionAsyncValue =
            ref.watch(getLastKnownOrCurrentPositionProvider);
        final authState = ref.watch(authStateChangesProvider);
        final activeDestinationValue = ref.watch(activeDestinationProvider);

        // First check if we have location data
        return positionAsyncValue.when(
          data: (position) {
            // Check authentication status and active destination
            return authState.when(
              data: (user) {
                final isLoggedIn = user != null;
                final hasDestination =
                    activeDestinationValue.valueOrNull != null;

                // If logged in and destination selected, show navigation
                if (isLoggedIn && hasDestination) {
                  return NavScreenGoogle(initialPosition: position);
                }

                // If not logged in OR no destination is selected, show the ListEDOptions
                // (mirroring the pattern in NavScreenGoogle when no destination is set)
                return Material(
                  color: Theme.of(context).colorScheme.surface,
                  child: const ListEDOptions(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
                  const Center(child: Text('Authentication error')),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) =>
              const Center(child: Text('Error getting location data')),
        );
      },
    );
  }
}
