import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/motivation_messages.dart';
import '../models/app_models.dart';
import '../services/native_platform_service.dart';
import '../services/notification_service.dart';
import 'settings_controller.dart';

class FocusSessionState {
  const FocusSessionState({
    required this.active,
    required this.strictMode,
    required this.untilStopped,
    required this.pomodoroEnabled,
    required this.breakDuration,
    required this.duration,
    required this.elapsed,
    required this.currentMessage,
    required this.startedAt,
  });

  final bool active;
  final bool strictMode;
  final bool untilStopped;
  final bool pomodoroEnabled;
  final Duration breakDuration;
  final Duration duration;
  final Duration elapsed;
  final String currentMessage;
  final DateTime? startedAt;

  factory FocusSessionState.idle() {
    return const FocusSessionState(
      active: false,
      strictMode: false,
      untilStopped: false,
      pomodoroEnabled: false,
      breakDuration: Duration.zero,
      duration: Duration.zero,
      elapsed: Duration.zero,
      currentMessage: 'Ready when you are.',
      startedAt: null,
    );
  }

  FocusSessionState copyWith({
    bool? active,
    bool? strictMode,
    bool? untilStopped,
    bool? pomodoroEnabled,
    Duration? breakDuration,
    Duration? duration,
    Duration? elapsed,
    String? currentMessage,
    DateTime? startedAt,
  }) {
    return FocusSessionState(
      active: active ?? this.active,
      strictMode: strictMode ?? this.strictMode,
      untilStopped: untilStopped ?? this.untilStopped,
      pomodoroEnabled: pomodoroEnabled ?? this.pomodoroEnabled,
      breakDuration: breakDuration ?? this.breakDuration,
      duration: duration ?? this.duration,
      elapsed: elapsed ?? this.elapsed,
      currentMessage: currentMessage ?? this.currentMessage,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  double get progress {
    if (!active || duration.inSeconds == 0) {
      return 0;
    }
    return (elapsed.inSeconds / duration.inSeconds).clamp(0, 1);
  }

  Duration get remaining {
    final diff = duration - elapsed;
    return diff.isNegative ? Duration.zero : diff;
  }
}

class FocusSessionController extends StateNotifier<FocusSessionState> {
  FocusSessionController(this._settingsController) : super(FocusSessionState.idle());

  final SettingsController _settingsController;
  Timer? _timer;
  int _messageIndex = 0;

  Future<void> startSession(FocusSessionPlan plan) async {
    if (state.active) {
      return;
    }
    _messageIndex = (_messageIndex + 1) % motivationMessages.length;
    state = state.copyWith(
      active: true,
      strictMode: plan.strictMode,
      untilStopped: plan.untilStopped,
      pomodoroEnabled: plan.pomodoroEnabled,
      breakDuration: plan.breakDuration,
      duration: plan.duration,
      elapsed: Duration.zero,
      currentMessage: motivationMessages[_messageIndex],
      startedAt: DateTime.now(),
    );
    await NativePlatformService.instance.persistBlockingConfiguration(_settingsController.state);
    await NativePlatformService.instance.updateSessionState(
      active: true,
      strictMode: plan.strictMode,
      untilStopped: plan.untilStopped,
      durationMinutes: plan.duration.inMinutes,
      elapsedSeconds: 0,
      message: state.currentMessage,
      startedAtMillis: state.startedAt!.millisecondsSinceEpoch,
    );
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  Future<bool> stopSession({bool completed = false, bool earlyExit = false}) async {
    if (!state.active) {
      return true;
    }
    if (state.strictMode && earlyExit) {
      return false;
    }
    _timer?.cancel();
    _timer = null;
    final finishedState = state;
    state = FocusSessionState.idle();
    await NativePlatformService.instance.clearSessionState();
    if (completed) {
      await _settingsController.recordCompletedSession(finishedState.duration);
      await NotificationService.instance.showSessionComplete(minutes: finishedState.duration.inMinutes);
    }
    return true;
  }

  void _tick(Timer timer) {
    if (!state.active || state.startedAt == null) {
      timer.cancel();
      return;
    }
    final elapsed = DateTime.now().difference(state.startedAt!);
    if (!state.untilStopped && elapsed >= state.duration) {
      unawaited(stopSession(completed: true));
      return;
    }
    state = state.copyWith(elapsed: elapsed);
    unawaited(
      NativePlatformService.instance.updateSessionState(
        active: true,
        strictMode: state.strictMode,
        untilStopped: state.untilStopped,
        durationMinutes: state.duration.inMinutes,
        elapsedSeconds: elapsed.inSeconds,
        message: state.currentMessage,
        startedAtMillis: state.startedAt?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
