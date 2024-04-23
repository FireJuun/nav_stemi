import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:sliver_tools/sliver_tools.dart';

class Checklist extends StatelessWidget {
  const Checklist({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: CustomScrollView(
        slivers: [
          SliverPinnedHeader(
            child: Container(
              color: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Center(
                child: Text(
                  'Checklist'.hardcoded,
                  style: textTheme.bodyLarge
                      ?.apply(color: colorScheme.onSecondary),
                ),
              ),
            ),
          ),
          SliverCrossAxisGroup(
            slivers: [
              Consumer(
                builder: (context, ref, child) {
                  final timeMetricsModelValue =
                      ref.watch(timeMetricsModelProvider);

                  return AsyncValueSliverWidget<TimeMetricsModel?>(
                    value: timeMetricsModelValue,
                    data: (timeMetricsModel) {
                      return SliverCrossAxisExpanded(
                        flex: 1,
                        sliver: SliverList.list(
                          children: [
                            ChecklistItem(
                              label: 'EKG by 5 min'.hardcoded,
                              selectionOverride: () =>
                                  timeMetricsModel?.hasEkgByFiveMin(),
                            ),
                            ChecklistItem(
                              label: 'Leave by 10 min'.hardcoded,
                              selectionOverride: () =>
                                  timeMetricsModel?.hasLeftByTenMin(),
                            ),
                            const Divider(thickness: 2),
                            ChecklistItem(label: 'Give Aspirin 325'.hardcoded),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              Consumer(
                builder: (context, ref, child) {
                  final patientInfoModelValue =
                      ref.watch(patientInfoModelProvider);

                  return AsyncValueSliverWidget(
                    value: patientInfoModelValue,
                    data: (patientInfoModel) {
                      final hasPatientInfo =
                          patientInfoModel?.hasPatientInfo() ?? false;
                      final hasCardiologist =
                          patientInfoModel?.hasCardiologistInfo() ?? false;

                      return SliverCrossAxisExpanded(
                        flex: 1,
                        sliver: SliverList.list(
                          children: [
                            ChecklistItem(
                              label: 'Pt Info'.hardcoded,
                              selectionOverride: () => hasPatientInfo,
                            ),
                            ChecklistItem(
                              label: 'Pt Cardiologist'.hardcoded,
                              selectionOverride: () => hasCardiologist,
                            ),
                            const Divider(thickness: 2),
                            ChecklistItem(label: 'Notify Cath Lab'.hardcoded),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChecklistItem extends StatefulWidget {
  const ChecklistItem({
    required this.label,
    this.selectionOverride,
    super.key,
  });

  final String label;
  final ValueGetter<bool?>? selectionOverride;

  @override
  State<ChecklistItem> createState() => _ChecklistItemState();
}

class _ChecklistItemState extends State<ChecklistItem> {
  bool? _isSelected = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final selectionOverride = widget.selectionOverride;
    final isSelected =
        selectionOverride != null ? selectionOverride.call() : _isSelected;

    return CheckboxListTile(
      value: isSelected,
      tristate: true,
      enabled: selectionOverride == null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (newValue) {
        setState(() {
          _isSelected = newValue;
        });
      },
      title: Text(
        widget.label,
        style: textTheme.bodySmall?.apply(
          decoration: switch (isSelected) {
            true => TextDecoration.lineThrough,
            false => null,
            null => TextDecoration.lineThrough,
          },
          color: switch (isSelected) {
            true => colorScheme.outline,
            false => colorScheme.onBackground,
            null => colorScheme.error,
          },
        ),
      ),
    );
  }
}
