import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class DataEntryWidget extends ConsumerWidget {
  const DataEntryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<PatientInfoModel?>>(
      patientInfoModelProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return CustomScrollView(
      slivers: [
        const TimeMetrics(),
        AsyncValueSliverWidget(
          value: patientInfoModelValue,
          data: (patientInfoModel) {
            return PatientInfo(
              // TODO(FireJuun): should we handle null patientInfoModel here? or somewhere else
              patientInfoModel: patientInfoModel ?? const PatientInfoModel(),
            );
          },
        ),
        const CareTeam(),
      ],
    );
  }
}
