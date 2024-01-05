import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreen extends HookWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = useState(false);

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
          Navigator.pop(context, shouldPop);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('nav'),
          // automaticallyImplyLeading: false,
        ),
        bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          padding: const EdgeInsets.all(8),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).maybePop();
                  },
                  child: const Text(
                    'Cancel\nNav',
                    textAlign: TextAlign.center,
                  ),
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text(
                    'Contact\nPCI/ED',
                    textAlign: TextAlign.center,
                  ),
                ),
                FilledButton(
                  onPressed: () => context.goNamed(AppRoute.navAddData.name),
                  child: const Text(
                    'Add\nData',
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
