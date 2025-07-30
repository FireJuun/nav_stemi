import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:nav_stemi/nav_stemi.dart';

void main() {
  group('FhirRepository', () {
    test('can be instantiated', () {
      final repository = FhirRepository(
        client: http.Client(),
        baseUri: Uri.parse('https://example.com'),
      );

      expect(repository, isA<FhirRepository>());
      expect(repository.client, isA<http.Client>());
      expect(repository.baseUri.toString(), 'https://example.com');
    });

    test('FhirRequestException contains message and status code', () {
      const exception = FhirRequestException('Test error', 404, 'Not found');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, 404);
      expect(exception.responseBody, 'Not found');
      expect(
        exception.toString(),
        'FhirRequestException: Test error (Status: 404)',
      );
    });
  });
}
