import 'package:shared_preferences/shared_preferences.dart';


/// A service class for managing user settings.
class SettingsService {

  // Key used to store the unit type in shared preferences.
  static const _unitKey = 'unitType'; // Key to store the unit type

  /// Updates the unit type in the application settings.
  ///
  /// This method updates the unit type based on the provided [unitType] string.
  /// The unit type is stored in the shared preferences for persistence.
  ///
  /// [unitType] The unit type to be saved (e.g., 'metric', 'imperial').
  Future<void> updateUnitTypeFromSettings(String unitType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_unitKey, unitType); // Save the unit type
  }


  /// Retrieves the current unit type from the application settings.
  ///
  /// This method returns the current unit type stored in the shared preferences.
  /// If no unit type is set, it defaults to 'metric'.
  ///
  /// Returns a [Future] that resolves to a [String] representing the unit type.
  Future<String> getCurrentUnitType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_unitKey) ?? 'metric'; // Retrieve the unit type or default to 'metric'
  }


}