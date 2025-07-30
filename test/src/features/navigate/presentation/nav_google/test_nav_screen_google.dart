import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:nav_stemi/nav_stemi.dart';

// Test version of NavScreenGoogle that uses a mock map widget
class TestNavScreenGoogle extends StatefulWidget {
  const TestNavScreenGoogle({required this.initialPosition, super.key});

  final Position initialPosition;

  @override
  State<TestNavScreenGoogle> createState() => _TestNavScreenGoogleState();
}

class _TestNavScreenGoogleState extends State<TestNavScreenGoogle> {
  bool _showSteps = false;
  bool _showAudioGuidance = false;
  bool _showSimulationControls = false;
  SimulationState _simulationState = SimulationState.running;

  void _dismissMenus() {
    setState(() {
      _showSteps = false;
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
                          NearestHospitalSelector(
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

                                    // Use a mock map widget instead of GoogleMapsNavigationView
                                    return GestureDetector(
                                      onTap: _dismissMenus,
                                      onLongPress: _dismissMenus,
                                      child: ColoredBox(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Text('Mock Google Maps'),
                                        ),
                                      ),
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
                                    child: shouldShowAudioGuidance()
                                        ? AudioGuidancePicker(
                                            onChanged: (audioGuidanceType) {
                                              notifier().setAudioGuidanceType(
                                                audioGuidanceType,
                                              );
                                            },
                                          )
                                        : null,
                                  ),
                                ),
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
                                    child: shouldShowSimulationControls()
                                        ? SimulationStatePicker(
                                            currentValue: _simulationState,
                                            onChanged: (simulationState) {
                                              setState(() {
                                                _simulationState =
                                                    simulationState;
                                              });
                                              notifier().setSimulationState(
                                                simulationState,
                                              );
                                            },
                                          )
                                        : null,
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
                          gapH8,
                        ],
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
