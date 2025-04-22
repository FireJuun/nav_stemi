import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

/// Excellent article showing how to do this:
/// https://codewithandrea.com/articles/flutter-bottom-navigation-bar-nested-routes-gorouter/
/// based on:
/// https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/stateful_shell_route.dart
///
class ScaffoldWithNestedNavigation extends StatefulWidget {
  const ScaffoldWithNestedNavigation({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey('ScaffoldWithNestedNavigation'));

  final StatefulNavigationShell navigationShell;

  @override
  State<ScaffoldWithNestedNavigation> createState() =>
      _ScaffoldWithNestedNavigationState();
}

class _ScaffoldWithNestedNavigationState
    extends State<ScaffoldWithNestedNavigation> {
  bool _canPop = false;

  void _onTap(int index) => widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isNavPage = widget.navigationShell.currentIndex == 0;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) async {
        final shouldPop = await showAlertDialog(
              context: context,
              title: 'Exit Navigation?'.hardcoded,
              cancelActionText: 'Go back'.hardcoded,
              defaultActionText: 'EXIT'.hardcoded,
            ) ??
            false;

        if (shouldPop && context.mounted) {
          // Show survey dialog before exit
          await SurveyDialog.show(context);

          setState(() => _canPop = shouldPop);
          if (context.mounted) {
            context.goNamed(AppRoute.home.name);
          }
        }
      },
      child: Scaffold(
        appBar: const AppBarWidget(),
        endDrawer: const NavDrawer(),
        body: AnimatedContainer(
          duration: 300.ms,
          color: isNavPage
              ? colorScheme.primaryContainer
              : colorScheme.secondaryContainer,
          child: widget.navigationShell,
        ),
        bottomNavigationBar: BottomNavBar(
          selectedIndex: widget.navigationShell.currentIndex,
          onDestinationSelected: _onTap,
        ),
      ),
    );
  }
}
