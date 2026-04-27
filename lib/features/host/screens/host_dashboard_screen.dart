import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/screens/login_screen.dart';
import '../widgets/session_card.dart';
import '../widgets/session_search_bar.dart';
import 'create_session_screen.dart';
import 'session_detail_screen.dart';

class HostDashboardScreen extends StatefulWidget {
  const HostDashboardScreen({super.key});

  @override
  State<HostDashboardScreen> createState() => _HostDashboardScreenState();
}

class _HostDashboardScreenState extends State<HostDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final user = context
        .read<AuthProvider>()
        .user;
    if (user != null) {
      await context.read<SessionProvider>().loadHostSessions(user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sessionProv = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Sessions', style: AppTypography.headingSmall),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateSessionScreen()),
          );
          _load();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Session'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SessionSearchBar(
              onChanged: (q) =>
                  context.read<SessionProvider>().setSearch(q),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: sessionProv.isLoading
                  ? const LoadingIndicator()
                  : sessionProv.sessions.isEmpty
                  ? Center(
                child: Text(
                  'No sessions yet.\nTap + to create one!',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              )
                  : RefreshIndicator(
                onRefresh: _load,
                child: ListView.builder(
                  itemCount: sessionProv.sessions.length,
                  itemBuilder: (context, i) {
                    final session = sessionProv.sessions[i];
                    return SessionCard(
                      session: session,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SessionDetailScreen(
                              session: session,
                            ),
                          ),
                        );
                        _load();
                      },
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