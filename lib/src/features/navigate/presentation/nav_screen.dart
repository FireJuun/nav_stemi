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
        appBar: AppBar(
          toolbarHeight: 80,
          automaticallyImplyLeading: false,
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
                        color: colorScheme.onBackground,
                      ),
                      Text(
                        'Exit'.hardcoded,
                        style: textTheme.bodyLarge
                            ?.apply(color: colorScheme.onBackground),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ),
              Flexible(
                flex: 2,
                child: Container(
                  height: 78,
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer,
                    border: Border.all(
                      color: colorScheme.onTertiaryContainer,
                      width: 4,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Total Time'.hardcoded,
                        style: textTheme.headlineSmall
                            ?.apply(color: colorScheme.onTertiaryContainer),
                      ),
                      Text(
                        '8:34'.hardcoded,
                        style: textTheme.headlineSmall
                            ?.apply(color: colorScheme.onTertiaryContainer),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        endDrawer: const Drawer(),
        body: const Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: MapScreen(),
        ),
        bottomNavigationBar: const BottomNavBar(),
      ),
    );
  }
}
