import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'firebase_user_data_repository.g.dart';

class FirebaseUserDataRepository {
  FirebaseUserDataRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const String _usersPath = 'users';

  Future<void> createUserData(FirebaseUserData userData) {
    return _firestore
        .collection(_usersPath)
        .doc(userData.appUser.uid)
        .set(userData.toMap());
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
          syncId: data['syncId'] as String?,
        );
      }
      return null;
    });
  }

  Future<void> updateUserData(FirebaseUserData userData) {
    return _firestore
        .collection(_usersPath)
        .doc(userData.appUser.uid)
        .update(userData.toMap());
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
        isAdmin: data['isAdmin'] as bool? ?? false,
        syncId: data['syncId'] as String?,
      );
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
FirebaseUserDataRepository firebaseUserDataRepository(Ref ref) {
  return FirebaseUserDataRepository(FirebaseFirestore.instance);
}

@riverpod
Future<FirebaseUserData?> fetchFirebaseUserData(Ref ref) async {
  final activeUser = ref.read(authStateChangesProvider).value;
  final repository = ref.read(firebaseUserDataRepositoryProvider);

  if (activeUser is FirebaseAppUser) {
    final cloudData = await repository.fetchUserData(activeUser);

    if (cloudData != null) {
      /// data already present
      return cloudData;
    } else {
      final newData =
          FirebaseUserData(appUser: activeUser, syncId: const Uuid().v4());

      /// push this data to cloud
      await repository.createUserData(newData);
      return newData;
    }
  }
  throw AssertionError('Not signed in with Firebase');
}
