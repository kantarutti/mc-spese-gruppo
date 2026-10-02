import 'package:shared_preferences/shared_preferences.dart';

class TutorialService {
  // 🔹 Ritorna TRUE se il tutorial deve essere mostrato
  static Future<bool> shouldShow(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(key) ?? false;
    return !seen; // se non visto → mostra
  }

  // 🔹 Segna il tutorial come "visto"
  static Future<void> disable(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, true);
  }

  // 🔥 RESET
  static Future<void> reset(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, false);
  }


}
