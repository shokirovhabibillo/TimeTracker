import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../data/models/app_usage_model.dart';
import '../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  UserSettingsModel _settings = UserSettingsModel();
  bool _isLoading = true;

  UserSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  ThemeSpec get themeSpec => AppTheme.specById(_settings.themeType);
  ThemeData get themeData => themeSpec.data;

  Future<void> load() async {
    _settings = await _repository.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeId(String themeId) async {
    _settings = _settings.copyWith(themeType: themeId);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setClockStyle(String style) async {
    _settings = _settings.copyWith(clockStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setTimerStyle(String style) async {
    _settings = _settings.copyWith(timerStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setCalendarStyle(String style) async {
    _settings = _settings.copyWith(calendarStyle: style);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setSleepWindow(String start, String end) async {
    _settings = _settings.copyWith(sleepStartTime: start, sleepEndTime: end);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setDistractionLimit(int minutes) async {
    _settings = _settings.copyWith(dailyDistractionLimitMin: minutes);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }

  Future<void> setAmbientSound(String? trackId) async {
    _settings = _settings.copyWith(ambientSound: trackId);
    notifyListeners();
    await _repository.saveSettings(_settings);
  }
}
