import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
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

  bool _isSessionActive = false;
  int _playersReady = 0;
  int _totalPlayers = 0;
  bool _quizStarting = false;

  @override
  void initState() {
    super.initState();
    _checkSessionStatus();
    _listenToSession();
    _listenToRoomCount();
  }

  @override
  void dispose() {
    // Leave the room if we were in it
    if (_isSessionActive) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _sessionService.playerLeftRoom(widget.session.id);
      }
    }
    super.dispose();
  }

  // Check current session status immediately
  Future<void> _checkSessionStatus() async {
    print('🔍 Checking session status...');
    final data = await _sessionService.getSessionOnce(widget.session.id);
    print('🔍 Session data: ${data['status']}, players_ready: ${data['players_ready']}');

    if (data['status'] == 'active') {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        print('✅ Session is active, entering room...');
        await _sessionService.playerEnteredRoom(widget.session.id);
        setState(() {
          _isSessionActive = true;
          _playersReady = (data['players_ready'] ?? 0) + 1;
        });
      }
    }
  }

  // Listen to session status changes
  void _listenToSession() {
    _sessionService.listenToSession(widget.session.id).listen((data) async {
      if (!mounted) return;
      if (data.isEmpty) return;

      final status = data['status'];
      print('📡 Session status changed to: $status');

      // If session becomes active while waiting
      if (status == 'active' && !_isSessionActive) {
        final user = context.read<AuthProvider>().user;
        if (user != null) {
          print('📡 Session became active, entering room...');
          await _sessionService.playerEnteredRoom(widget.session.id);
          setState(() {
            _isSessionActive = true;
          });
        }
      }

      // Update players ready count
      final playersReady = (data['players_ready'] ?? 0) as int;
      setState(() {
        _playersReady = playersReady;
      });
    });
  }

  // Listen to total participant count
  void _listenToRoomCount() async {
    // Get initial total
    final total = await _sessionService.getParticipantCount(widget.session.id);
    setState(() => _totalPlayers = total);
    print('👥 Total participants: $total');
  }

  Future<void> _leave() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Leave Session', style: AppTypography.headingSmall),
        content: Text(
          'Are you sure you want to leave?',
          style: AppTypography.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
            const Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    if (_isSessionActive) {
      await _sessionService.playerLeftRoom(widget.session.id);
    }

    await context.read<SessionProvider>().leaveSession(
      sessionId: widget.session.id,
      playerId: user.id,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  // This will be called when host navigates from dashboard to waiting room
  static Future<void> navigateAndWaitForStart(
      BuildContext context, {
        required SessionModel session,
        required String participantId,
      }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingRoomScreen(
          session: session,
          participantId: participantId,
        ),
      ),
    );
  }

  // Listen for when to start the quiz
  void _checkAndStartQuiz() {
    if (_isSessionActive && _playersReady >= 2 && !_quizStarting) {
      print('🎯 Quiz should start! playersReady=$_playersReady');
      setState(() => _quizStarting = true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CountdownScreen(
            session: widget.session,
            participantId: widget.participantId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if quiz should start on every rebuild
    _checkAndStartQuiz();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
        actions: [
          if (!_quizStarting)
            TextButton.icon(
              onPressed: _leave,
              icon: const Icon(Icons.exit_to_app, color: AppColors.error),
              label: const Text('Leave',
                  style: TextStyle(color: AppColors.error)),
            ),
        ],
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
                  color: _isSessionActive ? AppColors.success : AppColors.accent,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _isSessionActive ? 'Session is live!' : 'Waiting for Host',
                style: AppTypography.headingMedium,
              ),
              const SizedBox(height: 12),
              Text(
                _isSessionActive
                    ? 'Waiting for all players to enter...'
                    : 'The quiz will start once the host activates the session.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.session.label,
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.accent),
                ),
              ),
              if (_isSessionActive) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text('Players in room',
                          style: AppTypography.bodySecondary),
                      const SizedBox(height: 8),
                      Text(
                        '$_playersReady / $_totalPlayers',
                        style: AppTypography.scoreStyle,
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _totalPlayers > 0
                              ? (_playersReady / _totalPlayers).clamp(0.0, 1.0)
                              : 0,
                          backgroundColor: AppColors.background,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.success),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _playersReady >= 2
                            ? 'Starting quiz!'
                            : 'Waiting for ${2 - _playersReady} more player(s)...',
                        style: TextStyle(
                          color: _playersReady >= 2
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
    );
  }
}