import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/quiz_provider.dart';
import '../../../services/player_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/ranking_card.dart';

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
  int _rank = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRank();
  }

  Future<void> _loadRank() async {
    final entries = await _playerService.getLeaderboard(widget.sessionId);
    final user = context.read<AuthProvider>().user;

    if (user != null) {
      final index =
      entries.indexWhere((e) => e.playerId == user.id);
      setState(() {
        _rank = index >= 0 ? index + 1 : entries.length + 1;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator()
            : Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Session Over!', style: AppTypography.headingLarge),
              const SizedBox(height: 8),
              Text(
                'Here are your results',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 40),
              RankingCard(
                displayName: user?.displayName ?? 'Player',
                avatarUrl: user?.avatarUrl,
                score: quiz.score,
                rank: _rank,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  quiz.reset();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}