import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nav_stemi/nav_stemi.dart';

class ScanQrAcceptData extends StatelessWidget {
  const ScanQrAcceptData({
    required this.scannedLicense,
    required this.onRescanLicense,
    required this.onDataSubmitted,
    super.key,
  });

  final DriverLicense? scannedLicense;
  final VoidCallback onRescanLicense;
  final void Function(PatientInfoModel) onDataSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ResponsiveDialogHeader(label: 'Import Patient Info?'.hardcoded),
        Expanded(
          child: Column(
            children: [
              FilledButton(
                onPressed: onRescanLicense,
                child: Text('Rescan License'.hardcoded),
              ),
              gapH8,
              const Divider(thickness: 4),
              gapH16,
              if (scannedLicense == null)
                Center(child: Text('No License Scanned'.hardcoded))
              else
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    child: ScannedLicenseInfo(scannedLicense!),
                  ),
                ),
            ],
          ),
        ),
        Consumer(
          builder: (context, ref, child) {
            return ResponsiveDialogFooter(
              includeAccept: true,
              onAccept: () {
                ref
                    .read(patientInfoControllerProvider.notifier)
                    .saveLicenseAsPatientInfo(scannedLicense!);
                onDataSubmitted(scannedLicense!.toPatientInfo());
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ],
    );
  }
}

class ScannedLicenseInfo extends StatelessWidget {
  const ScannedLicenseInfo(this.scannedLicense, {super.key});

  final DriverLicense scannedLicense;

  @override
  Widget build(BuildContext context) {
    final patientInfo = scannedLicense.toPatientInfo();
    final birthDate = patientInfo.birthDate;

    return ListView(
      children: [
        Row(
          children: [
            Expanded(
              child: PatientInfoTextField(
                readOnly: true,
                label: 'First Name'.hardcoded,
                controller: TextEditingController(text: patientInfo.firstName),
              ),
            ),
            gapW16,
            Expanded(
              child: PatientInfoTextField(
                readOnly: true,
                label: 'Middle Name'.hardcoded,
                controller: TextEditingController(text: patientInfo.middleName),
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
                child: PatientInfoTextField(
                  readOnly: true,
                  label: 'Last Name'.hardcoded,
                  controller: TextEditingController(text: patientInfo.lastName),
                ),
              ),
            ),
          ],
        ),
        gapH32,
        if (birthDate != null)
          Text(
            'Age: ${birthDate.ageFromBirthDate()}',
          ),
        gapH32,
        Row(
          children: [
            Expanded(
              child: PatientInfoTextField(
                readOnly: true,
                label: 'Date of Birth'.hardcoded,
                controller:
                    TextEditingController(text: birthDate?.toBirthDateString()),
              ),
            ),
            gapW32,
            Expanded(
              child: PatientInfoTextField(
                readOnly: true,
                label: 'Gender'.hardcoded,
                controller: TextEditingController(
                  text: patientInfo.gender,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
