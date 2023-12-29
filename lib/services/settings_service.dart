class SettingsService {
  // Private constructor
  SettingsService._privateConstructor();

  // Singleton instance
  static final SettingsService _instance = SettingsService._privateConstructor();

  // Factory constructor to return the same instance
  factory SettingsService() {
    return _instance;
  }

  String _unitType = 'metric'; // Default unit type

  String getCurrentUnitType() => _unitType;

  void updateUnitTypeFromSettings(String unitType) {
    _unitType = unitType;
  }
}
