import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';

class SessionJoinCard extends StatelessWidget {
  final SessionModel session;
  final bool isEnrolled;
  final VoidCallback onJoin;
  final VoidCallback onResume;
  final VoidCallback onLeave;

  const SessionJoinCard({
    super.key,
    required this.session,
    required this.isEnrolled,
    required this.onJoin,
    required this.onResume,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEnrolled
              ? AppColors.success.withOpacity(0.4)
              : AppColors.accent.withOpacity(0.2),
          width: isEnrolled ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row — icon + label + action button
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isEnrolled
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEnrolled ? Icons.how_to_reg : Icons.quiz,
                  color: isEnrolled ? AppColors.success : AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.label,
                      style: AppTypography.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isEnrolled)
                      const Text(
                        'You are enrolled',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),

              // Join or Enter button
              ElevatedButton(
                onPressed: isEnrolled ? onResume : onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isEnrolled ? AppColors.success : AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEnrolled ? 'Enter' : 'Join',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Session ID row with copy button
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.tag,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    session.id,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: session.id));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Session ID copied!'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  child: const Icon(Icons.copy,
                      size: 14, color: AppColors.accent),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Bottom row — participant count + leave button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${session.participantCount} joined',
                    style: AppTypography.bodySecondary,
                  ),
                ],
              ),
              if (isEnrolled)
                GestureDetector(
                  onTap: onLeave,
                  child: const Row(
                    children: [
                      Icon(Icons.exit_to_app,
                          size: 14, color: AppColors.error),
                      SizedBox(width: 4),
                      Text(
                        'Leave session',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}