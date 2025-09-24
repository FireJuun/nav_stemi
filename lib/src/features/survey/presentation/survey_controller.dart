import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'survey_controller.g.dart';

@riverpod
class SurveyController extends _$SurveyController with NotifierMounted {
  @override
  FutureOr<void> build() {
    // Nothing to build
    state = const AsyncData(null);
    ref.onDispose(setUnmounted);
  }

  Future<bool> submitSurvey({
    required int appHelpfulness,
    required int appDifficulty,
    required String improvementSuggestion,
  }) async {
    state = const AsyncLoading();

    final surveyRepository = ref.read(surveyRepositoryProvider);
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) {
      state = AsyncError('User not logged in', StackTrace.current);
      return false;
    }
    final survey = SurveyResponseModel(
      uid: user.uid,
      appHelpfulness: appHelpfulness,
      appDifficulty: appDifficulty,
      improvementSuggestion: improvementSuggestion,
    );

    state = await AsyncValue.guard(() => surveyRepository.submitSurvey(survey));

    return !state.hasError;
  }
}
