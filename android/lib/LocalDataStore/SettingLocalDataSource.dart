import 'package:hive/hive.dart';

import '../Utils/Constant.dart';

class SettingsLocalDataSource {
  static bool showIntroSlider() {
    return Hive.box(settingsBox).get(showIntroSliderKey, defaultValue: true);
  }

  Future<void> setShowIntroSlider(bool value) async {
    print("introsliderval $value");
    Hive.box(settingsBox).put(showIntroSliderKey, value);
  }

  static bool getThemeSwitch() {
    return Hive.box(settingsBox).get(showThemeSwitchKey, defaultValue: false);
  }

  Future<void> setThemeSwitch(bool value) async {
    Hive.box(settingsBox).put(showThemeSwitchKey, value);
  }

  String theme() {
    return Hive.box(settingsBox)
        .get(settingsThemeKey, defaultValue: lightThemeKey);
  }

  Future<void> setTheme(String value) async {
    Hive.box(settingsBox).put(settingsThemeKey, value);
  }
}
