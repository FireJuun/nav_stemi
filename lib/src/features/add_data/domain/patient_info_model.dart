// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:equatable/equatable.dart';

class PatientInfoModel extends Equatable {
  const PatientInfoModel({
    this.lastName,
    this.firstName,
    this.middleName,
    this.birthDate,
    this.gender,
    this.cardiologist,
  });

  final String? lastName;
  final String? firstName;
  final String? middleName;

  final DateTime? birthDate;
  final String? gender;
  final String? cardiologist;

  PatientInfoModel copyWith({
    String? lastName,
    String? firstName,
    String? middleName,
    DateTime? birthDate,
    String? gender,
    String? cardiologist,
  }) {
    return PatientInfoModel(
      lastName: lastName ?? this.lastName,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      cardiologist: cardiologist ?? this.cardiologist,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'lastName': lastName,
      'firstName': firstName,
      'middleName': middleName,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'gender': gender,
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
      gender: map['gender'] != null ? map['gender'] as String : null,
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
      gender,
      cardiologist,
    ];
  }
}
