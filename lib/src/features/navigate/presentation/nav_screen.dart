import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreen extends HookWidget {
  const NavScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = useState(false);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Expanded(
                  child: SafeArea(
                    child: Container(
                      height: 100,
                      color: Colors.red[400],
                      child: Center(
                        child: Text(
                          '+ STEMI',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge!
                              .apply(color: colorScheme.onPrimary),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SafeArea(
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        border: Border.all(
                          color: const Color(0xFF4F4F4F),
                          width: 12,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Total Time\n8:34',
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge!.apply(
                            color: colorScheme.onPrimary,
                            heightDelta: -.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Flexible(
              child: Column(
                children: [
                  gapH8,
                  const Text('Time to closest'),
                  gapH12,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('PCI Center\n24 min'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('ED\n17 min'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Flexible(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: MapSample(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: const NavBottomLinks(),
      ),
    );
  }
}
