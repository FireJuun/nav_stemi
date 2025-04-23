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
          children: [
            Row(
              children: [
                Expanded(
                  child: PatientEntryText(
                    label: 'First Name'.hardcoded,
                    initialValue: patientInfoModel?.firstName,
                    onChanged: (value) => ref
                        .read(patientInfoControllerProvider.notifier)
                        .setFirstName(value),
                  ),
                ),
                gapW16,
                Expanded(
                  child: PatientEntryText(
                    label: 'Middle Name'.hardcoded,
                    initialValue: patientInfoModel?.middleName,
                    onChanged: (value) => ref
                        .read(patientInfoControllerProvider.notifier)
                        .setMiddleName(value),
                  ),
                ),
              ],
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: PatientEntryText(
                      label: 'Last Name'.hardcoded,
                      initialValue: patientInfoModel?.lastName,
                      onChanged: (value) => ref
                          .read(patientInfoControllerProvider.notifier)
                          .setLastName(value),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
