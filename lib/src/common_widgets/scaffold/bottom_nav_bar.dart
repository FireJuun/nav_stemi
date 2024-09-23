import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

// inspiration: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html#material.BottomNavigationBar.3
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      onTap: onDestinationSelected,
      type: BottomNavigationBarType.shifting,
      selectedItemColor: colorScheme.onPrimary,
      selectedFontSize: 24,
      unselectedFontSize: 16,
      currentIndex: selectedIndex,
      showUnselectedLabels: true,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.navigation),
          label: 'Go'.hardcoded,
          backgroundColor: colorScheme.primary,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.edit),
          label: 'Add Data'.hardcoded,
          backgroundColor: colorScheme.secondary,
        ),
      ],
    );
  }
}
