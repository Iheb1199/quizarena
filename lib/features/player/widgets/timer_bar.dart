import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class TimerBar extends StatelessWidget {
  final int secondsLeft;
  final int totalSeconds;

  const TimerBar({
    super.key,
    required this.secondsLeft,
    this.totalSeconds = 20, // changed from 60 to 20
  });

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / totalSeconds;
    final color = secondsLeft <= 5
        ? AppColors.error
        : secondsLeft <= 10
        ? Colors.orange
        : AppColors.accent;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.timer,
                color: AppColors.textSecondary, size: 18),
            Text(
              '$secondsLeft s',
              style: AppTypography.timerStyle.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}