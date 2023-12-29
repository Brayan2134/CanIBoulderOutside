import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _unitKey = 'unitType'; // Key to store the unit type

  Future<void> updateUnitTypeFromSettings(String unitType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unitType); // Save the unit type
  }

  Future<String> getCurrentUnitType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? 'metric'; // Retrieve the unit type or default to 'metric'
  }
}
