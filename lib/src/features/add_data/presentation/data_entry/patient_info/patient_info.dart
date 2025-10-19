import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

class PatientInfo extends ConsumerWidget {
  const PatientInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..listen<AsyncValue<void>>(
        patientInfoControllerProvider,
        (_, state) => state.showAlertDialogOnError(context),
      )
      ..listen<AsyncValue<PatientInfoModel?>>(
        patientInfoModelProvider,
        (_, state) => state.showAlertDialogOnError(context),
      );

    final state = ref.watch(patientInfoControllerProvider);

    if (state is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: PatientInfoData(),
    );
  }
}

class PatientInfoData extends StatefulWidget {
  const PatientInfoData({super.key});

  @override
  State<StatefulWidget> createState() => _PatientInfoDataState();
}

class _PatientInfoDataState extends State<PatientInfoData> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SliverList.list(
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Consumer(
                  builder: (context, ref, child) {
                    return FilledButton(
                      onPressed: () {
                        showDialog<bool>(
                          context: context,
                          builder: (context) => ScanQrLicenseDialog(
                            onDataSubmitted: (patientInfoModel) => ref
                                .read(patientInfoControllerProvider.notifier)
                                .setPatientInfoModel(patientInfoModel),
                          ),
                        );
                      },
                      child: Text("Scan Driver's License".hardcoded),
                    );
                  },
                ),
              ),
              gapH8,
              const Divider(thickness: 4),
              gapH16,
              const PatientEntryName(),
              gapH32,
              const PatientEntryBirthdate(),
              gapH16,
              const PatientEntryGender(),
              gapH16,
              const Divider(thickness: 4),
              gapH16,
              const PatientEntryCardiologist(),
            ],
          ),
        ),
      ],
    );
  }
}
