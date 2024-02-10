import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
          child: Consumer(
            builder: (context, ref, child) {
              ref.listen<AsyncValue<void>>(
                navScreenControllerProvider,
                (_, state) => state.showAlertDialogOnError(context),
              );

              final state = ref.watch(navScreenControllerProvider);
              return Stack(
                children: [
                  Column(
                    children: [
                      NearestEdSelector(
                        onTapNearestPciCenter: () async {
                          // TODO(FireJuun): handle tap for nearest pci
                          // final result =
                          //     await ActiveRouteRepository().getRoute();
                          // debugPrint('route result:\n${result.toJson()}');
                        },
                        onTapNearestEd: () async {
                          // TODO(FireJuun): handle tap for nearest ed
                          // final results =
                          //     await ActiveRouteRepository().getRouteMatrix();
                          // for (var i = 0; i < results.length; i++) {
                          //   final item = results[i].toJson();
                          //   debugPrint('route matrix result $i:\n$item');
                          // }
                          // debugPrint('all items found');
                        },
                      ),
                      gapH4,
                      Expanded(
                        child: Stack(
                          alignment: AlignmentDirectional.center,
                          children: [
                            GoogleMap(
                              initialCameraPosition: const CameraPosition(
                                target: locationRandolphEms,
                                zoom: 14,
                              ),
                              trafficEnabled: true,
                              myLocationButtonEnabled: false,
                              onMapCreated: (controller) => ref
                                  .read(navScreenControllerProvider.notifier)
                                  .onMapCreated(controller),
                              markers: ref.watch(markersProvider),
                              polylines: ref.watch(polylinesProvider),
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
                                  ? Align(
                                      alignment: Alignment.topCenter,
                                      child: TurnDirections(
                                        onTap: () => setState(
                                          () => _showNextTurn = false,
                                        ),
                                      ),
                                    )
                                  : Align(
                                      alignment: AlignmentDirectional.topStart,
                                      child: OutlinedButton.icon(
                                        style: Theme.of(context)
                                            .outlinedButtonTheme
                                            .style
                                            ?.copyWith(
                                              backgroundColor:
                                                  MaterialStatePropertyAll(
                                                colorScheme.background,
                                              ),
                                            ),
                                        icon: const Icon(Icons.expand_more),
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
                                    ? MediaQuery.of(context).size.height * 0.25
                                    : 0,
                                // TODO(FireJuun): directions go here
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  border: shouldShowSteps()
                                      ? Border.all(color: colorScheme.onSurface)
                                      : null,
                                ),
                                child:
                                    Center(child: Text('All Steps'.hardcoded)),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PrimaryToggleButton(
                              text: 'All Steps'.hardcoded,
                              onPressed: () =>
                                  setState(() => _showSteps = !_showSteps),
                              isActive: shouldShowSteps(),
                            ),
                            Row(
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
                                  onPressed: () => ref
                                      .watch(
                                        navScreenControllerProvider.notifier,
                                      )
                                      .showCurrentLocation(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.zoom_out),
                                  tooltip: 'Zoom Out'.hardcoded,
                                  onPressed: () => ref
                                      .read(
                                        navScreenControllerProvider.notifier,
                                      )
                                      .zoomOut(),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.zoom_in),
                                  tooltip: 'Zoom In'.hardcoded,
                                  onPressed: () => ref
                                      .read(
                                        navScreenControllerProvider.notifier,
                                      )
                                      .zoomIn(),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
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
          ),
        );
      },
    );
  }
}
