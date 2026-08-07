import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/providers.dart';
giimport 'core/theme/app_theme.dart';
import 'features/blocking/blocking_overlay_screen.dart';
import 'features/navigation/app_shell.dart';
import 'features/onboarding/onboarding_flow.dart';

class FocusModeApp extends ConsumerWidget {
  const FocusModeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Mode',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: settings.themeMode,
      routes: {
        BlockingOverlayScreen.routeName: (_) => const BlockingOverlayScreen(),
      },
      
      home: settings.onboardingComplete ? const AppShell() : const  OnboardingFlow(),
    );
  }
}
