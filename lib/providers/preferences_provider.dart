import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class PreferencesProvider with ChangeNotifier {
  final PreferencesService _preferencesService;
  
  // États réactifs
  String _themeMode;
  String _languageCode;
  bool _notificationsEnabled;
  bool _locationEnabled;
  String _currencyCode;

  PreferencesProvider(this._preferencesService)
      : _themeMode = _preferencesService.themeMode,
        _languageCode = _preferencesService.languageCode,
        _notificationsEnabled = _preferencesService.notificationsEnabled,
        _locationEnabled = _preferencesService.locationEnabled,
        _currencyCode = _preferencesService.currencyCode;

  // Getters
  String get themeMode => _themeMode;
  String get languageCode => _languageCode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationEnabled => _locationEnabled;
  String get currencyCode => _currencyCode;

  // Setters avec persistance
  Future<void> setThemeMode(String theme) async {
    _themeMode = theme;
    await _preferencesService.setThemeMode(theme);
    notifyListeners();
  }

  Future<void> setLanguageCode(String language) async {
    _languageCode = language;
    await _preferencesService.setLanguageCode(language);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    await _preferencesService.setNotificationsEnabled(enabled);
    notifyListeners();
  }

  Future<void> setLocationEnabled(bool enabled) async {
    _locationEnabled = enabled;
    await _preferencesService.setLocationEnabled(enabled);
    notifyListeners();
  }

  Future<void> setCurrencyCode(String currency) async {
    _currencyCode = currency;
    await _preferencesService.setCurrencyCode(currency);
    notifyListeners();
  }

  // Méthode pour obtenir le thème réel
  ThemeMode get currentThemeMode {
    switch (_themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }
}