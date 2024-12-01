import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

// TODO(FireJuun): Readjust location of these values
const _showNarration = false;
const _showNorthUp = false;

/// spec: https://github.com/googlemaps/flutter-navigation-sdk/blob/main/example/lib/pages/navigation.dart
enum SimulationState { running, paused, notRunning }

class NavScreenGoogle extends StatefulWidget {
  const NavScreenGoogle({required this.initialPosition, super.key});

  final Position initialPosition;

  @override
  State<NavScreenGoogle> createState() => _NavScreenGoogleState();
}

class _NavScreenGoogleState extends State<NavScreenGoogle> {
  bool _showSteps = false;
  bool _showNextTurn = true;

  /// Audio guidance settings
  bool _showAudioGuidance = false;
  NavigationAudioGuidanceType _audioGuidanceType =
      NavigationAudioGuidanceType.alertsAndGuidance;

  /// Simulation settings
  bool _showSimulationControls = false;
  SimulationState _simulationState = SimulationState.notRunning;

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;

        bool shouldShowSteps() => _showSteps && !isKeyboardVisible;
        bool shouldShowAudioGuidance() =>
            _showAudioGuidance && !isKeyboardVisible;
        bool shouldShowSimulationControls() =>
            _showSimulationControls && !isKeyboardVisible;

        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: Consumer(
            builder: (context, ref, child) {
              /// Listen for errors across the various async providers used in
              /// this screen and in related screens
              ref
                ..listen<AsyncValue<void>>(
                  navScreenGoogleControllerProvider,
                  (_, state) => state.showAlertDialogOnError(context),
                )
                ..listen(
                  getLastKnownOrCurrentPositionProvider,
                  (_, state) => state.showAlertDialogOnError(context),
                );

              final activeDestinationValue =
                  ref.watch(activeDestinationProvider);

              ref.watch(navScreenGoogleControllerProvider);

              NavScreenGoogleController notifier() => ref.read(
                    navScreenGoogleControllerProvider.notifier,
                  );

              return AsyncValueWidget<ActiveDestination?>(
                value: activeDestinationValue,
                data: (activeDestination) {
                  if (activeDestination == null) {
                    return Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: const ListEDOptions(),
                    );
                  }

                  return Stack(
                    children: [
                      Column(
                        children: [
                          NearestEdSelector(
                            activeDestination: activeDestination,
                          ),
                          gapH4,
                          Expanded(
                            child: Stack(
                              alignment: AlignmentDirectional.center,
                              children: [
                                Consumer(
                                  builder: (context, ref, child) {
                                    ref.watch(
                                      navScreenGoogleControllerProvider,
                                    );

                                    return GoogleMapsNavigationView(
                                      onViewCreated: notifier().onViewCreated,
                                      initialCameraPosition: CameraPosition(
                                        target:
                                            widget.initialPosition.toLatLng(),
                                        zoom: 14,
                                      ),
                                    );
                                  },
                                ),
                                AnimatedSwitcher(
                                  duration: 300.ms,

                                  /// required due to this bug: https://github.com/flutter/flutter/issues/121336#issuecomment-1482620874
                                  transitionBuilder: (child, animation) =>
                                      FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                                  child: _showNextTurn
                                      ? const Align(
                                          alignment: Alignment.topCenter,

                                          // child: NextStep(
                                          //   routeLegStep: activeRoute.route
                                          //       .routeStepById(
                                          //     activeRoute.activeStepId,
                                          //   )!,
                                          //   onTap: () => setState(
                                          //     () => _showNextTurn = false,
                                          //   ),
                                          // ),
                                        )
                                      : Align(
                                          alignment:
                                              AlignmentDirectional.topStart,
                                          child: OutlinedButton.icon(
                                            style: Theme.of(context)
                                                .outlinedButtonTheme
                                                .style
                                                ?.copyWith(
                                                  backgroundColor:
                                                      WidgetStatePropertyAll(
                                                    colorScheme.surface,
                                                  ),
                                                ),
                                            icon: const Icon(
                                              Icons.expand_more,
                                            ),
                                            label: Text('Next Step'.hardcoded),
                                            onPressed: () => setState(
                                              () => _showNextTurn = true,
                                            ),
                                          ),
                                        ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: 300.ms,
                                    height: shouldShowSteps()
                                        ? MediaQuery.of(context).size.height *
                                            0.25
                                        : 0,
                                    // TODO(FireJuun): directions go here
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      border: shouldShowSteps()
                                          ? Border.all(
                                              color: colorScheme.onSurface,
                                            )
                                          : null,
                                    ),
                                    child: const NavSteps(),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: 300.ms,
                                    height:
                                        shouldShowAudioGuidance() ? null : 0,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      border: shouldShowAudioGuidance()
                                          ? Border.all(
                                              color: colorScheme.onSurface,
                                            )
                                          : null,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: AudioGuidancePicker(
                                      currentValue: _audioGuidanceType,
                                      onChanged: (guidanceType) {
                                        setState(
                                          () {
                                            _audioGuidanceType = guidanceType;
                                            _showAudioGuidance = false;
                                            notifier().setAudioGuidanceType(
                                              guidanceType,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                /// Simulation controls
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: AnimatedContainer(
                                    duration: 300.ms,
                                    height: shouldShowSimulationControls()
                                        ? null
                                        : 0,
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      border: shouldShowSimulationControls()
                                          ? Border.all(
                                              color: colorScheme.onSurface,
                                            )
                                          : null,
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: SimulationStatePicker(
                                      currentValue: _simulationState,
                                      onChanged: (state) {
                                        setState(() {
                                          _simulationState = state;
                                          _showSimulationControls = false;
                                          notifier().setSimulationState(state);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          gapH8,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              PrimaryToggleButton(
                                text: 'All Steps'.hardcoded,
                                onPressed: () => setState(
                                  () => _showSteps = !_showSteps,
                                ),
                                isActive: shouldShowSteps(),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  /// volume up, important, volume off
                                  IconButton(
                                    icon: switch (_audioGuidanceType) {
                                      NavigationAudioGuidanceType
                                            .alertsAndGuidance =>
                                        const Icon(Icons.volume_up),
                                      NavigationAudioGuidanceType.alertsOnly =>
                                        const Icon(
                                          Icons.notification_important_outlined,
                                        ),
                                      NavigationAudioGuidanceType.silent =>
                                        const Icon(Icons.volume_off),
                                    },
                                    isSelected: _showAudioGuidance,
                                    tooltip: 'Audio Guidance'.hardcoded,
                                    onPressed: () {
                                      setState(() {
                                        _showAudioGuidance =
                                            !_showAudioGuidance;
                                      });
                                    },
                                  ),

                                  /// start, pause, stop navigation
                                  IconButton(
                                    icon: switch (_simulationState) {
                                      SimulationState.running =>
                                        const Icon(Icons.play_arrow),
                                      SimulationState.paused => const Icon(
                                          Icons.pause,
                                        ),
                                      SimulationState.notRunning =>
                                        const Icon(Icons.stop),
                                    },
                                    isSelected: _showSimulationControls,
                                    tooltip: 'Navigation State'.hardcoded,
                                    onPressed: () {
                                      setState(() {
                                        _showSimulationControls =
                                            !_showSimulationControls;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.moving),
                                    tooltip: 'Show Entire Route'.hardcoded,
                                    onPressed: notifier().zoomToActiveRoute,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    tooltip: 'Zoom Out'.hardcoded,
                                    onPressed: notifier().zoomOut,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    tooltip: 'Zoom In'.hardcoded,
                                    onPressed: notifier().zoomIn,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (_showNarration)
                        Align(
                          alignment: const Alignment(-1, .2),
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
                            )
                            .fadeIn(
                              duration: 200.ms,
                            ),
                      if (_showNorthUp)
                        Align(
                          alignment: const Alignment(1, .2),
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
                            )
                            .fadeIn(
                              duration: 200.ms,
                            ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class AudioGuidancePicker extends StatelessWidget {
  const AudioGuidancePicker({
    required this.currentValue,
    required this.onChanged,
    super.key,
  });

  final NavigationAudioGuidanceType currentValue;
  final ValueChanged<NavigationAudioGuidanceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: currentValue ==
                  NavigationAudioGuidanceType.alertsAndGuidance
              ? null
              : () => onChanged(NavigationAudioGuidanceType.alertsAndGuidance),
          icon: const Icon(Icons.volume_up),
        ),
        IconButton(
          onPressed: currentValue == NavigationAudioGuidanceType.alertsOnly
              ? null
              : () => onChanged(NavigationAudioGuidanceType.alertsOnly),
          icon: const Icon(Icons.notification_important_outlined),
        ),
        IconButton(
          onPressed: currentValue == NavigationAudioGuidanceType.silent
              ? null
              : () => onChanged(NavigationAudioGuidanceType.silent),
          icon: const Icon(Icons.volume_off),
        ),
      ],
    );
  }
}

class SimulationStatePicker extends StatelessWidget {
  const SimulationStatePicker({
    required this.currentValue,
    required this.onChanged,
    super.key,
  });

  final SimulationState currentValue;
  final ValueChanged<SimulationState> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: currentValue == SimulationState.running
              ? null
              : () => onChanged(SimulationState.running),
          icon: const Icon(Icons.play_arrow),
        ),
        IconButton(
          onPressed: currentValue == SimulationState.paused
              ? null
              : () => onChanged(SimulationState.paused),
          icon: const Icon(Icons.pause),
        ),
        IconButton(
          onPressed: currentValue == SimulationState.notRunning
              ? null
              : () => onChanged(SimulationState.notRunning),
          icon: const Icon(Icons.stop),
        ),
      ],
    );
  }
}
