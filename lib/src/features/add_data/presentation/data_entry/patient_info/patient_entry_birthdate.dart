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

// TODO(FireJuun): move all of this business logic out of the UI

/// Date formats used to try and parse the birth date
/// from a given string entered by the user
final _dateFormats = [DateFormat('MM/dd/yyyy')];

// More flexible date formatter that allows both single and double digit months/days
final _birthDateFormatter = MaskTextInputFormatter(
  mask: '##/##/####',
  filter: {'#': RegExp('[0-9]')},
);

class PatientEntryBirthdate extends ConsumerStatefulWidget {
  const PatientEntryBirthdate({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PatientEntryBirthdateState();
}

class _PatientEntryBirthdateState extends ConsumerState<PatientEntryBirthdate> {
  late final TextEditingController _birthDateController = TextEditingController(
    text: ref.read(patientBirthDateProvider)?.toBirthDateString(),
  );

  /// Used for BirthDate validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final birthDate = ref.watch(patientBirthDateProvider);

    return Form(
      key: _formKey,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: BirthDateEntryText(
              birthDateController: _birthDateController,
              onChanged: (value) {
                if (value == null && birthDate == null) {
                  return; // No change needed
                }
                if (value != null && value.length < 10) {
                  ref
                      .read(patientInfoControllerProvider.notifier)
                      .setBirthDate(null);
                  // Not a complete date yet, birthdate should be clear
                  return;
                }
                // If we have a complete date (10 chars), validate and parse it
                final isValidDate = _formKey.currentState?.validate() ?? false;

                if (!isValidDate) {
                  return; // Invalid date, do not update
                }

                // Handle different input formats:
                // 1. Empty string = null date
                // 2. Formatted date string (MM/DD/YYYY)
                // 3. Full DateTime string from date picker
                DateTime? newBirthDate;

                if (value == null || value.isEmpty) {
                  newBirthDate = null;
                } else if (value.contains('/')) {
                  // Try to parse MM/DD/YYYY format
                  newBirthDate = _birthDateToStringDTO.tryParse(
                    value,
                    formats: _dateFormats,
                  );
                } else {
                  // Try to parse a full DateTime string
                  // (from picker or previous state)
                  newBirthDate = DateTime.tryParse(value);
                }

                ref
                    .read(patientInfoControllerProvider.notifier)
                    .setBirthDate(newBirthDate);
              },
              prefixIcon: IconButton(
                icon: const Icon(Icons.date_range),
                onPressed: () async {
                  final now = DateTime.now();

                  // Try to use the current value as the initial date if available
                  final initialDate =
                      birthDate ?? now.subtract(_goBackDuration);

                  // Show date picker with better initial values
                  final newBirthDate = await showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: initialDate,
                    lastDate: now,
                  );
                  if (newBirthDate == null) {
                    return;
                  }

                  setState(() {
                    // Update the text field with the selected date
                    _birthDateController.text =
                        DateFormat('MM/dd/yyyy').format(newBirthDate);

                    // Update the state with the new birth date
                    ref
                        .read(patientInfoControllerProvider.notifier)
                        .setBirthDate(newBirthDate);
                  });
                },
              ),
            ),
          ),
          gapW16,
          Expanded(
            child: Text(
              birthDate != null
                  ? '''Age:   ${birthDate.ageFromBirthDate()}'''
                  : '',
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class BirthDateEntryText extends StatelessWidget {
  const BirthDateEntryText({
    required this.birthDateController,
    required this.onChanged,
    this.prefixIcon,
    this.readOnly = false,
    super.key,
  });

  final TextEditingController? birthDateController;
  final FormFieldSetter<String> onChanged;
  final Widget? prefixIcon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: birthDateController,
      validator: (value) {
        /// only accepts MM/DD/YYYY format
        /// 10 characters long
        if (value == null || value.isEmpty || value.length != 10) {
          return null;
        }

        // if (value.length != 10) {
        // TODO(FireJuun): only show this when you click away
        //   return 'Some error message';
        // }

        /// Date formats used to parse the birth date
        /// from a string entered by the user
        final newBirthDate =
            _birthDateToStringDTO.tryParse(value, formats: _dateFormats);
        if (newBirthDate == null) {
          return 'Invalid date format';
        }

        if (newBirthDate.isAfter(DateTime.now())) {
          return "Can't be in the future";
        } else if (newBirthDate.isBefore(
          DateTime.now().subtract(_oldestAgeDuration),
        )) {
          return 'Age too old';
        }

        return null;
      },
      // Don't auto-format during typing to avoid cursor jumping and text loss
      onChanged: (value) {
        // When field is emptied, pass null to clear the date
        if (value.isEmpty || value.length < 10) {
          onChanged(null);
          return;
        }

        // If we have a complete date (10 chars), validate and parse it
        if (value.length == 10) {
          final newBirthDate = _birthDateToStringDTO.tryParse(
            value,
            formats: _dateFormats,
          );

          if (newBirthDate != null) {
            // Pass the actual DateTime value
            onChanged(newBirthDate.toString());
          } else {
            // Pass raw text if we couldn't parse it
            onChanged(value);
          }
        } else {
          // Still pass the raw text even if invalid
          onChanged(value);
        }
      },
      inputFormatters: [_birthDateFormatter],
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        filled: !readOnly,
        hintText: 'MM/DD/YYYY'.hardcoded,
        label: Text('Date of Birth'.hardcoded, textAlign: TextAlign.center),
      ),
      readOnly: readOnly,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
