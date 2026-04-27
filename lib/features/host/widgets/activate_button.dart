import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/session_model.dart';
import '../../../shared/widgets/primary_button.dart';

class ActivateButton extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onActivate;
  final bool isLoading;

  const ActivateButton({
    super.key,
    required this.session,
    required this.onActivate,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!session.isPending) return const SizedBox.shrink();

    String? lockReason;
    if (session.questionCount < 10) {
      lockReason =
      'Need 10 questions to activate (${session.questionCount}/10)';
    } else if (session.participantCount < 2) {
      lockReason =
      'Need at least 2 players to activate (${session.participantCount}/2)';
    }

    return Column(
      children: [
        PrimaryButton(
          label: 'Activate Session',
          onPressed: lockReason == null ? onActivate : null,
          isLoading: isLoading,
          color: lockReason == null ? AppColors.success : AppColors.surface,
        ),
        if (lockReason != null) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                lockReason,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}