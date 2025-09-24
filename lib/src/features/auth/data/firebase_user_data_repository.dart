import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_user_data_repository.g.dart';

class FirebaseUserDataRepository {
  FirebaseUserDataRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _usersPath = 'users';

  Future<void> createUserData(FirebaseUserData userData) {
    return _firestore.collection(_usersPath).doc(userData.appUser.uid).set({
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'phoneNumber': userData.phoneNumber,
    });
  }

  Stream<FirebaseUserData?> watchUserData(FirebaseAppUser appUser) {
    return _firestore
        .collection(_usersPath)
        .doc(appUser.uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        return FirebaseUserData(
          appUser: appUser,
          firstName: data['firstName'] as String?,
          lastName: data['lastName'] as String?,
          phoneNumber: data['phoneNumber'] as String?,
        );
      }
      return null;
    });
  }

  Future<void> updateUserData(FirebaseUserData userData) {
    return _firestore.collection(_usersPath).doc(userData.appUser.uid).update({
      'firstName': userData.firstName,
      'lastName': userData.lastName,
      'phoneNumber': userData.phoneNumber,
    });
  }

  Future<FirebaseUserData?> fetchUserData(FirebaseAppUser appUser) async {
    final snapshot =
        await _firestore.collection(_usersPath).doc(appUser.uid).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      return FirebaseUserData(
        appUser: appUser,
        firstName: data['firstName'] as String?,
        lastName: data['lastName'] as String?,
        phoneNumber: data['phoneNumber'] as String?,
        isAdmin: data['isAdmin'] as bool? ?? false,
      );
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
FirebaseUserDataRepository firebaseUserDataRepository(Ref ref) {
  return FirebaseUserDataRepository(FirebaseFirestore.instance);
}

@Riverpod(keepAlive: true)
Stream<FirebaseUserData?> watchFirebaseUserData(Ref ref) {
  final activeUser = ref.watch(authStateChangesProvider).value;
  final repository = ref.watch(firebaseUserDataRepositoryProvider);

  if (activeUser is FirebaseAppUser) {
    return repository.watchUserData(activeUser);
  }
  return Stream.value(null);
}
