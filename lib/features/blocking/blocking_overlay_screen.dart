import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/motivation_messages.dart';
import '../../core/providers.dart';
import '../../core/widgets/section_card.dart';

class BlockingOverlayScreen extends ConsumerStatefulWidget {
  const BlockingOverlayScreen({super.key});

  static const String routeName = '/blocked';

  @override
  ConsumerState<BlockingOverlayScreen> createState() => _BlockingOverlayScreenState();
}
class _BlockingOverlayScreenState extends ConsumerState<BlockingOverlayScreen> {
  final TextEditingController _controller = TextEditingController();
  String _message = motivationMessages.first;

  @override
  void initState() {
    super.initState();
    _message = motivationMessages[DateTime.now().second % motivationMessages.length];
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(focusSessionControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final strictMode = session.strictMode || settings.defaultStrictMode;
    const unlockSentence = 'I choose focus now';

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.15),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This app is paused for now',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text('Your focus session is protecting your attention. $_message'),
                      const SizedBox(height: 16),
                      if (session.active)
                        _StatLine(label: 'Focused time', value: _format(session.elapsed))
                      else
                        const _StatLine(label: 'Focused time', value: '0m'),
                      const SizedBox(height: 8),
                      _StatLine(label: 'Mode', value: strictMode ? 'Strict' : 'Standard'),
                      const SizedBox(height: 16),
                      if (strictMode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type the sentence below to continue', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(unlockSentence, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _controller,
                              onChanged: (_) => setState(() {}),
                              decoration: const InputDecoration(hintText: 'Type here'),
                            ),
                            
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _controller.text.trim() == unlockSentence ? () => Navigator.of(context).maybePop() : null,
                                child: const Text('I understand'),
                              ),
                            ),
                          ],
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('Return to home screen'),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => SystemNavigator.pop(),
                        child: const Text('Close blocker'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _format(Duration duration) => '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
}

class _StatLine extends StatelessWidget {
  const _StatLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}
