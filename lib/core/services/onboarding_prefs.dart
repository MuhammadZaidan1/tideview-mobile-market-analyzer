import 'package:shared_preferences/shared_preferences.dart';

/// Helper kecil buat nyimpen status "user udah pernah pilih Guest mode"
/// di welcome screen, biar welcome screen gak muncul lagi tiap buka app.
class OnboardingPrefs {
  static const String _guestModeKey = 'has_chosen_guest_mode';

  static Future<bool> hasChosenGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestModeKey) ?? false;
  }

  static Future<void> setChosenGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, true);
  }
}
