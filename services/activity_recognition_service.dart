import 'dart:async';

import 'package:flutter_activity_recognition/flutter_activity_recognition.dart' as far;

import '../data/models/activity_log_model.dart';
import '../data/repositories/activity_time_repository.dart';

/// Listens for activity-type changes (walking/running/cycling/driving)
/// using Android's on-device Activity Recognition — no location/GPS
/// permission required, only ACTIVITY_RECOGNITION. Accumulates elapsed
/// time per mode into [ActivityTimeRepository] whenever the detected
/// activity changes.
class ActivityRecognitionService {
  static final ActivityRecognitionService instance = ActivityRecognitionService._();
  ActivityRecognitionService._();

  final _repository = ActivityTimeRepository();
  StreamSubscription<far.Activity>? _sub;
  String? _currentType;
  DateTime? _since;
  bool _started = false;

  /// Requests permission once (if not already granted/denied) and
  /// starts listening. Safe to call multiple times — only starts once.
  Future<void> start() async {
    if (_started) return;
    try {
      var permission = await far.FlutterActivityRecognition.instance.checkPermission();
      if (permission == far.ActivityPermission.DENIED) {
        permission = await far.FlutterActivityRecognition.instance.requestPermission();
      }
      if (permission != far.ActivityPermission.GRANTED) return;
    } catch (_) {
      return; // Sensor/permission unavailable on this device — fail quietly.
    }

    _started = true;
    _sub = far.FlutterActivityRecognition.instance.activityStream.listen(_onActivity, onError: (_) {});
  }

  void _onActivity(far.Activity activity) {
    final mapped = _mapType(activity.type);
    final now = DateTime.now();
    if (_currentType != null && _since != null) {
      final elapsed = now.difference(_since!).inSeconds;
      _repository.addSeconds(_currentType!, elapsed);
    }
    _currentType = mapped;
    _since = now;
  }

  String _mapType(far.ActivityType type) {
    switch (type) {
      case far.ActivityType.WALKING:
        return AppActivityType.walking;
      case far.ActivityType.RUNNING:
        return AppActivityType.running;
      case far.ActivityType.ON_BICYCLE:
        return AppActivityType.cycling;
      case far.ActivityType.IN_VEHICLE:
        return AppActivityType.vehicle;
      default:
        return AppActivityType.still;
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
