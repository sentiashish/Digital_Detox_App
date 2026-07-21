import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/sample_apps.dart';
import '../../core/models/app_models.dart';
import '../../core/providers.dart';
import '../../core/services/native_platform_service.dart';
import '../../core/widgets/section_card.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key, this.isResumingSetup = false});

  final bool isResumingSetup;

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _controller = PageController();
  List<InstalledApp> _installedApps = seededSampleApps();
  final Set<String> _blockedPackages = <String>{};
  final Set<String> _allowedPackages = <String>{};
  bool _strictMode = false;
  bool _loading = true;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final apps = await NativePlatformService.instance.fetchInstalledApps();
    if (!mounted) {
      return;
    }
    final allowedHints = defaultAllowedPackageHints;
    final blockedHints = defaultBlockedPackageHints;
    setState(() {
      _installedApps = apps;
      _allowedPackages.addAll(apps.where((app) => allowedHints.any((hint) => _matches(app, hint))).map((app) => app.packageName));
      _blockedPackages.addAll(apps.where((app) => blockedHints.any((hint) => _matches(app, hint))).map((app) => app.packageName));
      _loading = false;
    });
  }

  bool _matches(InstalledApp app, String hint) {
    final target = '${app.name} ${app.packageName}'.toLowerCase();
    return target.contains(hint);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _IntroPage(onNext: _next),
      _AppSelectionPage(
        title: 'Choose distracting apps',
        subtitle: 'Select the apps you want Focus Mode to block during sessions.',
        apps: _installedApps,
        isSelected: (app) => _blockedPackages.contains(app.packageName),
        onToggle: (app, enabled) {
          setState(() {
            if (enabled) {
              _blockedPackages.add(app.packageName);
            } else {
              _blockedPackages.remove(app.packageName);
            }
          });
        },
        onNext: _next,
        onBack: _back,
      ),
      _AppSelectionPage(
        title: 'Choose always allowed apps',
        subtitle: 'These stay available even while focus is active.',
        apps: _installedApps,
        isSelected: (app) => _allowedPackages.contains(app.packageName) || app.isEssential,
        onToggle: (app, enabled) {
          if (app.isEssential) {
            return;
          }
          setState(() {
            if (enabled) {
              _allowedPackages.add(app.packageName);
            } else {
              _allowedPackages.remove(app.packageName);
            }
          });
        },
        onNext: _next,
        onBack: _back,
      ),
      _PermissionPage(
        strictMode: _strictMode,
        onStrictChanged: (value) => setState(() => _strictMode = value),
        onFinish: _finish,
        onBack: _back,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isResumingSetup ? 'Setup review' : 'Welcome'),
        automaticallyImplyLeading: widget.isResumingSetup,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PageView(
              controller: _controller,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
            ),
    );
  }

  void _next() {
    if (_page < 3) {
      setState(() => _page++);
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _back() {
    if (_page > 0) {
      setState(() => _page--);
      _controller.previousPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  Future<void> _finish() async {
    final blocked = _installedApps.where((app) => _blockedPackages.contains(app.packageName)).toList();
    final allowed = _installedApps.where((app) => _allowedPackages.contains(app.packageName) || app.isEssential).toList();
    await ref.read(settingsControllerProvider.notifier).completeOnboarding(
          blockedApps: blocked,
          allowedApps: allowed,
          strictModeDefault: _strictMode,
        );
    await NativePlatformService.instance.requestNotificationPermission();
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.onNext});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      title: 'Make distraction harder, not willpower heavier.',
      subtitle: 'Focus Mode blocks distracting apps during chosen windows and keeps the essentials within reach.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _Bullet('Calm focus sessions with strict mode when you need it'),
          _Bullet('Essential apps stay available'),
          _Bullet('Usage, streak, and session tracking stay on device'),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: FilledButton(onPressed: onNext, child: const Text('Continue'))),
        ],
      ),
    );
  }
}

class _AppSelectionPage extends StatelessWidget {
  const _AppSelectionPage({
    required this.title,
    required this.subtitle,
    required this.apps,
    required this.isSelected,
    required this.onToggle,
    required this.onNext,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final List<InstalledApp> apps;
  final bool Function(InstalledApp app) isSelected;
  final void Function(InstalledApp app, bool enabled) onToggle;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      title: title,
      subtitle: subtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: apps
                .map(
                  (app) => FilterChip(
                    selected: isSelected(app),
                    label: Text(app.name),
                    onSelected: (value) => onToggle(app, value),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
              const SizedBox(width: 12),
              Expanded(child: FilledButton(onPressed: onNext, child: const Text('Next'))),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionPage extends StatelessWidget {
  const _PermissionPage({
    required this.strictMode,
    required this.onStrictChanged,
    required this.onFinish,
    required this.onBack,
  });

  final bool strictMode;
  final ValueChanged<bool> onStrictChanged;
  final Future<void> Function() onFinish;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return _OnboardingFrame(
      title: 'Permissions with clear reasons',
      subtitle: 'Each permission is explained before the system prompt or settings screen opens.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PermissionCard(
            title: 'Usage Access',
            body: 'Needed to notice when a distracting app comes into the foreground.',
          ),
          const _PermissionCard(
            title: 'Accessibility Service',
            body: 'Used only to trigger the blocking screen when a restricted app is opened.',
          ),
          const _PermissionCard(
            title: 'Overlay',
            body: 'Lets the blocker appear over distracting apps instead of just showing a toast.',
          ),
          const _PermissionCard(
            title: 'Notifications',
            body: 'Used for reminders, session completion, and calm nudges.',
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Strict mode by default'),
            subtitle: const Text('Add friction before ending a session early.'),
            value: strictMode,
            onChanged: onStrictChanged,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: OutlinedButton(onPressed: onBack, child: const Text('Back'))),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    onFinish();
                  },
                  child: const Text('Finish setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OnboardingFrame extends StatelessWidget {
  const _OnboardingFrame({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(subtitle),
            const SizedBox(height: 20),
            Expanded(child: SingleChildScrollView(child: child)),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        tileColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
        title: Text(title),
        subtitle: Text(body),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
