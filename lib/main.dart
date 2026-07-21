import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/native_platform_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.instance.init();
  await NotificationService.instance.init();
  await NativePlatformService.instance.initialize();
  runApp(const ProviderScope(child: FocusModeApp()));
}
