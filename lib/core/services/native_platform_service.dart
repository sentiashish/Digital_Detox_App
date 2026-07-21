import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/sample_apps.dart';
import '../models/app_models.dart';

class NativePlatformService {
  NativePlatformService._();

  static final NativePlatformService instance = NativePlatformService._();

  static const MethodChannel _channel = MethodChannel('focus_mode/blocking');

  Future<void> initialize() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _channel.invokeMethod<void>('initialize');
    } on MissingPluginException {
      return;
    }
  }

  Future<List<InstalledApp>> fetchInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (result == null) {
        return seededSampleApps();
      }
      return result
          .whereType<Map>()
          .map((item) => InstalledApp.fromJson(Map<String, dynamic>.from(item.cast<String, dynamic>())))
          .toList();
    } on MissingPluginException {
      return seededSampleApps();
    }
  }

  Future<void> persistBlockingConfiguration(AppSettings settings) async {
    try {
      await _channel.invokeMethod<void>('configureBlocking', jsonEncode(settings.toJson()));
    } on MissingPluginException {
      return;
    }
  }

  Future<void> openUsageAccessSettings() async => _invokeVoid('openUsageAccessSettings');
  Future<void> openAccessibilitySettings() async => _invokeVoid('openAccessibilitySettings');
  Future<void> openOverlaySettings() async => _invokeVoid('openOverlaySettings');
  Future<void> openBatteryOptimizationSettings() async => _invokeVoid('openBatteryOptimizationSettings');
  Future<void> requestNotificationPermission() async => _invokeVoid('requestNotificationPermission');

  Future<void> _invokeVoid(String method) async {
    try {
      await _channel.invokeMethod<void>(method);
    } on MissingPluginException {
      return;
    }
  }
}
