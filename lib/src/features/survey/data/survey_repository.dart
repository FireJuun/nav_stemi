import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/src/features/survey/domain/survey_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'survey_repository.g.dart';

class SurveyRepository {
  SurveyRepository(this._firestore);

  static const _collection = 'surveys';

  final FirebaseFirestore _firestore;

  /// Submit a survey response to Firebase
  Future<void> submitSurvey(SurveyResponseModel survey) async {
    final surveyWithTimestamp = survey.copyWith(
      surveySubmittedOn: Timestamp.now(),
    );

    await _firestore.collection(_collection).add(surveyWithTimestamp.toMap());
  }
}

@riverpod
SurveyRepository surveyRepository(Ref ref) {
  return SurveyRepository(FirebaseFirestore.instance);
}
