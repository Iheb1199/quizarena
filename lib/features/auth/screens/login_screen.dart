import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../host/screens/host_dashboard_screen.dart';
import '../../player/screens/player_dashboard_screen.dart';
import '../widgets/auth_text_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Converts technical Supabase errors to friendly messages
  String _friendlyError(String raw) {
    if (raw.contains('email_not_confirmed')) {
      return 'Please confirm your email before logging in.';
    }
    if (raw.contains('Invalid login credentials') ||
        raw.contains('invalid_credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (raw.contains('User already registered') ||
        raw.contains('already been registered')) {
      return 'An account with this email already exists.';
    }
    if (raw.contains('Password should be at least')) {
      return 'Your password must be at least 6 characters long.';
    }
    if (raw.contains('Unable to validate email address')) {
      return 'Please enter a valid email address.';
    }
    if (raw.contains('network') || raw.contains('socket')) {
      return 'No internet connection. Please check your network.';
    }
    // ← THIS is what catches the rate limit error
    if (raw.contains('too many requests') ||
        raw.contains('rate limit') ||
        raw.contains('over_email_send_rate_limit') ||
        raw.contains('429')) {
      return 'You\'ve signed up too many times during testing. Please wait 1 hour or disable email confirmation in Supabase dashboard.';
    }
    return 'Something went wrong. Please try again.';
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final user = auth.user!;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user.isHost
              ? const HostDashboardScreen()
              : const PlayerDashboardScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_friendlyError(auth.error ?? '')),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.quiz, color: Colors.white, size: 44),
                ),
                const SizedBox(height: 24),
                Text('Welcome Back', style: AppTypography.headingLarge),
                const SizedBox(height: 8),
                Text('Login to continue', style: AppTypography.bodySecondary),
                const SizedBox(height: 40),
                AuthTextField(
                  label: 'Email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: Validators.email,
                ),
                const SizedBox(height: 16),
                AuthTextField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                  prefixIcon: Icons.lock_outline,
                  validator: Validators.password,
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Login',
                  onPressed: _login,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignupScreen()),
                  ),
                  child: Text(
                    "Don't have an account? Sign Up",
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.accent,
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
}