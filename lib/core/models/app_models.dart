import 'dart:convert';

import 'package:flutter/material.dart';

class InstalledApp {
  const InstalledApp({
    required this.name,
    required this.packageName,
    this.isEssential = false,
    this.isSystemApp = false,
  });

  final String name;
  final String packageName;
  final bool isEssential;
  final bool isSystemApp;

  Map<String, dynamic> toJson() => {
        'name': name,
        'packageName': packageName,
        'isEssential': isEssential,
        'isSystemApp': isSystemApp,
      };

  factory InstalledApp.fromJson(Map<String, dynamic> json) {
    return InstalledApp(
      name: json['name'] as String,
      packageName: json['packageName'] as String,
      isEssential: json['isEssential'] as bool? ?? false,
      isSystemApp: json['isSystemApp'] as bool? ?? false,
    );
  }
}

class ScheduledBlockWindow {
  const ScheduledBlockWindow({
    required this.id,
    required this.title,
    required this.startMinutes,
    required this.endMinutes,
    required this.weekdays,
    this.enabled = true,
    this.strictMode = false,
  });

  final String id;
  final String title;
  final int startMinutes;
  final int endMinutes;
  final List<int> weekdays;
  final bool enabled;
  final bool strictMode;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'startMinutes': startMinutes,
        'endMinutes': endMinutes,
        'weekdays': weekdays,
        'enabled': enabled,
        'strictMode': strictMode,
      };

  factory ScheduledBlockWindow.fromJson(Map<String, dynamic> json) {
    return ScheduledBlockWindow(
      id: json['id'] as String,
      title: json['title'] as String,
      startMinutes: json['startMinutes'] as int,
      endMinutes: json['endMinutes'] as int,
      weekdays: (json['weekdays'] as List<dynamic>).cast<int>(),
      enabled: json['enabled'] as bool? ?? true,
      strictMode: json['strictMode'] as bool? ?? false,
    );
  }
}

class FocusSessionPlan {
  const FocusSessionPlan({
    required this.duration,
    required this.strictMode,
    required this.untilStopped,
    required this.pomodoroEnabled,
    required this.breakDuration,
  });

  final Duration duration;
  final bool strictMode;
  final bool untilStopped;
  final bool pomodoroEnabled;
  final Duration breakDuration;

  String get label {
    if (untilStopped) {
      return 'Until I stop it';
    }
    return '${duration.inMinutes} min';
  }
}

class AppSettings {
  const AppSettings({
    required this.onboardingComplete,
    required this.themeMode,
    required this.defaultStrictMode,
    required this.notificationsEnabled,
    required this.blockedApps,
    required this.allowedApps,
    required this.scheduledWindows,
    required this.currentStreakDays,
    required this.totalSessionsCompleted,
    required this.focusedMinutesToday,
    required this.focusedMinutesThisWeek,
    required this.timeSavedMinutesThisWeek,
    required this.lastSessionDateIso,
  });

  final bool onboardingComplete;
  final ThemeMode themeMode;
  final bool defaultStrictMode;
  final bool notificationsEnabled;
  final List<InstalledApp> blockedApps;
  final List<InstalledApp> allowedApps;
  final List<ScheduledBlockWindow> scheduledWindows;
  final int currentStreakDays;
  final int totalSessionsCompleted;
  final int focusedMinutesToday;
  final int focusedMinutesThisWeek;
  final int timeSavedMinutesThisWeek;
  final String? lastSessionDateIso;

  factory AppSettings.initial() {
    return const AppSettings(
      onboardingComplete: false,
      themeMode: ThemeMode.system,
      defaultStrictMode: false,
      notificationsEnabled: true,
      blockedApps: <InstalledApp>[],
      allowedApps: <InstalledApp>[],
      scheduledWindows: <ScheduledBlockWindow>[],
      currentStreakDays: 0,
      totalSessionsCompleted: 0,
      focusedMinutesToday: 0,
      focusedMinutesThisWeek: 0,
      timeSavedMinutesThisWeek: 0,
      lastSessionDateIso: null,
    );
  }

  AppSettings copyWith({
    bool? onboardingComplete,
    ThemeMode? themeMode,
    bool? defaultStrictMode,
    bool? notificationsEnabled,
    List<InstalledApp>? blockedApps,
    List<InstalledApp>? allowedApps,
    List<ScheduledBlockWindow>? scheduledWindows,
    int? currentStreakDays,
    int? totalSessionsCompleted,
    int? focusedMinutesToday,
    int? focusedMinutesThisWeek,
    int? timeSavedMinutesThisWeek,
    String? lastSessionDateIso,
  }) {
    return AppSettings(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      themeMode: themeMode ?? this.themeMode,
      defaultStrictMode: defaultStrictMode ?? this.defaultStrictMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      blockedApps: blockedApps ?? this.blockedApps,
      allowedApps: allowedApps ?? this.allowedApps,
      scheduledWindows: scheduledWindows ?? this.scheduledWindows,
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      totalSessionsCompleted: totalSessionsCompleted ?? this.totalSessionsCompleted,
      focusedMinutesToday: focusedMinutesToday ?? this.focusedMinutesToday,
      focusedMinutesThisWeek: focusedMinutesThisWeek ?? this.focusedMinutesThisWeek,
      timeSavedMinutesThisWeek: timeSavedMinutesThisWeek ?? this.timeSavedMinutesThisWeek,
      lastSessionDateIso: lastSessionDateIso ?? this.lastSessionDateIso,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingComplete': onboardingComplete,
        'themeMode': themeMode.index,
        'defaultStrictMode': defaultStrictMode,
        'notificationsEnabled': notificationsEnabled,
        'blockedApps': blockedApps.map((app) => app.toJson()).toList(),
        'allowedApps': allowedApps.map((app) => app.toJson()).toList(),
        'scheduledWindows': scheduledWindows.map((window) => window.toJson()).toList(),
        'currentStreakDays': currentStreakDays,
        'totalSessionsCompleted': totalSessionsCompleted,
        'focusedMinutesToday': focusedMinutesToday,
        'focusedMinutesThisWeek': focusedMinutesThisWeek,
        'timeSavedMinutesThisWeek': timeSavedMinutesThisWeek,
        'lastSessionDateIso': lastSessionDateIso,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      themeMode: ThemeMode.values[(json['themeMode'] as int?) ?? ThemeMode.system.index],
      defaultStrictMode: json['defaultStrictMode'] as bool? ?? false,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      blockedApps: (json['blockedApps'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(InstalledApp.fromJson)
          .toList(),
      allowedApps: (json['allowedApps'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(InstalledApp.fromJson)
          .toList(),
      scheduledWindows: (json['scheduledWindows'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(ScheduledBlockWindow.fromJson)
          .toList(),
      currentStreakDays: json['currentStreakDays'] as int? ?? 0,
      totalSessionsCompleted: json['totalSessionsCompleted'] as int? ?? 0,
      focusedMinutesToday: json['focusedMinutesToday'] as int? ?? 0,
      focusedMinutesThisWeek: json['focusedMinutesThisWeek'] as int? ?? 0,
      timeSavedMinutesThisWeek: json['timeSavedMinutesThisWeek'] as int? ?? 0,
      lastSessionDateIso: json['lastSessionDateIso'] as String?,
    );
  }
}

String encodeJson(Map<String, dynamic> json) => jsonEncode(json);

Map<String, dynamic> decodeJson(String jsonString) => jsonDecode(jsonString) as Map<String, dynamic>;
