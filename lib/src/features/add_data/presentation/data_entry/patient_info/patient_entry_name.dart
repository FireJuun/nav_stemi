import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientEntryName extends ConsumerWidget {
  const PatientEntryName({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return AsyncValueWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        return Column(
          spacing: Sizes.p16,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PatientEntryText(
              label: 'First Name'.hardcoded,
              initialValue: patientInfoModel?.firstName,
              onChanged: (value) => ref
                  .read(patientInfoControllerProvider.notifier)
                  .setFirstName(value),
            ),

            PatientEntryText(
              label: 'Middle Name'.hardcoded,
              initialValue: patientInfoModel?.middleName,
              onChanged: (value) => ref
                  .read(patientInfoControllerProvider.notifier)
                  .setMiddleName(value),
            ),
            PatientEntryText(
              label: 'Last Name'.hardcoded,
              initialValue: patientInfoModel?.lastName,
              onChanged: (value) => ref
                  .read(patientInfoControllerProvider.notifier)
                  .setLastName(value),
            ),
          ],
        );
      },
    );
  }
}
