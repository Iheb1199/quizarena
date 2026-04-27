import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../models/leaderboard_entry_model.dart';
import 'avatar_widget.dart';

class LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardEntryModel> entries;

  const LeaderboardPodium({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (entries.length >= 2) _buildPodiumItem(entries[1], 2, 80),
        if (entries.isNotEmpty) _buildPodiumItem(entries[0], 1, 110),
        if (entries.length >= 3) _buildPodiumItem(entries[2], 3, 60),
      ],
    );
  }

  Widget _buildPodiumItem(LeaderboardEntryModel entry, int rank, double height) {
    final colors = {
      1: const Color(0xFFFFD700),
      2: const Color(0xFFC0C0C0),
      3: const Color(0xFFCD7F32),
    };

    final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AvatarWidget(
            avatarUrl: entry.avatarUrl,
            displayName: entry.displayName,
            radius: rank == 1 ? 32 : 24,
          ),
          const SizedBox(height: 6),
          Text(
            entry.displayName,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${entry.score} pts',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 4),
          Text(medals[rank] ?? '', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Container(
            height: height,
            decoration: BoxDecoration(
              color: colors[rank]?.withOpacity(0.2),
              border: Border(
                top: BorderSide(color: colors[rank]!, width: 2),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: colors[rank],
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}