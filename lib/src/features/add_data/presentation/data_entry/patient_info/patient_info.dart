import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _goBackInYears = 60;
const _goBackDuration = Duration(days: _goBackInYears * 365);
const _oldestAgeInYears = 150;
const _oldestAgeDuration = Duration(days: _oldestAgeInYears * 365);
const _birthDateToStringDTO = BirthDateToStringDTO();

class PatientInfo extends ConsumerStatefulWidget {
  const PatientInfo({required this.patientInfoModel, super.key});

  final PatientInfoModel patientInfoModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientInfoState();
}

class _PatientInfoState extends ConsumerState<PatientInfo> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _lastNameTextController =
      TextEditingController(text: widget.patientInfoModel.lastName);
  late final TextEditingController _firstNameTextController =
      TextEditingController(text: widget.patientInfoModel.firstName);
  late final TextEditingController _middleNameTextController =
      TextEditingController(text: widget.patientInfoModel.middleName);
  late final TextEditingController _birthDateTextController =
      TextEditingController(
    text: widget.patientInfoModel.birthDate?.toBirthDateString(),
  );
  late final TextEditingController _cardiologistTextController =
      TextEditingController(text: widget.patientInfoModel.cardiologist);

  late SexAtBirth? _sexAtBirth = widget.patientInfoModel.sexAtBirth;
  late DateTime? _birthDate = widget.patientInfoModel.birthDate;

  @override
  void dispose() {
    _lastNameTextController.dispose();
    _firstNameTextController.dispose();
    _middleNameTextController.dispose();
    _birthDateTextController.dispose();
    _cardiologistTextController.dispose();
    super.dispose();
  }

  void _onFormDataChanged() {
    final patientInfoModel = PatientInfoModel(
      lastName: _lastNameTextController.text,
      firstName: _firstNameTextController.text,
      middleName: _middleNameTextController.text,
      birthDate: _birthDate,
      sexAtBirth: _sexAtBirth,
      cardiologist: _cardiologistTextController.text,
    );
    _updatePatientInfo(patientInfoModel);
  }

  Future<void> _updatePatientInfo(PatientInfoModel patientInfoModel) async {
    if (_formKey.currentState!.validate()) {
      // final scaffoldMessenger = ScaffoldMessenger.of(context);

      // TODO(FireJuun): debounce this
      // final success =
      ref
          .read(patientInfoControllerProvider.notifier)
          .setPatientInfo(patientInfoModel);
      // if (success) {
      // scaffoldMessenger.showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       'Patient info updated'.hardcoded,
      //     ),
      //   ),
      // );
      // }
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
                          onDataSubmitted: _updatePatientInfo,
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
                        controller: _firstNameTextController,
                      ),
                    ),
                    gapW16,
                    Expanded(
                      child: PatientInfoTextField(
                        label: 'Middle Name'.hardcoded,
                        controller: _middleNameTextController,
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
                          controller: _lastNameTextController,
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
                      child: PatientInfoTextField(
                        label: 'Date of Birth'.hardcoded,
                        controller: _birthDateTextController,
                        keyboardType: TextInputType.datetime,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return null;
                          }

                          /// Date formats used to try and parse the birth date
                          /// from a given string entered by the user
                          final formats = [
                            DateFormat('MM/dd/yy'),
                            DateFormat('MM/dd/yyyy'),
                            DateFormat('MM-dd-yy'),
                            DateFormat('MM-dd-yyyy'),
                          ];

                          final newBirthDate = const BirthDateToStringDTO()
                              .tryParse(value, formats: formats);
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

                          setState(() => _birthDate = newBirthDate);

                          return null;
                        },
                        prefixIcon: IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: () async {
                            final now = DateTime.now();

                            final selectedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(1900),
                              initialDate: now.subtract(_goBackDuration),
                              initialDatePickerMode: DatePickerMode.year,
                              lastDate: now,
                            );

                            if (selectedDate != null) {
                              _birthDateTextController.text =
                                  _birthDateToStringDTO
                                      .convertDatePicker(selectedDate);
                            } else {
                              _birthDateTextController.text = '';
                            }

                            setState(() => _birthDate = selectedDate);
                          },
                        ),
                      ),
                    ),
                    gapW32,
                    Expanded(
                      child: Text(
                        _birthDate != null
                            ? 'Age:   ${_birthDate!.ageFromBirthDate()}'
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
                  selected: {widget.patientInfoModel.sexAtBirth},
                  emptySelectionAllowed: true,
                  onSelectionChanged: (sexAtBirthList) {
                    final newSexAtBirth = sexAtBirthList.firstOrNull;

                    setState(() => _sexAtBirth = newSexAtBirth);
                    _onFormDataChanged();
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
                  controller: _cardiologistTextController,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PatientInfoTextField extends StatelessWidget {
  const PatientInfoTextField({
    required this.label,
    required this.controller,
    this.prefixIcon,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        filled: !readOnly,
        label: Text(label, textAlign: TextAlign.center),
      ),
      readOnly: readOnly,
      onTapOutside: (PointerDownEvent event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
    );
  }
}
