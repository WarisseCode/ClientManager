import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  static const String _notificationsKey = 'notifications_enabled';
  static const String _locationKey = 'location_enabled';
  static const String _currencyKey = 'currency_code';

  // Valeurs par défaut
  static const String defaultTheme = 'dark';
  static const String defaultLanguage = 'fr';
  static const String defaultCurrency = 'EUR';
  static const bool defaultNotifications = true;
  static const bool defaultLocation = false;

  late SharedPreferences _prefs;

  Future<PreferencesService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Gestion du thème
  String get themeMode => _prefs.getString(_themeKey) ?? defaultTheme;
  Future<void> setThemeMode(String theme) async {
    await _prefs.setString(_themeKey, theme);
  }

  // Gestion de la langue
  String get languageCode => _prefs.getString(_languageKey) ?? defaultLanguage;
  Future<void> setLanguageCode(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  // Gestion des notifications
  bool get notificationsEnabled => _prefs.getBool(_notificationsKey) ?? defaultNotifications;
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsKey, enabled);
  }

  // Gestion de la localisation
  bool get locationEnabled => _prefs.getBool(_locationKey) ?? defaultLocation;
  Future<void> setLocationEnabled(bool enabled) async {
    await _prefs.setBool(_locationKey, enabled);
  }

  // Gestion de la devise
  String get currencyCode => _prefs.getString(_currencyKey) ?? defaultCurrency;
  Future<void> setCurrencyCode(String currency) async {
    await _prefs.setString(_currencyKey, currency);
  }
}