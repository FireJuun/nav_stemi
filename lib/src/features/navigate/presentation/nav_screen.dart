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
  bool _showNextTurn = true;

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
                    onTapNearestPciCenter: () {
                      // TODO(FireJuun): handle tap for nearest pci
                    },
                    onTapNearestEd: () {
                      // TODO(FireJuun): handle tap for nearest ed
                    },
                  ),
                  gapH4,
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: AlignmentDirectional.center,
                      children: [
                        const FakeMap(),
                        AnimatedSwitcher(
                          duration: 300.ms,
                          child: _showNextTurn
                              ? Align(
                                  alignment: Alignment.topCenter,
                                  child: TurnDirections(
                                    onTap: () =>
                                        setState(() => _showNextTurn = false),
                                  ),
                                )
                              : Align(
                                  alignment: AlignmentDirectional.topStart,
                                  child: FilledButton.tonalIcon(
                                    icon: const Icon(Icons.expand_more),
                                    label: Text('Next Step'.hardcoded),
                                    onPressed: () =>
                                        setState(() => _showNextTurn = true),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
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
                    child: Center(child: Text('All Steps'.hardcoded)),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.alt_route),
                        tooltip: 'Other Routes'.hardcoded,
                        onPressed: () {
                          // TODO(FireJuun): Query Other Routes Dialog
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.moving),
                        tooltip: 'Show Entire Route'.hardcoded,
                        onPressed: () {
                          // TODO(FireJuun): Zoom map to full route
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.my_location),
                        tooltip: 'My Location'.hardcoded,
                        onPressed: () {
                          // TODO(FireJuun): Zoom map to current location
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Positioned.directional(
                textDirection: Directionality.of(context),
                end: 4,
                bottom: 4,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      tooltip: 'Zoom Out'.hardcoded,
                      onPressed: () {
                        // TODO(FireJuun): Zoom map out
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      tooltip: 'Zoom In'.hardcoded,
                      onPressed: () {
                        // TODO(FireJuun): Zoom map in
                      },
                    ),
                  ],
                ),
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
                          child: Text('All Steps'.hardcoded),
                        )
                      : OutlinedButton(
                          onPressed: () => setState(() => _showSteps = true),
                          child: Text('All Steps'.hardcoded),
                        ),
                ),
              ),
              Align(
                alignment: const Alignment(-1, .25),
                child: IconButton(
                  onPressed: () {
                    // TODO(FireJuun): handle directions toggle (+ redraw)
                  },
                  tooltip: 'Narrate Directions'.hardcoded,
                  icon: const Icon(Icons.voice_over_off),
                ),
              )
                  .animate(
                    target: shouldShowSteps() ? 1 : 0,
                    delay: 400.ms,
                  )
                  .fadeIn(
                    duration: 200.ms,
                  ),
              Align(
                alignment: const Alignment(1, .25),
                child: IconButton(
                  onPressed: () {
                    // TODO(FireJuun): handle north up toggle (+ redraw)
                  },
                  tooltip: 'North Points Up'.hardcoded,
                  icon: const Icon(Icons.explore),
                ),
              )
                  .animate(
                    target: shouldShowSteps() ? 1 : 0,
                    delay: 400.ms,
                  )
                  .fadeIn(
                    duration: 200.ms,
                  ),
            ],
          ),
        );
      },
    );
  }
}
