// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';

// A script to extract and encode the private key
// from a Google service account JSON file
// Usage: dart encode_key.dart < your_service_account_key.json
// Or: cat your_service_account_key.json | dart encode_key.dart

Future<void> main() async {
  try {
    // Check if stdin has input (piped content)
    if (stdin.hasTerminal) {
      print(
        'Please provide the service account JSON by piping it to this script:',
      );
      print(
        'Example: cat your_service_account_key.json | dart encode_key.dart',
      );
      exit(1);
    }

    // Read the JSON from stdin
    final input = await stdin.transform(utf8.decoder).join();

    if (input.isEmpty) {
      print('Error: No input received');
      exit(1);
    }

    // Parse the JSON
    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(input.trim()) as Map<String, dynamic>;
    } catch (e) {
      print('Error: Invalid JSON format');
      exit(1);
    }

    // Extract the private key
    final privateKey = jsonData['private_key'] as String?;
    if (privateKey == null) {
      print('Error: No "private_key" field found in the JSON');
      exit(1);
    }

    // Encode to base64
    final base64Key = base64.encode(utf8.encode(privateKey));

    // Print the encoded key
    print('Base64 encoded private key:');
    print(base64Key);

    print('\nUse this encoded key in your Dart defines.');
  } catch (e) {
    print('Error encoding key: $e');
    exit(1);
  }
}
