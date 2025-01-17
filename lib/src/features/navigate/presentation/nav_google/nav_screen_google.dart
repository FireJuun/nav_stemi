import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_navigation_flutter/google_navigation_flutter.dart';
import 'package:nav_stemi/nav_stemi.dart';

// TODO(FireJuun): Readjust location of these values
const _showNarration = false;

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

  /// Audio guidance settings
  bool _showAudioGuidance = false;

  /// Simulation settings
  bool _showSimulationControls = false;
  SimulationState _simulationState = SimulationState.running;

  void _dismissMenus() {
    setState(() {
      _showSteps = false;
      // _showNextTurn = false;
      _showAudioGuidance = false;
      _showSimulationControls = false;
    });
  }

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
                                      onMapLongClicked: (_) => _dismissMenus(),
                                      onMapClicked: (_) => _dismissMenus(),
                                    );
                                  },
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
                                      onChanged: (guidanceType) {
                                        setState(
                                          () {
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
                                  Consumer(
                                    builder: (context, ref, child) {
                                      final audioGuidanceType =
                                          ref.watch(audioGuidanceTypeProvider);

                                      return IconButton(
                                        icon: switch (audioGuidanceType) {
                                          AudioGuidanceType.alertsAndGuidance =>
                                            const Icon(Icons.volume_up),
                                          AudioGuidanceType.alertsOnly =>
                                            const Icon(
                                              Icons
                                                  .notification_important_outlined,
                                            ),
                                          AudioGuidanceType.silent =>
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
                                      );
                                    },
                                  ),

                                  /// start, pause, stop navigation

                                  Consumer(
                                    builder: (context, ref, child) {
                                      final showSimulationControls = ref.watch(
                                        shouldSimulateLocationProvider,
                                      );

                                      return (!showSimulationControls)
                                          ? const SizedBox()
                                          : IconButton(
                                              icon: switch (_simulationState) {
                                                SimulationState.running =>
                                                  const Icon(Icons.play_arrow),
                                                SimulationState.paused =>
                                                  const Icon(
                                                    Icons.pause,
                                                  ),
                                                SimulationState.notRunning =>
                                                  const Icon(Icons.stop),
                                              },
                                              isSelected:
                                                  _showSimulationControls,
                                              tooltip:
                                                  'Navigation State'.hardcoded,
                                              onPressed: () {
                                                setState(() {
                                                  _showSimulationControls =
                                                      !_showSimulationControls;
                                                });
                                              },
                                            );
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

class AudioGuidancePicker extends ConsumerWidget {
  const AudioGuidancePicker({
    required this.onChanged,
    super.key,
  });

  final ValueChanged<AudioGuidanceType> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentValue = ref.watch(audioGuidanceTypeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: currentValue == AudioGuidanceType.alertsAndGuidance
              ? null
              : () => onChanged(AudioGuidanceType.alertsAndGuidance),
          icon: const Icon(Icons.volume_up),
        ),
        IconButton(
          onPressed: currentValue == AudioGuidanceType.alertsOnly
              ? null
              : () => onChanged(AudioGuidanceType.alertsOnly),
          icon: const Icon(Icons.notification_important_outlined),
        ),
        IconButton(
          onPressed: currentValue == AudioGuidanceType.silent
              ? null
              : () => onChanged(AudioGuidanceType.silent),
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
        // TODO(FireJuun): reimplement ability to stop navigation?
        /// is this ever needed?
        // IconButton(
        //   onPressed: currentValue == SimulationState.notRunning
        //       ? null
        //       : () => onChanged(SimulationState.notRunning),
        //   icon: const Icon(Icons.stop),
        // ),
      ],
    );
  }
}
