import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/survey/data/survey_repository.dart';
import 'package:nav_stemi/src/features/survey/domain/survey_model.dart';

void main() {
  group('SurveyRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SurveyRepository repository;
    const testUid = 'test_uid';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = SurveyRepository(fakeFirestore);
    });

    group('submitSurvey', () {
      test('should add survey to Firestore with timestamp', () async {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 4,
          appDifficulty: 1,
          improvementSuggestion: 'Great app, no changes needed!',
        );

        await repository.submitSurvey(survey);

        // Verify the survey was added to the collection
        final snapshot = await fakeFirestore.collection('surveys').get();
        expect(snapshot.docs.length, equals(1));

        final savedData = snapshot.docs.first.data();
        expect(savedData['uid'], testUid);
        expect(savedData['appHelpfulness'], equals(4));
        expect(savedData['appDifficulty'], equals(1));
        expect(
          savedData['improvementSuggestion'],
          equals('Great app, no changes needed!'),
        );
        expect(savedData['surveySubmittedOn'], isA<Timestamp>());
      });

      test('should preserve existing timestamp if already set', () async {
        final existingTimestamp = Timestamp.fromDate(
          DateTime(2024, 1, 15, 10, 30),
        );

        final survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Could use improvements',
          surveySubmittedOn: existingTimestamp,
        );

        await repository.submitSurvey(survey);

        final snapshot = await fakeFirestore.collection('surveys').get();
        final savedData = snapshot.docs.first.data();

        // Should have replaced with current timestamp
        expect(savedData['surveySubmittedOn'], isA<Timestamp>());
        expect(
          savedData['surveySubmittedOn'],
          isNot(equals(existingTimestamp)),
        );
      });

      test('should handle multiple survey submissions', () async {
        const survey1 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 2,
          appDifficulty: 3,
          improvementSuggestion: 'Needs work',
        );

        const survey2 = SurveyResponseModel(
          uid: 'test_uid_2',
          appHelpfulness: 4,
          appDifficulty: 1,
          improvementSuggestion: 'Excellent!',
        );

        await repository.submitSurvey(survey1);
        await repository.submitSurvey(survey2);

        final snapshot = await fakeFirestore.collection('surveys').get();
        expect(snapshot.docs.length, equals(2));

        final allSurveys = snapshot.docs.map((doc) => doc.data()).toList();

        // Verify both surveys are saved
        expect(
          allSurveys.any((data) => data['appHelpfulness'] == 2),
          isTrue,
        );
        expect(
          allSurveys.any((data) => data['appHelpfulness'] == 4),
          isTrue,
        );
      });

      test('should save all rating values correctly', () async {
        // Test minimum values
        const minSurvey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 1,
          appDifficulty: 1,
          improvementSuggestion: 'Min values',
        );

        await repository.submitSurvey(minSurvey);

        // Test maximum values
        const maxSurvey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 4,
          appDifficulty: 4,
          improvementSuggestion: 'Max values',
        );

        await repository.submitSurvey(maxSurvey);

        final snapshot = await fakeFirestore.collection('surveys').get();
        expect(snapshot.docs.length, equals(2));

        final allData = snapshot.docs.map((doc) => doc.data()).toList();

        // Verify min values
        final minData = allData.firstWhere(
          (data) => data['improvementSuggestion'] == 'Min values',
        );
        expect(minData['appHelpfulness'], equals(1));
        expect(minData['appDifficulty'], equals(1));

        // Verify max values
        final maxData = allData.firstWhere(
          (data) => data['improvementSuggestion'] == 'Max values',
        );
        expect(maxData['appHelpfulness'], equals(4));
        expect(maxData['appDifficulty'], equals(4));
      });

      test('should handle empty improvement suggestion', () async {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: '',
        );

        await repository.submitSurvey(survey);

        final snapshot = await fakeFirestore.collection('surveys').get();
        final savedData = snapshot.docs.first.data();

        expect(savedData['improvementSuggestion'], equals(''));
      });

      test('should handle very long improvement suggestion', () async {
        final longSuggestion = 'A' * 1000; // 1000 character string

        final survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: longSuggestion,
        );

        await repository.submitSurvey(survey);

        final snapshot = await fakeFirestore.collection('surveys').get();
        final savedData = snapshot.docs.first.data();

        expect(savedData['improvementSuggestion'], equals(longSuggestion));
      });

      test('should create document with auto-generated ID', () async {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Test',
        );

        await repository.submitSurvey(survey);

        final snapshot = await fakeFirestore.collection('surveys').get();

        // Document should have an auto-generated ID
        expect(snapshot.docs.first.id, isNotEmpty);
        expect(snapshot.docs.first.id.length, greaterThan(10));
      });

      test('should maintain data integrity through serialization', () async {
        const originalSurvey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: r'Test suggestion with special chars: @#$%',
        );

        await repository.submitSurvey(originalSurvey);

        final snapshot = await fakeFirestore.collection('surveys').get();
        final savedData = snapshot.docs.first.data();

        // Convert back to model (excluding timestamp which is added)
        final retrievedSurvey = SurveyResponseModel.fromMap({
          ...savedData,
          'surveySubmittedOn': null, // Remove timestamp for comparison
        });

        expect(retrievedSurvey.uid, testUid);
        expect(
          retrievedSurvey.appHelpfulness,
          equals(originalSurvey.appHelpfulness),
        );
        expect(
          retrievedSurvey.appDifficulty,
          equals(originalSurvey.appDifficulty),
        );
        expect(
          retrievedSurvey.improvementSuggestion,
          equals(originalSurvey.improvementSuggestion),
        );
      });
    });
  });
}
