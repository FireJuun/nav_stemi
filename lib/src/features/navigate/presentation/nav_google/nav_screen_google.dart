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

class NavScreenGoogle extends ConsumerStatefulWidget {
  const NavScreenGoogle({super.key});

  @override
  ConsumerState<NavScreenGoogle> createState() => _NavScreenGoogleState();
}

class _NavScreenGoogleState extends ConsumerState<NavScreenGoogle> {
  bool _showSteps = false;
  bool _showNextTurn = true;
  bool _isNavigating = false;
  bool _isSimulatingRoute = false;

  /// Speed multiplier used for simulation.
  static const double simulationSpeedMultiplier = 5;

  @override
  void initState() {
    super.initState();
    // ref.read(googleNavigationServiceProvider).initialize();
  }

  @override
  void dispose() {
    ref.read(googleNavigationServiceProvider).cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lastKnownOrCurrentPositionValue =
        ref.watch(getLastKnownOrCurrentPositionProvider);

    return Column(
      children: [
        Expanded(
          child: AsyncValueWidget<Position>(
            value: lastKnownOrCurrentPositionValue,
            data: (initialPosition) => GoogleMapsNavigationView(
              onViewCreated: ref
                  .read(navScreenGoogleControllerProvider.notifier)
                  .onViewCreated,
              initialCameraPosition: CameraPosition(
                target: initialPosition.toLatLng(),
                zoom: 14,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_isNavigating)
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(googleNavigationRepositoryProvider)
                          .clearDestinations();

                      setState(() {
                        _isNavigating = false;
                      });
                    },
                    child: const Text('STOP Navigation'),
                  )
                else
                  FilledButton(
                    onPressed: () {
                      // final activeEd = widget.destinations.activeEd;
                      // if (activeEd != null) {
                      //   ref.read(routeServiceProvider).goToEd(
                      //         activeEd: activeEd,
                      //         nearbyEds: widget.destinations.nearbyEds,
                      //       );
                      // }
                      // setState(() {
                      //   _isNavigating = true;
                      // });
                    },
                    child: const Text('Navigate'),
                  ),
                if (_isSimulatingRoute)
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(googleNavigationRepositoryProvider)
                          .stopSimulation();

                      setState(() {
                        _isSimulatingRoute = false;
                      });
                    },
                    child: const Text('STOP Simulation'),
                  )
                else
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(googleNavigationRepositoryProvider)
                          .simulateLocationsAlongExistingRouteWithOptions(
                            SimulationOptions(
                              speedMultiplier: simulationSpeedMultiplier,
                            ),
                          );

                      setState(() {
                        _isSimulatingRoute = true;
                      });
                    },
                    child: const Text('START Simulation'),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    // TODO(FireJuun): reimplement
    return KeyboardVisibilityBuilder(
      builder: (context, isKeyboardVisible) {
        final colorScheme = Theme.of(context).colorScheme;

        bool shouldShowSteps() => _showSteps && !isKeyboardVisible;
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
                )
                ..listen(
                  activeRouteProvider,
                  (_, state) => state.showAlertDialogOnError(context),
                )
                ..listen(
                  availableRoutesProvider,
                  (_, state) => state.showAlertDialogOnError(context),
                );

              final availableRoutesValue = ref.watch(availableRoutesProvider);

              return AsyncValueWidget<AvailableRoutes?>(
                value: availableRoutesValue,
                data: (availableRoutes) {
                  final activeRouteValue = ref.watch(activeRouteProvider);

                  return AsyncValueWidget<ActiveRoute?>(
                    value: activeRouteValue,
                    data: (activeRoute) {
                      final state =
                          ref.watch(navScreenGoogleControllerProvider);

                      if (activeRoute == null || availableRoutes == null) {
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
                                availableRoutes: availableRoutes,
                                activeRoute: activeRoute,
                              ),
                              gapH4,
                              Expanded(
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    // const NavScreenGoogleMap(),
                                    AnimatedSwitcher(
                                      duration: 300.ms,

                                      /// required due to this bug: https://github.com/flutter/flutter/issues/121336#issuecomment-1482620874
                                      transitionBuilder: (child, animation) =>
                                          FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                      child: _showNextTurn
                                          ? Align(
                                              alignment: Alignment.topCenter,
                                              child: NextStep(
                                                routeLegStep: activeRoute.route
                                                    .routeStepById(
                                                  activeRoute.activeStepId,
                                                )!,
                                                onTap: () => setState(
                                                  () => _showNextTurn = false,
                                                ),
                                              ),
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
                                                label:
                                                    Text('Next Step'.hardcoded),
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
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .height *
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
                                  ],
                                ),
                              ),
                              gapH8,
                              if (state.isLoading)
                                const Padding(
                                  padding: EdgeInsets.all(Sizes.p8),
                                  child: LinearProgressIndicator(),
                                )
                              else
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    PrimaryToggleButton(
                                      text: 'All Steps'.hardcoded,
                                      onPressed: () => setState(
                                        () => _showSteps = !_showSteps,
                                      ),
                                      isActive: shouldShowSteps(),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // IconButton(
                                        //   icon: const Icon(Icons.alt_route),
                                        //   tooltip: 'Other Routes'.hardcoded,
                                        //   onPressed: () {
                                        //     // `TODO`(FireJuun): Query Other Routes Dialog
                                        //   },
                                        // ),
                                        IconButton(
                                          icon: const Icon(Icons.moving),
                                          tooltip:
                                              'Show Entire Route'.hardcoded,
                                          onPressed: () => ref
                                              .read(
                                                navScreenGoogleControllerProvider
                                                    .notifier,
                                              )
                                              .zoomToActiveRoute(),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.my_location),
                                          tooltip: 'My Location'.hardcoded,
                                          onPressed: () => ref
                                              .read(
                                                navScreenGoogleControllerProvider
                                                    .notifier,
                                              )
                                              .showCurrentLocation(),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.remove),
                                          tooltip: 'Zoom Out'.hardcoded,
                                          onPressed: () => ref
                                              .read(
                                                navScreenGoogleControllerProvider
                                                    .notifier,
                                              )
                                              .zoomOut(),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add),
                                          tooltip: 'Zoom In'.hardcoded,
                                          onPressed: () => ref
                                              .read(
                                                navScreenGoogleControllerProvider
                                                    .notifier,
                                              )
                                              .zoomIn(),
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
              );
            },
          ),
        );
      },
    );
  }
}
