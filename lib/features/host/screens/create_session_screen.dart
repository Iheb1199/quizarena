import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/session_provider.dart';
import '../../../shared/widgets/primary_button.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    print('test create');
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final session = await context.read<SessionProvider>().createSession(
      label: _labelController.text.trim(),
      hostId: user.id,
    );

    if (!mounted) return;

    if (session != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text('Session Created!', style: AppTypography.headingSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your session ID:', style: AppTypography.bodySecondary),
              const SizedBox(height: 8),
              SelectableText(
                session.id,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.accent),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK',
                  style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProv = context.watch<SessionProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Create Session')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Session Label', style: AppTypography.headingSmall),
              const SizedBox(height: 8),
              Text(
                'Give your session a unique and descriptive name.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _labelController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g. Science Quiz - Grade 10',
                  hintStyle:
                  const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.label_outline,
                      color: AppColors.textSecondary),
                ),
                validator: Validators.sessionLabel,
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Create Session',
                onPressed: _create,
                isLoading: sessionProv.isLoading,
                icon: Icons.add,
              ),
            ],
          ),
        ),
      ),
    );
  }
}