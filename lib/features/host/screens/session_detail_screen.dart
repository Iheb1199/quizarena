import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../services/session_service.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/activate_button.dart';
import 'question_editor_screen.dart';
import 'host_leaderboard_screen.dart';

class SessionDetailScreen extends StatefulWidget {
  final SessionModel session;

  const SessionDetailScreen({super.key, required this.session});

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {



  final _sessionService = SessionService();
  late SessionModel _session;
  bool _isActivating = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _session = widget.session;
    print('🔍 participantCount on open: ${_session.status}');
    _listenToSession();
    _roomSub = _sessionService.listenToRoomCount(_session.id).listen((count) {
      if (mounted) setState(() => _playersInRoom = count);
    });


  }

  StreamSubscription? _roomSub;
  int _playersInRoom = 0;



  @override
  void dispose() {
  _roomSub?.cancel();
  super.dispose();
  }


  void _listenToSession() {
    _sessionService.listenToSession(_session.id).listen((data) {
      if (data.isNotEmpty && mounted) {
        setState(() {
          _session = SessionModel.fromMap({
            ..._session.toMap(),
            'status': data['status'],
          });
        });
      }
    });
  }

  Future<void> _activate() async {
    setState(() => _isActivating = true);
    await _sessionService.activateSession(_session.id);
    setState(() => _isActivating = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Session',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('This action cannot be undone.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isDeleting = true);
    await _sessionService.deleteSession(_session.id);
    if (mounted) Navigator.pop(context);
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.bodySecondary),
              Text(value, style: AppTypography.headingSmall),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_session.label)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Status', _session.status.toUpperCase(), Icons.info_outline),
            const SizedBox(height: 12),
            _infoTile('Participants', '${_playersInRoom}', Icons.people),
            const SizedBox(height: 12),
            _infoTile('Questions', '${_session.questionCount}/10', Icons.quiz),
            const SizedBox(height: 24),
            if (_session.isPending) ...[
              PrimaryButton(
                label: 'Edit Questions',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuestionEditorScreen(session: _session),
                  ),
                ),
                icon: Icons.edit,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 12),
              ActivateButton(
                session: _session,
                onActivate: _activate,
                isLoading: _isActivating,
                playersInRoom: _playersInRoom,
              ),
            ],
            if (_session.isActive || _session.isFinished) ...[
              PrimaryButton(
                label: 'View Leaderboard',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HostLeaderboardScreen(sessionId: _session.id),
                  ),
                ),
                icon: Icons.leaderboard,
                color: AppColors.secondary,
              ),
            ],
            if (_session.isFinished) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Delete Session',
                onPressed: _isDeleting ? null : _delete,
                isLoading: _isDeleting,
                color: AppColors.error,
                icon: Icons.delete_outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}