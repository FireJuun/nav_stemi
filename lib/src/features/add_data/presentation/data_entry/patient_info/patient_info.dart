import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';

const _goBackInYears = 60;
const _goBackDuration = Duration(days: _goBackInYears * 365);
const _birthDateToStringDTO = BirthDateToStringDTO();

class PatientInfo extends ConsumerStatefulWidget {
  const PatientInfo({required this.patientInfoModel, super.key});

  final PatientInfoModel patientInfoModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PatientInfoState();
}

class _PatientInfoState extends ConsumerState<PatientInfo> {
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
  late final TextEditingController _genderTextController =
      TextEditingController(text: widget.patientInfoModel.gender);
  late final TextEditingController _cardiologistTextController =
      TextEditingController(text: widget.patientInfoModel.cardiologist);

  DateTime? birthDate;

  @override
  void dispose() {
    _lastNameTextController.dispose();
    _firstNameTextController.dispose();
    _middleNameTextController.dispose();
    _birthDateTextController.dispose();
    _genderTextController.dispose();
    _cardiologistTextController.dispose();
    super.dispose();
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList.list(
            children: [
              Center(
                child: FilledButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (context) => ScanQrLicenseDialog(
                        onDataSubmitted: (patientInfoModel) {
                          setState(() {
                            _lastNameTextController.text =
                                patientInfoModel.lastName ?? '';
                            _firstNameTextController.text =
                                patientInfoModel.firstName ?? '';
                            _middleNameTextController.text =
                                patientInfoModel.middleName ?? '';
                            _birthDateTextController.text = patientInfoModel
                                    .birthDate
                                    ?.toBirthDateString() ??
                                '';
                            _genderTextController.text =
                                patientInfoModel.gender ?? '';
                          });
                        },
                      ),
                    );
                  },
                  child: Text("Scan Driver's License".hardcoded),
                ),
              ),
              gapH16,
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
              if (birthDate != null)
                Text(
                  'Age: ${birthDate?.ageFromBirthDate()}',
                ),
              gapH32,
              Row(
                children: [
                  Expanded(
                    child: PatientInfoTextField(
                      label: 'Date of Birth'.hardcoded,
                      controller: _birthDateTextController,
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

                          setState(() {
                            birthDate = selectedDate;
                          });
                        },
                      ),
                    ),
                  ),
                  gapW32,
                  Expanded(
                    child: PatientInfoTextField(
                      label: 'Gender'.hardcoded,
                      controller: _genderTextController,
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.list),
                        onPressed: () {
                          // TODO(FireJuun): Open picker window to select gender
                        },
                      ),
                    ),
                  ),
                ],
              ),
              gapH32,
              const Divider(thickness: 4),
              gapH16,
              PatientInfoTextField(
                label: "Patient's Cardiologist".hardcoded,
                controller: _cardiologistTextController,
              ),
            ],
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
    this.readOnly = false,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
