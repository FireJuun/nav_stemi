import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientEntryGender extends ConsumerWidget {
  const PatientEntryGender({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return AsyncValueWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        return Column(
          children: [
            Text('Sex at Birth'.hardcoded, textAlign: TextAlign.center),
            gapH4,
            SegmentedButton<SexAtBirth?>(
              selected: {patientInfoModel?.sexAtBirth},
              showSelectedIcon: false,
              emptySelectionAllowed: true,
              onSelectionChanged: (sexAtBirthList) {
                final newSexAtBirth = sexAtBirthList.firstOrNull;
                ref
                    .read(patientInfoControllerProvider.notifier)
                    .setSexAtBirth(newSexAtBirth);
              },
              segments: SexAtBirth.values
                  .map(
                    (sexAtBirth) => ButtonSegment<SexAtBirth?>(
                      value: sexAtBirth,
                      label: Text(sexAtBirth.name),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
