import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

/// Used to import CSV data into Cloud Firestore from a local file
List<Map<String, dynamic>> parseCSV(String csvFilePath) {
  final rows =
      const CsvToListConverter().convert(File(csvFilePath).readAsStringSync());
  final data = <Map<String, dynamic>>[];

  // Assuming your CSV has a header row
  final headers = rows.removeAt(0).cast<String>();

  for (final row in rows) {
    final document = <String, dynamic>{};
    for (var i = 0; i < headers.length; i++) {
      document[headers[i]] = row[i];
    }
    data.add(document);
  }

  return data;
}

Future<void> selectAndUploadCSV() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
  );

  if (result != null) {
    final filePath = result.files.single.path!;
    await uploadCSVToFirestore(filePath);
  }
}

// TODO(FireJuun): Add error handling
// TODO(FireJuun): Make it so that we aren't adding duplicate data
Future<void> uploadCSVToFirestore(String csvFilePath) async {
  final data = parseCSV(csvFilePath);

  final firestore = FirebaseFirestore.instance;
  final CollectionReference hospitalsCollection =
      firestore.collection('hospitals-rcems');

  for (final document in data) {
    await hospitalsCollection.add(document);
  }

  debugPrint('CSV data uploaded to Firestore!');
}
