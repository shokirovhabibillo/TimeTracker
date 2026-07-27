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

  AppThemeType get themeType => _settings.themeType == 'classic'
      ? AppThemeType.classic
      : AppThemeType.hightech;

  Future<void> load() async {
    _settings = await _repository.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setThemeType(AppThemeType type) async {
    _settings = _settings.copyWith(
        themeType: type == AppThemeType.classic ? 'classic' : 'hightech');
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
