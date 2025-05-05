import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: colorScheme.secondary,
            ),
            child: Center(
              child: Text(
                'Nav STEMI'.hardcoded,
                style: textTheme.headlineMedium
                    ?.apply(color: colorScheme.onSecondary),
              ),
            ),
          ),
          const ShowNavSteps(),
          const NavigationSettingsView(),
        ],
      ),
    );
  }
}

class ShowNavSteps extends ConsumerWidget {
  const ShowNavSteps({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final textColor = colorScheme.secondary;
    final mapSessionReadyValue = ref.watch(mapSessionReadyProvider);

    return AsyncValueWidget(
      value: mapSessionReadyValue,
      data: (mapSessionReady) {
        if (!mapSessionReady) {
          return const SizedBox();
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.play_arrow,
                color: textColor,
              ),
              title: Text(
                'Start Navigation'.hardcoded,
                style: textTheme.titleMedium?.apply(color: textColor),
              ),
              onTap: () {
                unawaited(
                  ref
                      .read(googleNavigationServiceProvider)
                      .startDrivingDirections(),
                );

                if (!context.mounted) return;
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.stop,
                color: textColor,
              ),
              title: Text(
                'Stop Navigation'.hardcoded,
                style: textTheme.titleMedium?.apply(color: textColor),
              ),
              onTap: () {
                unawaited(
                  ref
                      .read(googleNavigationServiceProvider)
                      .stopDrivingDirections(),
                );

                if (!context.mounted) return;
                Scaffold.of(context).closeEndDrawer();
              },
            ),
            const Divider(),
          ],
        );
      },
    );
  }
}
