import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/focus_session_controller.dart';
import 'controllers/settings_controller.dart';
import 'services/native_platform_service.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService.instance);
final nativePlatformServiceProvider = Provider<NativePlatformService>((ref) => NativePlatformService.instance);
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService.instance);

final settingsControllerProvider = StateNotifierProvider<SettingsController, AppSettings>(
  (ref) => SettingsController(ref.read(storageServiceProvider)),
);

final focusSessionControllerProvider = StateNotifierProvider<FocusSessionController, FocusSessionState>(
  (ref) => FocusSessionController(ref.read(settingsControllerProvider.notifier)),
);
