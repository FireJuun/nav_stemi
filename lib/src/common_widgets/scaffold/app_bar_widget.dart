import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _toolbarHeight = 76.0;

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      toolbarHeight: _toolbarHeight,
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
                    style: textTheme.titleMedium
                        ?.apply(color: colorScheme.onBackground),
                  ),
                ],
              ),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              height: _toolbarHeight,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(_toolbarHeight);
}
