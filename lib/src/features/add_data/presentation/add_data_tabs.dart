import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class AddDataTabs extends StatelessWidget {
  const AddDataTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Text(
                'Time Metrics'.hardcoded,
                textAlign: TextAlign.center,
              ),
              Text(
                'Patient Info'.hardcoded,
                textAlign: TextAlign.center,
              ),
              Text(
                'Care Team'.hardcoded,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          Divider(color: colorScheme.primary),
          const Expanded(
            child: TabBarView(
              children: [
                DataEntryView(child: TimeMetrics()),
                DataEntryView(child: PatientInfoDataTab()),
                DataEntryView(child: CareTeam()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PatientInfoDataTab extends ConsumerWidget {
  const PatientInfoDataTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<PatientInfoModel?>>(
      patientInfoModelProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return AsyncValueSliverWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        // TODO(FireJuun): reimplement handling of null patientInfoModel
        // if (patientInfoModel == null) {
        //   return const SliverToBoxAdapter(
        //     child: Center(child: Text('No info available')),
        //   );
        // }
        return PatientInfo(
            patientInfoModel: patientInfoModel ?? const PatientInfoModel());
      },
    );
  }
}

class DataEntryView extends StatelessWidget {
  const DataEntryView({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [child],
    );
  }
}
