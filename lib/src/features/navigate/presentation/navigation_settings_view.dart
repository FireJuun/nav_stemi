import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class NavigationSettingsView extends ConsumerWidget {
  const NavigationSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navigationSettingsValue =
        ref.watch(navigationSettingsChangesProvider);
    ref.watch(navigationSettingsViewControllerProvider);

    return AsyncValueWidget(
      value: navigationSettingsValue,
      data: (navigationSettings) {
        final textTheme = Theme.of(context).textTheme;
        final colorScheme = Theme.of(context).colorScheme;

        final textColor = colorScheme.secondary;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Navigation Settings'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            gapH8,

            /// Show North Up
            SwitchListTile(
              title: Text('Show North Up'.hardcoded),
              value: navigationSettings.showNorthUp,
              onChanged: (value) => ref
                  .read(navigationSettingsViewControllerProvider.notifier)
                  .setShowNorthUp(value: value),
            ),

            /// Audio Guidance Type
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('Audio Guidance'.hardcoded),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SegmentedButton<AudioGuidanceType>(
                segments: AudioGuidanceType.values
                    .map(
                      (e) => ButtonSegment<AudioGuidanceType>(
                        value: e,
                        label: Text(
                          e.shortName().hardcoded,
                          textAlign: TextAlign.center,
                        ),
                        tooltip: e.shortName().hardcoded,
                      ),
                    )
                    .toList(),
                selected: {navigationSettings.audioGuidanceType},
                showSelectedIcon: false,
                onSelectionChanged: (selections) {
                  assert(selections.length == 1, 'Only one selection allowed');
                  final newValue = selections.first;

                  if (ref.exists(navScreenGoogleControllerProvider)) {
                    /// Only set the audio guidance type if the map
                    /// is already loaded / running.
                    ///
                    /// This state is exclusive with NavScreenGoogleController
                    ref
                        .read(navScreenGoogleControllerProvider.notifier)
                        .setAudioGuidanceType(newValue);
                  } else {
                    /// Otherwise, just save it as a local preference
                    ref
                        .read(navigationSettingsViewControllerProvider.notifier)
                        .setAudioGuidanceType(value: newValue);
                  }
                },
              ),
            ),

            /// Simulator Settings
            const Divider(),
            Text(
              'Simulator Settings'.hardcoded,
              style: textTheme.titleMedium?.apply(color: textColor),
            ),
            gapH8,
            SwitchListTile(
              title: Text('Simulate Location'.hardcoded),
              value: navigationSettings.shouldSimulateLocation,
              onChanged: (value) => ref
                  .read(navigationSettingsViewControllerProvider.notifier)
                  .setShouldSimulateLocation(value: value),
            ),

            /// Simulation Speed Multiplier
            if (navigationSettings.shouldSimulateLocation)
              NavSimulationSlider(
                initialValue: navigationSettings.simulationSpeedMultiplier,
                onChanged: (value) => ref
                    .read(navigationSettingsViewControllerProvider.notifier)
                    .setSimulationSpeedMultiplier(value: value),
              ),
            if (navigationSettings.shouldSimulateLocation)
              const SimulationStartingLocationPicker(),
          ],
        );
      },
    );
  }
}

class NavSimulationSlider extends StatefulWidget {
  const NavSimulationSlider({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final double initialValue;
  final void Function(double) onChanged;

  @override
  State<NavSimulationSlider> createState() => _NavSimulationSliderState();
}

class _NavSimulationSliderState extends State<NavSimulationSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = _truncate(widget.initialValue);
  }

  void _updateValue(double newValue) {
    setState(() => _value = _truncate(newValue));
  }

  double _truncate(double value) => double.parse(value.toStringAsFixed(1));

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Simulation Driving\nSpeed Multiplier'.hardcoded),
      trailing: Text('$_value'),
      subtitle: Slider(
        value: _value,
        max: 5,
        divisions: 50,
        label: '$_value',
        onChanged: _updateValue,
        onChangeEnd: (newValue) => widget.onChanged(_truncate(newValue)),
      ),
    );
  }
}

class SimulationStartingLocationPicker extends ConsumerWidget {
  const SimulationStartingLocationPicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startingLocation = ref.watch(simulationStartingLocationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Simulation Starting Location'.hardcoded),
          ),
          gapH8,
          DropdownMenu<AppWaypoint?>(
            expandedInsets: EdgeInsets.zero,
            initialSelection: startingLocation,
            onSelected: (value) {
              if (value is AppWaypoint) {
                ref
                    .read(navigationSettingsRepositoryProvider)
                    .setSimulationStartingLocation(value: value);
                // ignore: avoid_print
                print('Selected: $value');
              }
            },
            dropdownMenuEntries: [
              ...simulationLocations
                  .map((e) => DropdownMenuEntry(value: e, label: e.label)),
              // TODO(FireJuun): implement ability to restart from last location
              /// or to include null values here
              // const DropdownMenuEntry(value: null, label: '--Last Location--'),
            ],
          ),
        ],
      ),
    );
  }
}
