import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../services/session_service.dart';

class SessionCard extends StatelessWidget {
  final SessionModel session;
  final VoidCallback onTap;

  const SessionCard({
    super.key,
    required this.session,
    required this.onTap,
  });

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'finished':
        return AppColors.textSecondary;
      default:
        return AppColors.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor(session.status).withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.quiz, color: AppColors.accent),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.label, style: AppTypography.headingSmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      StreamBuilder<int>(
                        stream: SessionService().listenToParticipantCount(session.id),
                        builder: (context, snapshot) {
                          final count = snapshot.data ?? session.participantCount;

                          return Text(
                            '$count',
                            style: AppTypography.bodySecondary,
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.quiz,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text('${session.questionCount}/10',
                          style: AppTypography.bodySecondary),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(session.status).withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                session.status.toUpperCase(),
                style: TextStyle(
                  color: _statusColor(session.status),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}