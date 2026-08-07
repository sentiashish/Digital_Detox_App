import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/controllers/focus_session_controller.dart';
import '../../core/models/app_models.dart';
import '../../core/providers.dart';
import '../../core/widgets/section_card.dart';
import '../../core/widgets/stat_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final session = ref.watch(focusSessionControllerProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: const Text('Focus Mode'),
          actions: [
            IconButton(
              onPressed: () => ref.read(settingsControllerProvider.notifier).setThemeMode(
                    settings.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
                  ),
              icon: Icon(settings.themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protect your attention without fighting your phone.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a calm focus block, keep essential apps available, and let the blocker do the hard part.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonalIcon(
                        onPressed: session.active ? null : () => _openSessionPicker(context, ref),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 14),
                          child: Text('Start Focus Session'),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Motivation', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(session.currentMessage),
                    const SizedBox(height: 8),
                    Text(
                      session.active ? 'Session running now' : 'No session active right now',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (session.active)
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current session', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(value: session.progress),
                      const SizedBox(height: 8),
                      Text('${_formatDuration(session.elapsed)} focused · ${_formatDuration(session.remaining)} left'),
                      const SizedBox(height: 8),
                      Text(session.currentMessage, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => ref.read(focusSessionControllerProvider.notifier).stopSession(earlyExit: true),
                              child: const Text('Stop session'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              if (session.active) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Today',
                      value: '${settings.focusedMinutesToday} min',
                      icon: Icons.hourglass_bottom_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Streak',
                      value: '${settings.currentStreakDays} day${settings.currentStreakDays == 1 ? '' : 's'}',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'Sessions',
                      value: '${settings.totalSessionsCompleted}',
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Saved',
                      value: '${settings.timeSavedMinutesThisWeek} min',
                      icon: Icons.savings_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick access', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.block_rounded, size: 18),
                          label: const Text('Blocked apps'),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Use the Settings tab to manage app lists.')),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.schedule_rounded, size: 18),
                          label: const Text('Schedules'),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Scheduling comes in the next stage.')),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.security_rounded, size: 18),
                          label: const Text('Permissions'),
                          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Open Settings to review permissions.')),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _openSessionPicker(BuildContext context, WidgetRef ref) async {
    final plan = await showModalBottomSheet<FocusSessionPlan>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _SessionPickerSheet(),
    );
    if (plan == null || !context.mounted) {
      return;
    }
    await ref.read(focusSessionControllerProvider.notifier).startSession(plan);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours == 0) {
      return '${duration.inMinutes}m';
    }
    return '${hours}h ${minutes}m';
  }
}

class _SessionPickerSheet extends StatefulWidget {
  const _SessionPickerSheet();

  @override
  State<_SessionPickerSheet> createState() => _SessionPickerSheetState();
}

class _SessionPickerSheetState extends State<_SessionPickerSheet> {
  int _selectedMinutes = 25;
  bool _strictMode = false;
  bool _untilStopped = false;
  bool _pomodoro = false;

  @override
  Widget build(BuildContext context) {
    final options = [25, 50, 90];
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 4, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose a focus block', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: options
                  .map(
                    (value) => ChoiceChip(
                      label: Text('$value min'),
                      selected: _selectedMinutes == value && !_untilStopped,
                      onSelected: (_) => setState(() {
                        _untilStopped = false;
                        _selectedMinutes = value;
                      }),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Until I stop it'),
              value: _untilStopped,
              onChanged: (value) => setState(() => _untilStopped = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Strict mode'),
              subtitle: const Text('Add friction before ending early.'),
              value: _strictMode,
              onChanged: (value) => setState(() => _strictMode = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pomodoro style'),
              subtitle: const Text('Saved for the next stage of the engine.'),
              value: _pomodoro,
              onChanged: (value) => setState(() => _pomodoro = value),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop(
                    FocusSessionPlan(
                      duration: Duration(minutes: _selectedMinutes),
                      strictMode: _strictMode,
                      untilStopped: _untilStopped,
                      pomodoroEnabled: _pomodoro,
                      breakDuration: const Duration(minutes: 5),
                    ),
                  );
                },
                child: const Text('Start session'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
