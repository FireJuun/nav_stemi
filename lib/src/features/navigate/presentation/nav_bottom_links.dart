import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavBottomLinks extends StatelessWidget {
  const NavBottomLinks({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
