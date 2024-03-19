import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Excellent article showing how to do this:
/// https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/
/// based on:
/// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
///
class ScaffoldWithNestedNavigation extends HookWidget {
  const ScaffoldWithNestedNavigation({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) => navigationShell.goBranch(
        index,
        initialLocation: index == navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final canPop = useState(false);
    final colorScheme = Theme.of(context).colorScheme;
    final isNavPage = navigationShell.currentIndex == 0;

    return PopScope(
      canPop: canPop.value,
      onPopInvoked: (didPop) async {
        final shouldPop = await showAlertDialog(
              context: context,
              title: 'Exit Navigation?'.hardcoded,
              cancelActionText: 'Go back'.hardcoded,
              defaultActionText: 'EXIT'.hardcoded,
            ) ??
            false;
        canPop.value = shouldPop;
        if (shouldPop && context.mounted) {
          context.goNamed(AppRoute.home.name);
        }
      },
      child: Scaffold(
        appBar: const AppBarWidget(),
        endDrawer: const RightNavDrawer(),
        body: AnimatedContainer(
          duration: 300.ms,
          color: isNavPage
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          child: navigationShell,
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: _onTap,
        ),
      ),
    );
  }
}
