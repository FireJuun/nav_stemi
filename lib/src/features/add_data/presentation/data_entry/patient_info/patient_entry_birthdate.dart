import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _goBackInYears = 60;
const _goBackDuration = Duration(days: _goBackInYears * 365);
const _oldestAgeInYears = 150;
const _oldestAgeDuration = Duration(days: _oldestAgeInYears * 365);
const _birthDateToStringDTO = BirthDateToStringDTO();

// Date formats used for parsing
final _dateFormats = [DateFormat('MM/dd/yyyy')];

// Mask formatter for date input
final _birthDateFormatter = MaskTextInputFormatter(
  mask: '##/##/####',
  filter: {'#': RegExp('[0-9]')},
);

class PatientEntryBirthdate extends ConsumerWidget {
  const PatientEntryBirthdate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientInfoModelValue = ref.watch(patientInfoModelProvider);
    final patientBirthDate = ref.watch(patientBirthDateProvider);

    return AsyncValueWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: PatientEntryText(
                label: 'Date of Birth'.hardcoded,
                initialValue: patientBirthDate?.toBirthDateString() ?? '',
                keyboardType: TextInputType.phone,
                inputFormatters: [_birthDateFormatter],
                prefixIcon: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: () async {
                    final now = DateTime.now();
                    final initialDate =
                        patientBirthDate ?? now.subtract(_goBackDuration);

                    final newDate = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900),
                      initialDate: initialDate,
                      lastDate: now,
                    );

                    if (newDate != null) {
                      ref
                          .read(patientInfoControllerProvider.notifier)
                          .setBirthDate(newDate);
                    }
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return null;
                  }

                  if (value.length < 10) {
                    return 'Enter complete date';
                  }

                  final date = _birthDateToStringDTO.tryParse(
                    value,
                    formats: _dateFormats,
                  );

                  if (date == null) {
                    return 'Invalid date format';
                  }

                  if (date.isAfter(DateTime.now())) {
                    return "Can't be in the future";
                  }

                  if (date
                      .isBefore(DateTime.now().subtract(_oldestAgeDuration))) {
                    return 'Age too old';
                  }

                  return null;
                },
                onChanged: (value) {
                  if (value == null || value.isEmpty) {
                    ref
                        .read(patientInfoControllerProvider.notifier)
                        .setBirthDate(null);
                    return;
                  }

                  // Only update the model with complete, valid dates
                  if (value.length == 10) {
                    final date = _birthDateToStringDTO.tryParse(
                      value,
                      formats: _dateFormats,
                    );

                    if (date != null) {
                      ref
                          .read(patientInfoControllerProvider.notifier)
                          .setBirthDate(date);
                    }
                  }
                },
              ),
            ),
            gapW16,
            Expanded(
              child: Text(
                patientBirthDate != null
                    ? 'Age:   ${patientBirthDate.ageFromBirthDate()}'
                    : '',
                textAlign: TextAlign.end,
              ),
            ),
          ],
        );
      },
    );
  }
}
