// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nav_stemi/nav_stemi.dart';

@immutable
class PatientInfoModel extends Equatable {
  const PatientInfoModel({
    this.lastName,
    this.firstName,
    this.middleName,
    this.birthDate,
    this.sexAtBirth,
    this.cardiologist,
  });

  final String? lastName;
  final String? firstName;
  final String? middleName;

  final DateTime? birthDate;
  final SexAtBirth? sexAtBirth;
  final String? cardiologist;

  /// ValueGetter used to allow null values in the copyWith method
  /// spec: https://stackoverflow.com/a/73432242
  PatientInfoModel copyWith({
    ValueGetter<String?>? lastName,
    ValueGetter<String?>? firstName,
    ValueGetter<String?>? middleName,
    ValueGetter<DateTime?>? birthDate,
    ValueGetter<SexAtBirth?>? sexAtBirth,
    ValueGetter<String?>? cardiologist,
  }) {
    return PatientInfoModel(
      lastName: lastName != null ? lastName() : this.lastName,
      firstName: firstName != null ? firstName() : this.firstName,
      middleName: middleName != null ? middleName() : this.middleName,
      birthDate: birthDate != null ? birthDate() : this.birthDate,
      sexAtBirth: sexAtBirth != null ? sexAtBirth() : this.sexAtBirth,
      cardiologist: cardiologist != null ? cardiologist() : this.cardiologist,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'sexAtBirth': sexAtBirth,
      'cardiologist': cardiologist,
    };
  }

  factory PatientInfoModel.fromMap(Map<String, dynamic> map) {
    return PatientInfoModel(
      lastName: map['lastName'] != null ? map['lastName'] as String : null,
      firstName: map['firstName'] != null ? map['firstName'] as String : null,
      middleName:
          map['middleName'] != null ? map['middleName'] as String : null,
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'] as int)
          : null,
      sexAtBirth: map['sexAtBirth'] != null
          ? SexAtBirthToEnumConverter.fromString(map['sexAtBirth'] as String)
          : null,
      cardiologist:
          map['cardiologist'] != null ? map['cardiologist'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  // ignore: lines_longer_than_80_chars
  factory PatientInfoModel.fromJson(String source) =>
      PatientInfoModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      lastName,
      firstName,
      middleName,
      birthDate,
      sexAtBirth,
      cardiologist,
    ];
  }

  bool patientInfoChecklistState() =>
      lastName != null ||
      firstName != null ||
      middleName != null ||
      birthDate != null ||
      sexAtBirth != null;

  bool cardiologistInfoChecklistState() =>
      cardiologist != null && cardiologist!.isNotEmpty;
}
