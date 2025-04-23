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
              // gapH4,
              const Divider(thickness: 4),
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
              // gapH4,
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
    final sexAtBirth = patientInfo.sexAtBirth;

    return ListView(
      children: [
        gapH12,
        Row(
          children: [
            Expanded(
              child: PatientEntryText(
                readOnly: true,
                label: 'First Name'.hardcoded,
                onChanged: (_) {},
                initialValue: patientInfo.firstName,
              ),
            ),
            gapW16,
            Expanded(
              child: PatientEntryText(
                readOnly: true,
                label: 'Middle Name'.hardcoded,
                onChanged: (_) {},
                initialValue: patientInfo.middleName,
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
                  readOnly: true,
                  label: 'Last Name'.hardcoded,
                  onChanged: (_) {},
                  initialValue: patientInfo.lastName,
                ),
              ),
            ),
          ],
        ),
        gapH16,
        Row(
          children: [
            Expanded(
              child: PatientEntryText(
                readOnly: true,
                label: 'Date of Birth'.hardcoded,
                onChanged: (_) {},
                initialValue: birthDate?.toBirthDateString(),
              ),
            ),
            gapW32,
            Expanded(
              child: Text(
                birthDate != null
                    ? 'Age:   ${birthDate.ageFromBirthDate()}'
                    : '',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        gapH16,
        Text('Sex at Birth'.hardcoded, textAlign: TextAlign.center),
        gapH4,
        SegmentedButton<SexAtBirth?>(
          selected: {sexAtBirth},
          emptySelectionAllowed: true,
          showSelectedIcon: false,
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
  }
}
