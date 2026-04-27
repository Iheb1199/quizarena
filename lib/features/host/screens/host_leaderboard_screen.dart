import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/leaderboard_entry_model.dart';
import '../../../services/player_service.dart';
import '../../../shared/widgets/leadingboard_podium.dart';
import '../../../shared/widgets/loading_indicator.dart';

class HostLeaderboardScreen extends StatefulWidget {
  final String sessionId;

  const HostLeaderboardScreen({super.key, required this.sessionId});

  @override
  State<HostLeaderboardScreen> createState() => _HostLeaderboardScreenState();
}

class _HostLeaderboardScreenState extends State<HostLeaderboardScreen> {
  final _playerService = PlayerService();
  List<LeaderboardEntryModel> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _listenToLeaderboard();
  }

  void _listenToLeaderboard() {
    _playerService.listenToLeaderboard(widget.sessionId).listen((rows) async {
      final entries = await _playerService.getLeaderboard(widget.sessionId);
      if (mounted) setState(() {
        _entries = entries;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leaderboard', style: AppTypography.headingSmall),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _entries.isEmpty
          ? Center(
        child: Text('No participants yet',
            style: AppTypography.bodySecondary),
      )
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text('Top 3 Players', style: AppTypography.headingMedium),
            const SizedBox(height: 32),
            LeaderboardPodium(entries: _entries),
          ],
        ),
      ),
    );
  }
}