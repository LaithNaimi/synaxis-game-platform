import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class RoundTimerWidget extends StatefulWidget {
  const RoundTimerWidget({
    super.key,
    required this.roundDurationSeconds,
    required this.roundStartedAt,
    this.suddenDeath = false,
    this.suddenDeathAt,
    this.stopped = false,
  });

  final int roundDurationSeconds;
  final DateTime? roundStartedAt;
  final bool suddenDeath;
  final DateTime? suddenDeathAt;
  final bool stopped;

  @override
  State<RoundTimerWidget> createState() => _RoundTimerWidgetState();
}

class _RoundTimerWidgetState extends State<RoundTimerWidget> {
  Timer? _ticker;
  int _secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _computeSecondsLeft();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!widget.stopped) {
        _computeSecondsLeft();
      }
    });
  }

  @override
  void didUpdateWidget(covariant RoundTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _computeSecondsLeft();
  }

  void _computeSecondsLeft() {
    if (widget.stopped) return;

    final now = DateTime.now();

    if (widget.suddenDeath && widget.suddenDeathAt != null) {
      final diff = widget.suddenDeathAt!.difference(now).inSeconds;
      setState(() => _secondsLeft = diff.clamp(0, 999));
      return;
    }

    if (widget.roundStartedAt != null) {
      final elapsed = now.difference(widget.roundStartedAt!).inSeconds;
      final remaining = widget.roundDurationSeconds - elapsed;
      setState(() =>
          _secondsLeft = remaining.clamp(0, widget.roundDurationSeconds));
      return;
    }

    setState(() => _secondsLeft = widget.roundDurationSeconds);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLow = _secondsLeft <= 10;
    final isSuddenDeath = widget.suddenDeath;

    Color timerColor;
    if (isSuddenDeath) {
      timerColor = AppColors.error;
    } else if (isLow) {
      timerColor = AppColors.warning;
    } else {
      timerColor = AppColors.primary;
    }

    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    final display = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isSuddenDeath)
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(right: AppSpacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.error,
            ),
          )
        else
          Icon(
            Icons.timer_outlined,
            color: timerColor,
            size: 16,
          ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          display,
          style: AppTextStyles.bodyBold.copyWith(
            color: timerColor,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
