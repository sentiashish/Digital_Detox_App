import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_apps.dart';
import '../../core/providers.dart';
import '../../core/services/native_platform_service.dart';
import '../../core/widgets/section_card.dart';
import '../onboarding/onboarding_flow.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final blocked = settings.blockedApps.isEmpty ? seededSampleApps().where((app) => !app.isEssential).toList() : settings.blockedApps;
    final allowed = settings.allowedApps.isEmpty ? seededSampleApps().where((app) => app.isEssential).toList() : settings.allowedApps;

    return CustomScrollView(
      slivers: [
        const SliverAppBar(pinned: true, title: Text('Settings')),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(value: ThemeMode.system, label: Text('System')),
                        ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                        ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                      ],
                      selected: {settings.themeMode},
                      onSelectionChanged: (value) => ref.read(settingsControllerProvider.notifier).setThemeMode(value.first),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Default strict mode'),
                      subtitle: const Text('Add friction before ending sessions early.'),
                      value: settings.defaultStrictMode,
                      onChanged: (value) => ref.read(settingsControllerProvider.notifier).setDefaultStrictMode(value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Notifications'),
                      subtitle: const Text('Gentle reminders and completion alerts.'),
                      value: settings.notificationsEnabled,
                      onChanged: (value) => ref.read(settingsControllerProvider.notifier).setNotificationsEnabled(value),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Allowed apps', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: allowed.map((app) => Chip(label: Text(app.name))).toList()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Blocked apps', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(spacing: 8, runSpacing: 8, children: blocked.map((app) => Chip(label: Text(app.name))).toList()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Permissions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    _PermissionRow(
                      title: 'Usage Access',
                      description: 'Detect the foreground app so the blocker can react immediately.',
                      actionLabel: 'Open',
                      onTap: NativePlatformService.instance.openUsageAccessSettings,
                    ),
                    _PermissionRow(
                      title: 'Accessibility',
                      description: 'Launch the blocking screen when a restricted app comes forward.',
                      actionLabel: 'Open',
                      onTap: NativePlatformService.instance.openAccessibilitySettings,
                    ),
                    _PermissionRow(
                      title: 'Overlay',
                      description: 'Show the block screen above the distracting app.',
                      actionLabel: 'Open',
                      onTap: NativePlatformService.instance.openOverlaySettings,
                    ),
                    _PermissionRow(
                      title: 'Battery optimization',
                      description: 'Improve reliability for scheduled blocking.',
                      actionLabel: 'Open',
                      onTap: NativePlatformService.instance.openBatteryOptimizationSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OnboardingFlow(isResumingSetup: true))),
                child: const Text('Review setup flow'),
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.title, required this.description, required this.actionLabel, required this.onTap});

  final String title;
  final String description;
  final String actionLabel;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(description),
      trailing: TextButton(
        onPressed: () {
          onTap();
        },
        child: Text(actionLabel),
      ),
    );
  }
}
