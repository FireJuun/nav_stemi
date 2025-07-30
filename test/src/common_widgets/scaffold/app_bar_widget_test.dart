import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:nav_stemi/nav_stemi.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockAuthClient extends Mock implements auth.AuthClient {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('AppBarWidget', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            appBar: AppBarWidget(),
          ),
        ),
      );
    }

    testWidgets('should display exit button and timer', (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Exit'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byType(CountUpTimerView), findsOneWidget);
    });

    testWidgets('should show account circle outlined when not logged in',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
      expect(find.byIcon(Icons.account_circle), findsNothing);
    });

    testWidgets('should show filled account circle when logged in',
        (tester) async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockAuthClient();
      final googleAppUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(googleAppUser),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.account_circle), findsOneWidget);
      expect(find.byIcon(Icons.account_circle_outlined), findsNothing);
    });

    testWidgets('should show FHIR sync indicator when logged in',
        (tester) async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockAuthClient();
      final googleAppUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(googleAppUser),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(FhirSyncStatusIndicator), findsOneWidget);
    });

    testWidgets('should not show FHIR sync indicator when not logged in',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FhirSyncStatusIndicator), findsNothing);
    });

    testWidgets('should show loading indicator during auth state loading',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => const Stream.empty(),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error icon on auth state error', (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.error(Exception('Auth error')),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show auth dialog when profile icon is pressed',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.byKey(AppBarWidget.profileIconButtonKey));
      await tester.pumpAndSettle();

      expect(find.byType(AuthDialog), findsOneWidget);
    });
  });

  group('AuthDialog', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget createTestWidget({
      VoidCallback? onClose,
    }) {
      return ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AuthDialog(onClose: onClose),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('should display sign in UI when not authenticated',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('You are not signed in'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets(
        'should display sign out UI when authenticated with GoogleAppUser',
        (tester) async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockAuthClient();
      when(() => mockGoogleSignInAccount.displayName).thenReturn('Test User');

      final googleAppUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(googleAppUser),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Signed in as: Test User'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets(
        'should display sign out UI when authenticated with ServiceAccountUser',
        (tester) async {
      final mockHttpClient = MockHttpClient();
      final serviceAccountUser = ServiceAccountUser(
        email: 'test@example.com',
        client: mockHttpClient,
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(serviceAccountUser),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Signed in as: User'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should sign in when Sign In button pressed', (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );
      when(() => mockAuthRepository.signIn()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.signIn()).called(1);
      expect(find.byType(AuthDialog), findsNothing);
    });

    testWidgets('should sign out when Sign Out button pressed', (tester) async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockAuthClient();
      final googleAppUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );

      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(googleAppUser),
      );
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      verify(() => mockAuthRepository.signOut()).called(1);
      expect(find.byType(AuthDialog), findsNothing);
    });

    testWidgets('should call onClose callback when sign out', (tester) async {
      final mockGoogleSignInAccount = MockGoogleSignInAccount();
      final mockAuthClient = MockAuthClient();
      final googleAppUser = GoogleAppUser(
        user: mockGoogleSignInAccount,
        client: mockAuthClient,
      );

      var onCloseCalled = false;
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(googleAppUser),
      );
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});

      await tester.pumpWidget(
        createTestWidget(
          onClose: () => onCloseCalled = true,
        ),
      );
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out'));
      await tester.pumpAndSettle();

      expect(onCloseCalled, isTrue);
    });

    testWidgets('should close dialog when Close button pressed',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.value(null),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.byType(AuthDialog), findsNothing);
    });

    testWidgets('should show loading indicator during auth state loading',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => const Stream.empty(),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show error message on auth state error',
        (tester) async {
      when(() => mockAuthRepository.authStateChanges()).thenAnswer(
        (_) => Stream.error(Exception('Auth error')),
      );

      await tester.pumpWidget(createTestWidget());
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Auth error'), findsOneWidget);
    });
  });
}
