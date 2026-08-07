import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_models.dart';
import '../services/native_platform_service.dart';
import '../services/storage_service.dart';

class SettingsController extends StateNotifier<AppSettings> {
  SettingsController(this._storage) : super(_storage.loadSettings());

  final StorageService _storage;

  Future<void> _save(AppSettings next) async {
    state = next;
    await _storage.saveSettings(next);
  }

  Future<void> completeOnboarding({
    required List<InstalledApp> blockedApps,
    required List<InstalledApp> allowedApps,
    required bool strictModeDefault,
  }) async {
    final next = state.copyWith(
      onboardingComplete: true,
      blockedApps: blockedApps,
      allowedApps: allowedApps,
      defaultStrictMode: strictModeDefault,
    );
    await _save(next);
    await NativePlatformService.instance.persistBlockingConfiguration(next);
  }

  Future<void> setThemeMode(ThemeMode mode) async => _save(state.copyWith(themeMode: mode));
  Future<void> setDefaultStrictMode(bool enabled) async => _save(state.copyWith(defaultStrictMode: enabled));
  Future<void> setNotificationsEnabled(bool enabled) async => _save(state.copyWith(notificationsEnabled: enabled));

  Future<void> setBlockedApps(List<InstalledApp> apps) async {
    final next = state.copyWith(blockedApps: apps);
    await _save(next);
    await NativePlatformService.instance.persistBlockingConfiguration(next);
  }

  Future<void> setAllowedApps(List<InstalledApp> apps) async {
    final next = state.copyWith(allowedApps: apps);
    await _save(next);
    await NativePlatformService.instance.persistBlockingConfiguration(next);
  }

  Future<void> addScheduleWindow(ScheduledBlockWindow window) async {
    final next = state.copyWith(scheduledWindows: [...state.scheduledWindows, window]);
    await _save(next);
    await NativePlatformService.instance.persistBlockingConfiguration(next);
  }

  Future<void> removeScheduleWindow(String id) async {
    final next = state.copyWith(
      scheduledWindows: state.scheduledWindows.where((window) => window.id != id).toList(),
    );
    await _save(next);
    await NativePlatformService.instance.persistBlockingConfiguration(next);
  }

  Future<void> recordCompletedSession(Duration duration) async {
    final todayIso = DateUtils.dateOnly(DateTime.now()).toIso8601String();
    final isNewDay = state.lastSessionDateIso != todayIso;
    final next = state.copyWith(
      totalSessionsCompleted: state.totalSessionsCompleted + 1,
      focusedMinutesToday: state.focusedMinutesToday + duration.inMinutes,
      focusedMinutesThisWeek: state.focusedMinutesThisWeek + duration.inMinutes,
      timeSavedMinutesThisWeek: state.timeSavedMinutesThisWeek + (duration.inMinutes * 3 ~/ 4),
      currentStreakDays: isNewDay ? state.currentStreakDays + 1 : state.currentStreakDays,
      lastSessionDateIso: todayIso,
    );
    await _save(next);
  }
}
