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

/// Date formats used to try and parse the birth date
/// from a given string entered by the user
final _dateFormats = [DateFormat('MM/dd/yyyy')];

final _birthDateFormatter = MaskTextInputFormatter(
  mask: '##/##/####',
  filter: {'#': RegExp('[0-9]')},
  initialText: 'MM/DD/YYYY',
);

class PatientInfo extends ConsumerStatefulWidget {
  const PatientInfo({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientInfoState();
}

class _PatientInfoState extends ConsumerState<PatientInfo> {
  final _formKey = GlobalKey<FormState>();
  final _birthDateController = TextEditingController();

  PatientInfoModel _patientInfoModel = const PatientInfoModel();

  @override
  void dispose() {
    _birthDateController.dispose();
    super.dispose();
  }

  void _onFormDataChanged() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (isValid) {
      ref
          .read(patientInfoControllerProvider.notifier)
          .setPatientInfoModel(_patientInfoModel);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      patientInfoControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );

    final state = ref.watch(patientInfoControllerProvider);

    if (state is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final patientInfoModelValue = ref.watch(patientInfoModelProvider);

    return AsyncValueSliverWidget(
      value: patientInfoModelValue,
      data: (patientInfoModel) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_patientInfoModel != patientInfoModel &&
              patientInfoModel != null) {
            setState(() {
              _patientInfoModel = patientInfoModel;
              _birthDateController.text =
                  _patientInfoModel.birthDate?.toString() ?? '';
            });
          }
        });

        return SliverMainAxisGroup(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: Form(
                key: _formKey,
                onChanged: _onFormDataChanged,
                child: SliverList.list(
                  children: [
                    Center(
                      child: FilledButton(
                        onPressed: () {
                          showDialog<bool>(
                            context: context,
                            builder: (context) => ScanQrLicenseDialog(
                              onDataSubmitted: (patientInfoModel) {
                                setState(() {
                                  _patientInfoModel = patientInfoModel;

                                  /// using this instead of _updatePatientInfo
                                  /// so that cardiologist isn't overwritten
                                  _onFormDataChanged();
                                });
                              },
                            ),
                          );
                        },
                        child: Text("Scan Driver's License".hardcoded),
                      ),
                    ),
                    gapH8,
                    const Divider(thickness: 4),
                    gapH16,
                    Row(
                      children: [
                        Expanded(
                          child: PatientInfoTextField(
                            label: 'First Name'.hardcoded,
                            initialValue: _patientInfoModel.firstName,
                            onChanged: (value) {
                              setState(() {
                                _patientInfoModel = _patientInfoModel.copyWith(
                                  firstName: () => value,
                                );

                                /// These are called via `Form: onChanged`, but
                                /// some data fields need to be updated manually
                                // _onFormDataChanged();
                              });
                            },
                          ),
                        ),
                        gapW16,
                        Expanded(
                          child: PatientInfoTextField(
                            label: 'Middle Name'.hardcoded,
                            initialValue: _patientInfoModel.middleName,
                            onChanged: (value) {
                              setState(() {
                                _patientInfoModel = _patientInfoModel.copyWith(
                                  middleName: () => value,
                                );

                                /// These are called via `Form: onChanged`, but
                                /// some data fields need to be updated manually
                                // _onFormDataChanged();
                              });
                            },
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
                              label: 'Last Name'.hardcoded,
                              initialValue: _patientInfoModel.lastName,
                              onChanged: (value) {
                                setState(() {
                                  _patientInfoModel =
                                      _patientInfoModel.copyWith(
                                    lastName: () => value,
                                  );

                                  /// These are called via `Form: onChanged`, but
                                  /// some data fields need to be updated manually
                                  // _onFormDataChanged();
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    gapH32,
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: BirthDateInfo(
                            formKey: _formKey,
                            controller: _birthDateController,
                            onChanged: (value) {
                              final newBirthDate = (value == null)
                                  ? null
                                  : _birthDateToStringDTO.tryParse(
                                      value,
                                      formats: _dateFormats,
                                    );

                              setState(() {
                                _patientInfoModel = _patientInfoModel.copyWith(
                                  birthDate: () => newBirthDate,
                                );

                                _onFormDataChanged();
                              });
                            },
                            prefixIcon: IconButton(
                              icon: const Icon(Icons.date_range),
                              onPressed: () async {
                                final now = DateTime.now();

                                final newBirthDate = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime(1900),
                                  initialDate: now.subtract(_goBackDuration),
                                  initialDatePickerMode: DatePickerMode.year,
                                  lastDate: now,
                                );
                                if (newBirthDate == null) {
                                  return;
                                }

                                setState(() {
                                  _patientInfoModel =
                                      _patientInfoModel.copyWith(
                                    birthDate: () => newBirthDate,
                                  );

                                  _birthDateController.text =
                                      newBirthDate.toBirthDateString();

                                  _onFormDataChanged();
                                });
                              },
                            ),
                          ),
                        ),
                        gapW16,
                        Expanded(
                          child: Text(
                            _patientInfoModel.birthDate != null
                                ? '''Age:   ${_patientInfoModel.birthDate!.ageFromBirthDate()}'''
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
                      selected: {_patientInfoModel.sexAtBirth},
                      showSelectedIcon: false,
                      emptySelectionAllowed: true,
                      onSelectionChanged: (sexAtBirthList) {
                        /// For this SegmentedButton, _onFormDataChanged
                        /// Only works if updated manually
                        ///
                        final newSexAtBirth = sexAtBirthList.firstOrNull;

                        final newModel = _patientInfoModel.copyWith(
                          sexAtBirth: () => newSexAtBirth,
                        );

                        setState(() {
                          _patientInfoModel = newModel;

                          _onFormDataChanged();
                        });
                      },
                      segments: SexAtBirth.values
                          .map(
                            (sexAtBirth) => ButtonSegment<SexAtBirth?>(
                              value: sexAtBirth,
                              label: Text(sexAtBirth.name),
                            ),
                          )
                          .toList(),
                    ),
                    gapH16,
                    const Divider(thickness: 4),
                    gapH16,
                    PatientInfoTextField(
                      label: "Patient's Cardiologist".hardcoded,
                      initialValue: _patientInfoModel.cardiologist,
                      onChanged: (value) {
                        setState(() {
                          _patientInfoModel = _patientInfoModel.copyWith(
                            cardiologist: () => value,
                          );

                          /// These are called via `Form: onChanged`, but
                          /// some data fields need to be updated manually
                          // _onFormDataChanged();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class PatientInfoTextField extends StatefulWidget {
  const PatientInfoTextField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.prefixIcon,
    this.hint,
    this.keyboardType,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final String? initialValue;
  final FormFieldSetter<String>? onChanged;
  final Widget? prefixIcon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  State<PatientInfoTextField> createState() => _PatientInfoTextFieldState();
}

class _PatientInfoTextFieldState extends State<PatientInfoTextField> {
  late final TextEditingController _textEditingController =
      TextEditingController(text: widget.initialValue);

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _textEditingController,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        prefixIcon: widget.prefixIcon,
        filled: !widget.readOnly,
        hintText: widget.hint,
        label: Text(widget.label, textAlign: TextAlign.center),
      ),
      readOnly: widget.readOnly,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}

class BirthDateInfo extends StatelessWidget {
  const BirthDateInfo({
    required this.controller,
    required this.onChanged,
    required this.formKey,
    this.prefixIcon,
    this.readOnly = false,
    super.key,
  });

  final TextEditingController controller;
  final FormFieldSetter<String> onChanged;
  final GlobalKey<FormState> formKey;
  final Widget? prefixIcon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
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
      onChanged: (value) {
        /// For this TextField, _onFormDataChanged
        /// Only works if updated manually
        if (value.isEmpty || value.length != 10) {
          onChanged(value);
        } else if (value.length == 10) {
          // TODO(FireJuun): implement date saving, only if valid
          final isValidDate = formKey.currentState?.validate() ?? false;

          if (isValidDate && value.length == 10) {
            final newBirthDate = _birthDateToStringDTO.tryParse(
              value,
              formats: _dateFormats,
            );

            onChanged(newBirthDate?.toString() ?? '');
          }
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
