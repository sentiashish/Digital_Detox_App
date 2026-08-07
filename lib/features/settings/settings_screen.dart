import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_apps.dart';
import '../../core/models/app_models.dart';
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
                    Text('Scheduled blocks', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(
                      'Recurring windows keep distracting apps paused automatically. These stay saved on the device.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    if (settings.scheduledWindows.isEmpty)
                      const Text('No schedules yet. Add one for study hours or night mode.')
                    else
                      Column(
                        children: settings.scheduledWindows
                            .map(
                              (window) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(window.title),
                                subtitle: Text('${window.weekdayLabel} · ${window.timeLabel}${window.strictMode ? ' · strict' : ''}'),
                                leading: Icon(window.enabled ? Icons.event_available_rounded : Icons.event_busy_rounded),
                                trailing: IconButton(
                                  onPressed: () => ref.read(settingsControllerProvider.notifier).removeScheduleWindow(window.id),
                                  icon: const Icon(Icons.delete_outline_rounded),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonalIcon(
                            onPressed: () async {
                              final schedule = await showModalBottomSheet<ScheduledBlockWindow>(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                builder: (_) => const _ScheduleComposerSheet(),
                              );
                              if (schedule != null && context.mounted) {
                                await ref.read(settingsControllerProvider.notifier).addScheduleWindow(schedule);
                              }
                            },
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add schedule'),
                          ),
                        ),
                      ],
                    ),
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

class _ScheduleComposerSheet extends StatefulWidget {
  const _ScheduleComposerSheet();

  @override
  State<_ScheduleComposerSheet> createState() => _ScheduleComposerSheetState();
}

class _ScheduleComposerSheetState extends State<_ScheduleComposerSheet> {
  final TextEditingController _titleController = TextEditingController(text: 'Study hours');
  TimeOfDay _start = const TimeOfDay(hour: 21, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 7, minute: 0);
  final Set<int> _weekdays = {1, 2, 3, 4, 5, 6, 7};
  bool _strictMode = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekdayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add schedule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final selected = await showTimePicker(context: context, initialTime: _start);
                      if (selected != null) {
                        setState(() => _start = selected);
                      }
                    },
                    child: Text('Start ${_start.format(context)}'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final selected = await showTimePicker(context: context, initialTime: _end);
                      if (selected != null) {
                        setState(() => _end = selected);
                      }
                    },
                    child: Text('End ${_end.format(context)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: weekdayLabels.asMap().entries.map((entry) {
                final dayIndex = entry.key + 1;
                final label = entry.value;
                return FilterChip(
                  label: Text(label),
                  selected: _weekdays.contains(dayIndex),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _weekdays.add(dayIndex);
                      } else {
                        _weekdays.remove(dayIndex);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Strict mode for this schedule'),
              subtitle: const Text('Adds friction before ending early.'),
              value: _strictMode,
              onChanged: (value) => setState(() => _strictMode = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _weekdays.isEmpty
                    ? null
                    : () {
                        final schedule = ScheduledBlockWindow(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          title: _titleController.text.trim().isEmpty ? 'Scheduled block' : _titleController.text.trim(),
                          startMinutes: _start.hour * 60 + _start.minute,
                          endMinutes: _end.hour * 60 + _end.minute,
                          weekdays: _weekdays.toList()..sort(),
                          strictMode: _strictMode,
                        );
                        Navigator.of(context).pop(schedule);
                      },
                child: const Text('Save schedule'),
              ),
            ),
          ],
        ),
      ),
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
