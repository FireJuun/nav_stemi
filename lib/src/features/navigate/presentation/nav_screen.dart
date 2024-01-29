import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});

  @override
  State<NavScreen> createState() => _NavScreenState();
}

class _NavScreenState extends State<NavScreen> {
  bool _showSteps = false;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;
        bool shouldShowSteps() => _showSteps && !isKeyboardVisible;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  NearestEdSelector(
                    onTapNearestPciCenter: () {},
                    onTapNearestEd: () {},
                  ),
                  gapH4,
                  const Expanded(child: FakeMap()),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: _showSteps ? 0 : 60,
                    child: const SizedBox.shrink(),
                  ),
                  AnimatedContainer(
                    duration: 300.ms,
                    height: shouldShowSteps()
                        ? MediaQuery.of(context).size.height * 0.25
                        : 0,
                    // TODO(FireJuun): directions go here
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: shouldShowSteps()
                          ? Border.all(color: colorScheme.onSurface)
                          : null,
                    ),
                    child: const Center(child: Text('Directions')),
                  ),
                ],
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                start: 4,
                bottom: 4,
                child: AnimatedSwitcher(
                  duration: 300.ms,
                  child: shouldShowSteps()
                      ? FilledButton(
                          onPressed: () => setState(() => _showSteps = false),
                          child: Text('Steps'.hardcoded),
                        )
                      : OutlinedButton(
                          onPressed: () => setState(() => _showSteps = true),
                          child: Text('Steps'.hardcoded),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
