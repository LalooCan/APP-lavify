import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../app_config.dart';
import '../repositories/firestore_worker_repository.dart';

class WorkerService {
  WorkerService._internal();

  static final WorkerService _instance = WorkerService._internal();

  factory WorkerService() => _instance;

  final ValueNotifier<bool> isAvailable = ValueNotifier<bool>(false);
  final FirestoreWorkerRepository _firestoreRepository =
      FirestoreWorkerRepository();

  void toggleAvailability() {
    setAvailability(!isAvailable.value);
  }

  void setAvailability(bool value, {GeoPoint? location}) {
    isAvailable.value = value;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (AppConfig.backendMode == BackendMode.firestore &&
        uid != null &&
        uid.isNotEmpty) {
      _firestoreRepository.setAvailability(uid, value, location);
    }
  }

  Future<List<Map<String, dynamic>>> getAvailableWorkers() {
    return _firestoreRepository.getAvailableWorkers();
  }

  void updateWorkerLocation(GeoPoint location) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return;
    }
    _firestoreRepository.updateWorkerLocation(uid, location);
  }
}
