import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_models.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const String _boxName = 'focus_mode';
  static const String _settingsKey = 'app_settings';

  late Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  AppSettings loadSettings() {
    final raw = _box.get(_settingsKey);
    if (raw is Map<dynamic, dynamic>) {
      return AppSettings.fromJson(Map<String, dynamic>.from(raw));
    }
    if (raw is Map<String, dynamic>) {
      return AppSettings.fromJson(raw);
    }
    return AppSettings.initial();
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _box.put(_settingsKey, settings.toJson());
  }
}
