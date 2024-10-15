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
                  'STEMI Checklist'.hardcoded,
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
                      final hasEkgByFiveMin = timeMetricsModel == null
                          ? () => false
                          : timeMetricsModel.hasEkgByFiveMin;

                      final hasLeftByTenMin = timeMetricsModel == null
                          ? () => false
                          : timeMetricsModel.hasLeftByTenMin;

                      return SliverCrossAxisExpanded(
                        flex: 1,
                        sliver: SliverList.list(
                          children: [
                            ChecklistItem(
                              label: 'EKG by 5 min'.hardcoded,
                              isSelected: hasEkgByFiveMin,
                            ),
                            ChecklistItem(
                              label: 'Leave by 10 min'.hardcoded,
                              isSelected: hasLeftByTenMin,
                            ),
                            const Divider(thickness: 2),
                            Consumer(
                              builder: (context, ref, child) {
                                final patientInfoModelValue =
                                    ref.watch(patientInfoModelProvider);

                                return AsyncValueWidget(
                                  value: patientInfoModelValue,
                                  data: (patientInfoModel) {
                                    final hasAspirinInfo = patientInfoModel
                                        ?.aspirinInfoChecklistState();

                                    return ChecklistItem(
                                      label: 'Give Aspirin 325'.hardcoded,
                                      isSelected: () => hasAspirinInfo,
                                      onChanged: (checklist) => ref
                                          .read(
                                            checklistControllerProvider
                                                .notifier,
                                          )
                                          .setDidGetAspirinFromChecklist(
                                            checklist: checklist,
                                          ),
                                    );
                                  },
                                );
                              },
                            ),
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
                          patientInfoModel?.patientInfoChecklistState();
                      final hasCardiologist =
                          patientInfoModel?.cardiologistInfoChecklistState();
                      final hasCathLabInfo =
                          patientInfoModel?.cathLabInfoChecklistState();

                      return SliverCrossAxisExpanded(
                        flex: 1,
                        sliver: SliverList.list(
                          children: [
                            ChecklistItem(
                              label: 'Pt Info'.hardcoded,
                              isSelected: () => hasPatientInfo,
                            ),
                            ChecklistItem(
                              label: 'Pt Cardiologist'.hardcoded,
                              isSelected: () => hasCardiologist,
                            ),
                            const Divider(thickness: 2),
                            ChecklistItem(
                              label: 'Notify Cath Lab'.hardcoded,
                              isSelected: () => hasCathLabInfo,
                              onChanged: (checklist) => ref
                                  .read(checklistControllerProvider.notifier)
                                  .setIsCathLabNotifiedFromChecklist(
                                    checklist: checklist,
                                  ),
                            ),
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

class ChecklistItem extends StatelessWidget {
  const ChecklistItem({
    required this.label,
    this.isSelected,
    this.onChanged,
    super.key,
  });

  final String label;
  final ValueGetter<bool?>? isSelected;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isSelectedWithOverride = isSelected?.call();

    return CheckboxListTile(
      value: isSelectedWithOverride,
      tristate: true,
      enabled: onChanged != null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 2),
      visualDensity: VisualDensity.compact,
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: onChanged,
      title: Text(
        label,
        style: textTheme.bodySmall?.apply(
          decoration: switch (isSelectedWithOverride) {
            true => TextDecoration.lineThrough,
            false => null,
            null => TextDecoration.lineThrough,
          },
          color: switch (isSelectedWithOverride) {
            true => colorScheme.outline,
            false => colorScheme.onSurface,
            null => colorScheme.error,
          },
        ),
      ),
    );
  }
}
