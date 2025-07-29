import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockSurveyRepository extends Mock implements SurveyRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SurveyResponseModel(
        appHelpfulness: 0,
        appDifficulty: 0,
        improvementSuggestion: '',
      ),
    );
  });
  group('SurveyController', () {
    late ProviderContainer container;
    late MockSurveyRepository mockSurveyRepository;

    setUp(() {
      mockSurveyRepository = MockSurveyRepository();
      container = ProviderContainer(
        overrides: [
          surveyRepositoryProvider.overrideWithValue(mockSurveyRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should have initial state as AsyncData(null)', () {
      final state = container.read(surveyControllerProvider);
      expect(state, equals(const AsyncData<void>(null)));
    });

    group('submitSurvey', () {
      test('should submit survey successfully and return true', () async {
        // Arrange
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);

        // Act
        final result = await controller.submitSurvey(
          appHelpfulness: 4,
          appDifficulty: 1,
          improvementSuggestion: 'Great app!',
        );

        // Assert
        expect(result, isTrue);
        expect(
          container.read(surveyControllerProvider),
          equals(const AsyncData<void>(null)),
        );

        // Verify the repository was called with correct survey
        final capturedSurvey = verify(
          () => mockSurveyRepository.submitSurvey(captureAny()),
        ).captured.single as SurveyResponseModel;

        expect(capturedSurvey.appHelpfulness, equals(4));
        expect(capturedSurvey.appDifficulty, equals(1));
        expect(capturedSurvey.improvementSuggestion, equals('Great app!'));
      });

      test('should handle submission errors and return false', () async {
        // Arrange
        final error = Exception('Network error');
        when(() => mockSurveyRepository.submitSurvey(any())).thenThrow(error);

        final controller = container.read(surveyControllerProvider.notifier);

        // Act
        final result = await controller.submitSurvey(
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Needs improvement',
        );

        // Assert
        expect(result, isFalse);

        final state = container.read(surveyControllerProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals(error));
      });

      test('should handle all valid helpfulness ratings', () async {
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);

        // Test all valid ratings (1-4)
        for (var rating = 1; rating <= 4; rating++) {
          final result = await controller.submitSurvey(
            appHelpfulness: rating,
            appDifficulty: 2,
            improvementSuggestion: 'Rating $rating',
          );

          expect(result, isTrue);
        }

        // Verify 4 calls were made
        verify(() => mockSurveyRepository.submitSurvey(any())).called(4);
      });

      test('should handle all valid difficulty ratings', () async {
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);

        // Test all valid ratings (1-4)
        for (var rating = 1; rating <= 4; rating++) {
          final result = await controller.submitSurvey(
            appHelpfulness: 3,
            appDifficulty: rating,
            improvementSuggestion: 'Difficulty $rating',
          );

          expect(result, isTrue);
        }

        // Verify 4 calls were made
        verify(() => mockSurveyRepository.submitSurvey(any())).called(4);
      });

      test('should handle empty improvement suggestion', () async {
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);

        final result = await controller.submitSurvey(
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: '',
        );

        expect(result, isTrue);

        final capturedSurvey = verify(
          () => mockSurveyRepository.submitSurvey(captureAny()),
        ).captured.single as SurveyResponseModel;

        expect(capturedSurvey.improvementSuggestion, equals(''));
      });

      test('should handle very long improvement suggestion', () async {
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);
        final longSuggestion = 'A' * 1000;

        final result = await controller.submitSurvey(
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: longSuggestion,
        );

        expect(result, isTrue);

        final capturedSurvey = verify(
          () => mockSurveyRepository.submitSurvey(captureAny()),
        ).captured.single as SurveyResponseModel;

        expect(capturedSurvey.improvementSuggestion, equals(longSuggestion));
      });

      test('should handle multiple consecutive submissions', () async {
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final controller = container.read(surveyControllerProvider.notifier);

        // Submit first survey
        final result1 = await controller.submitSurvey(
          appHelpfulness: 4,
          appDifficulty: 1,
          improvementSuggestion: 'First submission',
        );
        expect(result1, isTrue);

        // Submit second survey
        final result2 = await controller.submitSurvey(
          appHelpfulness: 2,
          appDifficulty: 3,
          improvementSuggestion: 'Second submission',
        );
        expect(result2, isTrue);

        // Verify both submissions
        verify(() => mockSurveyRepository.submitSurvey(any())).called(2);
      });

      test('should maintain state consistency after error', () async {
        // First submission fails
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenThrow(Exception('Error'));

        final controller = container.read(surveyControllerProvider.notifier);

        final result1 = await controller.submitSurvey(
          appHelpfulness: 3,
          appDifficulty: 2,
          improvementSuggestion: 'Will fail',
        );
        expect(result1, isFalse);
        expect(container.read(surveyControllerProvider).hasError, isTrue);

        // Second submission succeeds
        when(() => mockSurveyRepository.submitSurvey(any()))
            .thenAnswer((_) async {});

        final result2 = await controller.submitSurvey(
          appHelpfulness: 4,
          appDifficulty: 1,
          improvementSuggestion: 'Will succeed',
        );
        expect(result2, isTrue);
        expect(container.read(surveyControllerProvider).hasError, isFalse);
      });
    });
  });
}
