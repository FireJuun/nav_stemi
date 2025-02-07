import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nav_stemi/nav_stemi.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'hospitals_repository.g.dart';

class HospitalsRepository {
  HospitalsRepository(this._firestore);
  // TODO(FireJuun): extract [_collection]...eventually
  /// This will be relevant when additional regions or hospital systems
  /// are incorporated into the app
  static const _collection = 'hospitals-rcems';

  final FirebaseFirestore _firestore;

  Future<List<Hospital>> fetchHospitals() async {
    final ref = _firestore.collection(_collection);
    final snapshot = await ref.get();

    final data = snapshot.docs.map((doc) {
      return Hospital.fromMap(doc.data());
    }).toList();

    return data;
  }

  // TODO(FireJuun): add stream/watch support
  // Stream<List<Hospital>> watchHospitals() {
  //   final ref = _firestore.collection(_collection);
  //   final data = ref.snapshots().map(
  //         (snapshot) => snapshot.docs.map((doc) {
  //           return Hospital.fromMap(doc.data());
  //         }).toList(),
  //       );

  //   return data;
  // }

  // TODO(FireJuun): implement converter for better type safety
  /// This will require the data model to track
  /// the document ID for each file in the collection
  ///
  // CollectionReference<Map<String, Hospital>> _hospitalRef() => _firestore
  //     .collection(_collection)
  //     .withConverter<Hospital>(
  //       fromFirestore: (doc, _) => Hospital.fromMap(doc.data()!),
  //       toFirestore: (hospital, _) => hospital.toMap(),
  //     )
}

@riverpod
HospitalsRepository hospitalsRepository(Ref ref) {
  return HospitalsRepository(FirebaseFirestore.instance);
}
