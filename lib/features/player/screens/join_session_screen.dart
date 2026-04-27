import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/player_service.dart';
import '../../../shared/widgets/primary_button.dart';
import 'waiting_room_screen.dart';

class JoinSessionScreen extends StatefulWidget {
  final SessionModel session;

  const JoinSessionScreen({super.key, required this.session});

  @override
  State<JoinSessionScreen> createState() => _JoinSessionScreenState();
}

class _JoinSessionScreenState extends State<JoinSessionScreen> {
  final _playerService = PlayerService();
  bool _isJoining = false;

  Future<void> _join() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => _isJoining = true);

    try {
      final existing = await _playerService.getParticipant(
        sessionId: widget.session.id,
        playerId: user.id,
      );

      final participant = existing ??
          await _playerService.joinSession(
            sessionId: widget.session.id,
            playerId: user.id,
          );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => WaitingRoomScreen(
            session: widget.session,
            participantId: participant.id,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _isJoining = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.session.label)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz, color: AppColors.accent, size: 48),
            ),
            const SizedBox(height: 24),
            Text(widget.session.label, style: AppTypography.headingMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              '${widget.session.participantCount} players already joined',
              style: AppTypography.bodySecondary,
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              label: 'Join Session',
              onPressed: _join,
              isLoading: _isJoining,
              icon: Icons.login,
            ),
          ],
        ),
      ),
    );
  }
}