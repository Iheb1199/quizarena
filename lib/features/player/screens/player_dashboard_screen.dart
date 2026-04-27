import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../services/player_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/session_join_card.dart';
import 'join_session_screen.dart';
import 'waiting_room_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlayerDashboardScreen extends StatefulWidget {
  const PlayerDashboardScreen({super.key});

  @override
  State<PlayerDashboardScreen> createState() => _PlayerDashboardScreenState();
}

class _PlayerDashboardScreenState extends State<PlayerDashboardScreen> {
  final _searchController = TextEditingController();
  final _playerService = PlayerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      _listenToSessionChanges();
    });
  }

  void _listenToSessionChanges() {
    Supabase.instance.client
        .from('sessions')
        .stream(primaryKey: ['id'])
        .listen((_) {
      // Reload whenever any session changes status
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      await context
          .read<SessionProvider>()
          .loadPendingSessions(playerId: user.id);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _leaveSession(String sessionId) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Leave Session', style: AppTypography.headingSmall),
        content: Text(
          'Are you sure you want to leave this session?',
          style: AppTypography.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
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

    await context.read<SessionProvider>().leaveSession(
      sessionId: sessionId,
      playerId: user.id,
    );
  }

  Future<void> _resumeSession(String sessionId) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    // Fetch the real participant ID before navigating
    final participant = await _playerService.getParticipant(
      sessionId: sessionId,
      playerId: user.id,
    );

    if (participant == null) return;
    if (!mounted) return;

    final session = context
        .read<SessionProvider>()
        .sessions
        .firstWhere((s) => s.id == sessionId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WaitingRoomScreen(
          session: session,
          participantId: participant.id,
        ),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProv = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:
        Text('Available Sessions', style: AppTypography.headingSmall),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();
              if (!mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: (q) =>
                  context.read<SessionProvider>().setSearch(q),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by label or session ID...',
                prefixIcon: const Icon(Icons.search,
                    color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    context.read<SessionProvider>().clearSearch();
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: sessionProv.isLoading
                  ? const LoadingIndicator()
                  : sessionProv.sessions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off,
                        color: AppColors.textSecondary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _searchController.text.isNotEmpty
                          ? 'No sessions match your search.'
                          : 'No sessions available.\nCheck back later!',
                      style: AppTypography.bodySecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
                  : RefreshIndicator(
                onRefresh: () async {
                  _searchController.clear();
                  context.read<SessionProvider>().clearSearch();
                  await _load();
                },
                child: ListView.builder(
                  itemCount: sessionProv.sessions.length,
                  itemBuilder: (context, i) {
                    final session = sessionProv.sessions[i];
                    final enrolled =
                    sessionProv.isEnrolled(session.id);

                    return SessionJoinCard(
                      session: session,
                      isEnrolled: enrolled,
                      onJoin: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JoinSessionScreen(
                                session: session),
                          ),
                        );
                        await _load();
                      },
                      onResume: () =>
                          _resumeSession(session.id),
                      onLeave: () =>
                          _leaveSession(session.id),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}