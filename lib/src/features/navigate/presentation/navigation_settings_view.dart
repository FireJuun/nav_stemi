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
                onSelectionChanged: (selections) {
                  assert(selections.length == 1, 'Only one selection allowed');
                  ref
                      .read(navigationSettingsViewControllerProvider.notifier)
                      .setAudioGuidanceType(value: selections.first);
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
            NavSimulationSlider(
              initialValue: navigationSettings.simulationSpeedMultiplier,
              onChanged: (value) => ref
                  .read(navigationSettingsViewControllerProvider.notifier)
                  .setSimulationSpeedMultiplier(value: value),
            ),
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
      title: Text('Simulation Speed Multiplier'.hardcoded),
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
