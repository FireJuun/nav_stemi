import 'dart:async';

import 'package:nav_stemi/src/features/auth/data/firebase_user_data_repository.dart';
import 'package:nav_stemi/src/features/auth/domain/app_user.dart';
import 'package:nav_stemi/src/features/auth/domain/firebase_user_data.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user_profile_dialog_controller.g.dart';

@riverpod
class UserProfileDialogController extends _$UserProfileDialogController {
  @override
  FutureOr<void> build() {
    // no-op
  }

  Future<bool> updateUserData({
    required FirebaseAppUser appUser,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    final userDataRepository = ref.read(firebaseUserDataRepositoryProvider);
    final newUserData = FirebaseUserData(
      appUser: appUser,
      firstName: firstName,
      lastName: lastName,
      syncId: const Uuid().v4(),
    );
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => userDataRepository.updateUserData(newUserData),
    );
    return !state.hasError;
  }
}
