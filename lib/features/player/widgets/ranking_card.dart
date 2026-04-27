import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/helpers.dart';
import '../../../shared/widgets/avatar_widget.dart';

class RankingCard extends StatelessWidget {
  final String displayName;
  final String? avatarUrl;
  final int score;
  final int rank;

  const RankingCard({
    super.key,
    required this.displayName,
    this.avatarUrl,
    required this.score,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.6),
            AppColors.secondary.withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(Helpers.rankSuffix(rank),
              style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          AvatarWidget(
            avatarUrl: avatarUrl,
            displayName: displayName,
            radius: 36,
          ),
          const SizedBox(height: 12),
          Text(displayName, style: AppTypography.headingSmall),
          const SizedBox(height: 8),
          Text('$score pts', style: AppTypography.scoreStyle),
        ],
      ),
    );
  }
}