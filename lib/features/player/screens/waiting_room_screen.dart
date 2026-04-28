import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/session_service.dart';
import 'countdown_screen.dart';

class WaitingRoomScreen extends StatefulWidget {
  final SessionModel session;
  final String participantId;

  const WaitingRoomScreen({
    super.key,
    required this.session,
    required this.participantId,
  });

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final _sessionService = SessionService();

  StreamSubscription? _sessionSub;
  StreamSubscription? _participantSub;

  String _sessionStatus = 'pending';
  int _participantCount = 0;
  bool _quizStarting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Get current session state
    final data = await _sessionService.getSessionOnce(widget.session.id);
    if (mounted) {
      setState(() => _sessionStatus = data['status'] as String);
    }

    // Listen to session status changes
    _sessionSub = _sessionService
        .listenToSession(widget.session.id)
        .listen((data) {
      if (!mounted || data.isEmpty) return;
      setState(() => _sessionStatus = data['status'] as String);
      _checkAndStart();
    });

  }

  void _checkAndStart() async {
    if (_quizStarting) return;

    // Always fetch fresh values instead of relying on cached state
    final data = await _sessionService.getSessionOnce(widget.session.id);
    final status = data['status'] as String;
    final count = await _sessionService.getParticipantCount(widget.session.id);

    if (!mounted) return;
    setState(() {
      _sessionStatus = status;
      _participantCount = count;
    });

    print(status);
    print(count);
    print(_quizStarting);
    if (status == 'active' && count >= 2 && !_quizStarting) {
      setState(() => _quizStarting = true);

      await _sessionService.setQuizStartTime(widget.session.id);

      print('yousel');
      final freshData = await _sessionService.getSessionOnce(widget.session.id);
      final startTimeRaw = freshData['quiz_started_at'] as String?;
      if (startTimeRaw == null || !mounted) return;

      final startTime = DateTime.parse(startTimeRaw).toLocal().add(const Duration(seconds: 5));


      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CountdownScreen(
            session: widget.session,
            participantId: widget.participantId,
            startTime: startTime,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    _participantSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: Text(widget.session.label),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    color: _sessionStatus == 'active'
                        ? AppColors.success
                        : AppColors.accent,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  _sessionStatus == 'active'
                      ? 'Session is live!'
                      : 'Waiting for Host',
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 12),
                Text(
                  _sessionStatus == 'active'
                      ? 'Waiting for all players...'
                      : 'The quiz will start once the host activates the session.',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                if (_sessionStatus == 'active') ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text('Players ready',
                            style: AppTypography.bodySecondary),
                        const SizedBox(height: 8),
                        Text(
                          '$_participantCount / 2',
                          style: AppTypography.scoreStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _participantCount >= 2
                              ? 'Starting quiz...'
                              : 'Waiting for the other player...',
                          style: TextStyle(
                            color: _participantCount >= 2
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}