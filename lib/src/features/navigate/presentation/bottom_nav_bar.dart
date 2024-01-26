import 'package:flutter/material.dart';
import 'package:nav_stemi/nav_stemi.dart';

// inspiration: https://api.flutter.dev/flutter/material/BottomNavigationBar-class.html#material.BottomNavigationBar.3
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BottomNavigationBar(
      onTap: _onItemTapped,
      type: BottomNavigationBarType.shifting,
      selectedItemColor: colorScheme.onPrimary,
      selectedFontSize: 24,
      unselectedFontSize: 16,
      currentIndex: _selectedIndex,
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
