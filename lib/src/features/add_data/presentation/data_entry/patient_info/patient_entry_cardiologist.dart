import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientEntryCardiologist extends ConsumerWidget {
  const PatientEntryCardiologist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return AsyncValueWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        return PatientEntryText(
          label: "Patient's Cardiologist".hardcoded,
          initialValue: patientInfoModel?.cardiologist,
          onChanged: (value) => ref
              .read(patientInfoControllerProvider.notifier)
              .setCardiologist(value),
        );
      },
    );
  }
}
