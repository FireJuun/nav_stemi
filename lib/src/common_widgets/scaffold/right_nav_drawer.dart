import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class RightNavDrawer extends ConsumerWidget {
  const RightNavDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final textColor = colorScheme.secondary;

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
          ListTile(
            leading: Icon(
              Icons.play_circle,
              color: textColor,
            ),
            title: Text(
              'Start Simulation'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            onTap: () {
              unawaited(
                ref
                    .read(googleNavigationServiceProvider)
                    .simulateUserLocation(),
              );

              if (!context.mounted) return;
              Scaffold.of(context).closeEndDrawer();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.stop_circle,
              color: textColor,
            ),
            title: Text(
              'Stop Simulation'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            onTap: () {
              unawaited(
                ref.read(googleNavigationServiceProvider).stopSimulation(),
              );
              if (!context.mounted) return;
              Scaffold.of(context).closeEndDrawer();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.play_arrow,
              color: textColor,
            ),
            title: Text(
              'Start Timer'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            onTap: () {
              ref.read(countUpTimerRepositoryProvider).start();
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
              'Stop Timer'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            onTap: () {
              ref.read(countUpTimerRepositoryProvider).stop();
              if (!context.mounted) return;
              Scaffold.of(context).closeEndDrawer();
            },
          ),
          ListTile(
            leading: Icon(
              Icons.refresh,
              color: textColor,
            ),
            title: Text(
              'Reset Timer'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            onTap: () {
              ref.read(countUpTimerRepositoryProvider).reset();
              if (!context.mounted) return;
              Scaffold.of(context).closeEndDrawer();
            },
          ),
        ],
      ),
    );
  }
}
