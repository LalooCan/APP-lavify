import 'package:flutter/foundation.dart';

class WorkerService {
  WorkerService._internal();

  static final WorkerService _instance = WorkerService._internal();

  factory WorkerService() => _instance;

  final ValueNotifier<bool> isAvailable = ValueNotifier<bool>(false);

  void toggleAvailability() {
    isAvailable.value = !isAvailable.value;
  }

  void setAvailability(bool value) {
    isAvailable.value = value;
  }
}
