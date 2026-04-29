import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/leaderboard_entry_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../services/player_service.dart';
import '../../../services/session_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../player/screens/player_dashboard_screen.dart';

class ResultScreen extends StatefulWidget {
  final String sessionId;
  final String participantId;

  const ResultScreen({
    super.key,
    required this.sessionId,
    required this.participantId,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final _playerService = PlayerService();
  List<LeaderboardEntryModel> _entries = [];
  int _myRank = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final entries = await _playerService.getLeaderboard(widget.sessionId);

    await SessionService().leaveRoom(
      sessionId: widget.sessionId,
      playerId: user.id,
    );

    final index = entries.indexWhere((e) => e.playerId == user.id);

    if (mounted) {
      setState(() {
        _entries = entries;
        _myRank = index >= 0 ? index + 1 : entries.length + 1;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final user = context.watch<AuthProvider>().user;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _isLoading
              ? const LoadingIndicator()
              : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text('Session Over!', style: AppTypography.headingLarge),
                const SizedBox(height: 4),
                Text(
                  'Final Standings',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 40),

                // Podium
                _buildPodium(),

                const SizedBox(height: 32),

                // My result card
                _buildMyResult(user?.displayName ?? 'You', quiz.score),

                const SizedBox(height: 40),

                // Back to dashboard button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      quiz.reset();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const PlayerDashboardScreen(),
                        ),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.dashboard),
                    label: const Text('Back to Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPodium() {
    if (_entries.isEmpty) return const SizedBox.shrink();

    final first = _entries.isNotEmpty ? _entries[0] : null;
    final second = _entries.length > 1 ? _entries[1] : null;
    final third = _entries.length > 2 ? _entries[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2nd place
        if (second != null)
          _buildPodiumSlot(
            entry: second,
            height: 100,
            color: const Color(0xFFC0C0C0),
            medalEmoji: '🥈',
          ),

        const SizedBox(width: 8),

        // 1st place
        if (first != null)
          _buildPodiumSlot(
            entry: first,
            height: 140,
            color: const Color(0xFFFFD700),
            medalEmoji: '🥇',
          ),

        const SizedBox(width: 8),

        // 3rd place
        if (third != null)
          _buildPodiumSlot(
            entry: third,
            height: 80,
            color: const Color(0xFFCD7F32),
            medalEmoji: '🥉',
          ),
      ],
    );
  }

  Widget _buildPodiumSlot({
    required LeaderboardEntryModel entry,
    required double height,
    required Color color,
    required String medalEmoji,
  }) {
    final isMe = entry.rank == _myRank;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Medal
          Text(medalEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),

          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isMe ? AppColors.accent : color,
                width: isMe ? 3 : 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              backgroundColor: AppColors.surface,
              child: entry.avatarUrl == null
                  ? Text(
                entry.displayName[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              )
                  : null,
            ),
          ),
          const SizedBox(height: 4),

          // Name
          Text(
            isMe ? 'You' : entry.displayName,
            style: TextStyle(
              color: isMe ? AppColors.accent : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Score
          Text(
            '${entry.score} pts',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 6),

          // Podium block
          Container(
            height: height,
            decoration: BoxDecoration(
              color: color.withOpacity(0.85),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyResult(String displayName, int score) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.accent.withOpacity(0.2),
            child: Text(
              '#$_myRank',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Result', style: AppTypography.bodySecondary),
                Text(displayName, style: AppTypography.headingSmall),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$score pts',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                _myRank == 1
                    ? '🏆 Winner!'
                    : _myRank == 2
                    ? '🥈 Runner-up'
                    : _myRank == 3
                    ? '🥉 Third place'
                    : 'Keep it up!',
                style: AppTypography.bodySecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}