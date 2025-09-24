import 'package:nav_stemi/nav_stemi.dart';

class FirebaseUserData {
  FirebaseUserData({
    required this.appUser,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.isAdmin = false,
  });

  final FirebaseAppUser appUser;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool isAdmin;

  FirebaseUserData copyWith({
    required FirebaseAppUser appUser,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? isAdmin,
  }) {
    return FirebaseUserData(
      appUser: appUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
