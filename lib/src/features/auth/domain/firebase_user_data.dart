import 'package:nav_stemi/nav_stemi.dart';

class FirebaseUserData {
  FirebaseUserData({
    required this.appUser,
    this.firstName,
    this.lastName,
    this.isAdmin = false,
  });

  final FirebaseAppUser appUser;
  final String? firstName;
  final String? lastName;
  late final String? phoneNumber = appUser.user.phoneNumber;
  final bool isAdmin;

  FirebaseUserData copyWith({
    required FirebaseAppUser appUser,
    String? firstName,
    String? lastName,
    bool? isAdmin,
  }) {
    return FirebaseUserData(
      appUser: appUser,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
