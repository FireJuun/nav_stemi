import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nav_stemi/src/features/survey/domain/survey_model.dart';

void main() {
  group('SurveyResponseModel', () {
    final testTimestamp = Timestamp.fromDate(DateTime(2024, 1, 15, 10, 30));
    const testUid = 'test_uid';

    const testSurveyResponse = SurveyResponseModel(
      uid: testUid,
      appHelpfulness: 3,
      appDifficulty: 2,
      improvementSuggestion: 'Add more features',
    );

    final testSurveyResponseWithTimestamp = SurveyResponseModel(
      uid: testUid,
      appHelpfulness: 4,
      appDifficulty: 1,
      improvementSuggestion: 'Great app!',
      surveySubmittedOn: testTimestamp,
    );

    test('should create instance with required fields', () {
      expect(testSurveyResponse.uid, testUid);
      expect(testSurveyResponse.appHelpfulness, equals(3));
      expect(testSurveyResponse.appDifficulty, equals(2));
      expect(
        testSurveyResponse.improvementSuggestion,
        equals('Add more features'),
      );
      expect(testSurveyResponse.surveySubmittedOn, isNull);
    });

    test('should create instance with all fields including timestamp', () {
      expect(testSurveyResponseWithTimestamp.uid, testUid);
      expect(testSurveyResponseWithTimestamp.appHelpfulness, equals(4));
      expect(testSurveyResponseWithTimestamp.appDifficulty, equals(1));
      expect(testSurveyResponseWithTimestamp.improvementSuggestion, equals('Great app!'));
      expect(testSurveyResponseWithTimestamp.surveySubmittedOn, equals(testTimestamp));
    });

    group('appHelpfulness values', () {
      test('should accept valid helpfulness rating of 1 (Not helpful at all)', () {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 1,
          appDifficulty: 2,
          improvementSuggestion: 'Needs work',
        );
        expect(survey.appHelpfulness, equals(1));
      });

      test('should accept valid helpfulness rating of 4 (Very helpful)', () {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 4,
          appDifficulty: 2,
          improvementSuggestion: 'Excellent',
        );
        expect(survey.appHelpfulness, equals(4));
      });
    });

    group('appDifficulty values', () {
      test('should accept valid difficulty rating of 1 (Very easy)', () {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 1,
          improvementSuggestion: 'Simple to use',
        );
        expect(survey.appDifficulty, equals(1));
      });

      test('should accept valid difficulty rating of 4 (Very difficult)', () {
        const survey = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 4,
          improvementSuggestion: 'Too complex',
        );
        expect(survey.appDifficulty, equals(4));
      });
    });

    group('fromMap', () {
      test('should create instance from map without timestamp', () {
        final map = {
          'uid': testUid,
          'appHelpfulness': 3,
          'appDifficulty': 2,
          'improvementSuggestion': 'Add more features',
        };

        final survey = SurveyResponseModel.fromMap(map);

        expect(survey.uid, testUid);
        expect(survey.appHelpfulness, equals(3));
        expect(survey.appDifficulty, equals(2));
        expect(survey.improvementSuggestion, equals('Add more features'));
        expect(survey.surveySubmittedOn, isNull);
      });

      test('should create instance from map with timestamp', () {
        final map = {
          'uid': testUid,
          'appHelpfulness': 4,
          'appDifficulty': 1,
          'improvementSuggestion': 'Great app!',
          'surveySubmittedOn': testTimestamp,
        };

        final survey = SurveyResponseModel.fromMap(map);

        expect(survey.uid, testUid);
        expect(survey.appHelpfulness, equals(4));
        expect(survey.appDifficulty, equals(1));
        expect(survey.improvementSuggestion, equals('Great app!'));
        expect(survey.surveySubmittedOn, equals(testTimestamp));
      });

      test('should handle null timestamp in map', () {
        final map = {
          'uid': testUid,
          'appHelpfulness': 3,
          'appDifficulty': 2,
          'improvementSuggestion': 'Good app',
          'surveySubmittedOn': null,
        };

        final survey = SurveyResponseModel.fromMap(map);

        expect(survey.surveySubmittedOn, isNull);
      });
    });

    group('fromJson', () {
      test('should create instance from JSON string', () {
        const jsonString = '''
        {
          "uid": "test_uid",
          "appHelpfulness": 3,
          "appDifficulty": 2,
          "improvementSuggestion": "Add more features"
        }
        ''';

        final survey = SurveyResponseModel.fromJson(jsonString);

        expect(survey.uid, testUid);
        expect(survey.appHelpfulness, equals(3));
        expect(survey.appDifficulty, equals(2));
        expect(survey.improvementSuggestion, equals('Add more features'));
        expect(survey.surveySubmittedOn, isNull);
      });
    });

    group('toMap', () {
      test('should convert to map without timestamp', () {
        final map = testSurveyResponse.toMap();

        expect(map['uid'], testUid);
        expect(map['appHelpfulness'], equals(3));
        expect(map['appDifficulty'], equals(2));
        expect(map['improvementSuggestion'], equals('Add more features'));
        expect(map['surveySubmittedOn'], isNull);
      });

      test('should convert to map with timestamp', () {
        final map = testSurveyResponseWithTimestamp.toMap();

        expect(map['uid'], testUid);
        expect(map['appHelpfulness'], equals(4));
        expect(map['appDifficulty'], equals(1));
        expect(map['improvementSuggestion'], equals('Great app!'));
        expect(map['surveySubmittedOn'], equals(testTimestamp));
      });
    });

    group('toJson', () {
      test('should convert to JSON string', () {
        final json = testSurveyResponse.toJson();
        final decoded = SurveyResponseModel.fromJson(json);

        expect(decoded, equals(testSurveyResponse));
      });
    });

    group('copyWith', () {
      test('should copy with no changes', () {
        final copy = testSurveyResponse.copyWith();

        expect(copy, equals(testSurveyResponse));
      });

      test('should copy with appHelpfulness change', () {
        final copy = testSurveyResponse.copyWith(appHelpfulness: 4);

        expect(copy.appHelpfulness, equals(4));
        expect(copy.appDifficulty, equals(testSurveyResponse.appDifficulty));
        expect(copy.improvementSuggestion, equals(testSurveyResponse.improvementSuggestion));
      });

      test('should copy with appDifficulty change', () {
        final copy = testSurveyResponse.copyWith(appDifficulty: 1);

        expect(copy.appHelpfulness, equals(testSurveyResponse.appHelpfulness));
        expect(copy.appDifficulty, equals(1));
        expect(copy.improvementSuggestion, equals(testSurveyResponse.improvementSuggestion));
      });

      test('should copy with improvementSuggestion change', () {
        final copy = testSurveyResponse.copyWith(
          improvementSuggestion: 'New suggestion',
        );

        expect(copy.appHelpfulness, equals(testSurveyResponse.appHelpfulness));
        expect(copy.appDifficulty, equals(testSurveyResponse.appDifficulty));
        expect(copy.improvementSuggestion, equals('New suggestion'));
      });

      test('should copy with timestamp addition', () {
        final copy = testSurveyResponse.copyWith(surveySubmittedOn: testTimestamp);

        expect(copy.appHelpfulness, equals(testSurveyResponse.appHelpfulness));
        expect(copy.appDifficulty, equals(testSurveyResponse.appDifficulty));
        expect(copy.improvementSuggestion, equals(testSurveyResponse.improvementSuggestion));
        expect(copy.surveySubmittedOn, equals(testTimestamp));
      });

      test('should copy with all fields changed', () {
        final copy = testSurveyResponse.copyWith(
          uid: 'new_uid',
          appHelpfulness: 1,
          appDifficulty: 4,
          improvementSuggestion: 'Everything changed',
          surveySubmittedOn: testTimestamp,
        );

        expect(copy.uid, 'new_uid');
        expect(copy.appHelpfulness, equals(1));
        expect(copy.appDifficulty, equals(4));
        expect(copy.improvementSuggestion, equals('Everything changed'));
        expect(copy.surveySubmittedOn, equals(testTimestamp));
      });
    });

    group('Equatable', () {
      test('should support value equality', () {
        const survey1 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Add more features',
        );

        const survey2 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Add more features',
        );

        expect(survey1, equals(survey2));
      });

      test('should not be equal when fields differ', () {
        const survey1 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Add more features',
        );

        const survey2 = SurveyResponseModel(
          uid: 'other_uid',
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Add more features',
        );

        expect(survey1, isNot(equals(survey2)));
      });

      test('should include timestamp in equality check', () {
        final survey1 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Same text',
          surveySubmittedOn: testTimestamp,
        );

        final survey2 = SurveyResponseModel(
          uid: testUid,
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Same text',
          surveySubmittedOn: Timestamp.fromDate(DateTime(2024, 1, 16)),
        );

        expect(survey1, isNot(equals(survey2)));
      });
    });

    test('should have stringify enabled', () {
      expect(testSurveyResponse.stringify, isTrue);
    });

    test('should provide props for equality comparison', () {
      final props = testSurveyResponseWithTimestamp.props;

      expect(props.length, equals(5));
      expect(props[0], equals(testUid)); // uid
      expect(props[1], equals(4)); // appHelpfulness
      expect(props[2], equals(1)); // appDifficulty
      expect(props[3], equals('Great app!')); // improvementSuggestion
      expect(props[4], equals(testTimestamp)); // surveySubmittedOn
    });
  });
}
