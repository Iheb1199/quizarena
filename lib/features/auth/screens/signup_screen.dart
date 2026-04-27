import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/role_selector.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _picker = ImagePicker();

  String _role = 'player';
  File? _avatarFile;
  Uint8List? _avatarBytes;
  XFile? _pickedXFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (picked != null) {
      _pickedXFile = picked;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() => _avatarBytes = bytes);
      } else {
        setState(() => _avatarFile = File(picked.path));
      }
    }
  }

  Widget _buildAvatarPreview() {
    ImageProvider? imageProvider;

    if (kIsWeb && _avatarBytes != null) {
      imageProvider = MemoryImage(_avatarBytes!);
    } else if (!kIsWeb && _avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    }

    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.surface,
            child: ClipOval(
              child: imageProvider != null
                  ? Image(
                image: imageProvider,
                width: 104,
                height: 104,
                fit: BoxFit.cover,
                key: ValueKey(_pickedXFile?.path),
              )
                  : const Icon(
                Icons.person,
                color: AppColors.textSecondary,
                size: 48,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              color: Colors.black,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyError(String raw) {
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
    if (raw.contains('too many requests') ||
        raw.contains('rate limit') ||
        raw.contains('over_email_send_rate_limit') ||
        raw.contains('429')) {
      return 'Too many attempts. Please wait a moment and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showConfirmationDialog(bool emailWasSent) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              emailWasSent
                  ? Icons.mark_email_unread
                  : Icons.check_circle_outline,
              color: AppColors.accent,
            ),
            const SizedBox(width: 10),
            Text(
              emailWasSent ? 'Check your email' : 'Account created!',
              style: AppTypography.headingSmall,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (emailWasSent) ...[
              Text(
                'We sent a confirmation link to:',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text.trim(),
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.accent),
              ),
              const SizedBox(height: 16),
              Text(
                'Please click the link in your email to activate your account before logging in.',
                style: AppTypography.bodySecondary,
              ),
            ] else ...[
              Text(
                'Your account has been successfully created.',
                style: AppTypography.bodySecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'You can now login with your email and password.',
                style: AppTypography.bodySecondary,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Text(
              'Go to Login',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;

      // Step 1 — create auth user
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;
      if (user == null) {
        _showError('Signup failed. Please try again.');
        setState(() => _isLoading = false);
        return;
      }

      // Step 2 — upload avatar if selected
      String? avatarUrl;
      try {
        final path = 'avatars/${user.id}.jpg';

        if (kIsWeb && _avatarBytes != null) {
          await supabase.storage.from('avatars').uploadBinary(
            path,
            _avatarBytes!,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
          avatarUrl =
              supabase.storage.from('avatars').getPublicUrl(path);
        } else if (!kIsWeb && _avatarFile != null) {
          await supabase.storage.from('avatars').upload(
            path,
            _avatarFile!,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
          avatarUrl =
              supabase.storage.from('avatars').getPublicUrl(path);
        }
      } catch (e) {
        // Avatar upload failure doesn't block signup
        print('Avatar upload failed: $e');
      }

      // Step 3 — insert user profile
      await supabase.from('users').insert({
        'id': user.id,
        'display_name': _displayNameController.text.trim(),
        'role': _role,
        'avatar_url': avatarUrl,
      });

      if (!mounted) return;

      // Step 4 — check if a confirmation email was actually sent
      // When email confirmation is ON in Supabase, the session
      // is null after signup until the user confirms.
      // When it's OFF, the session is immediately available.
      final emailWasSent = response.session == null;

      // Step 5 — always show dialog, never go to dashboard directly
      setState(() => _isLoading = false);
      _showConfirmationDialog(emailWasSent);
    } catch (e) {
      if (mounted) _showError(_friendlyError(e.toString()));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Text('Create Account', style: AppTypography.headingLarge),
                const SizedBox(height: 8),
                Text('Join QuizArena today',
                    style: AppTypography.bodySecondary),
                const SizedBox(height: 32),
                _buildAvatarPreview(),
                const SizedBox(height: 8),
                Text(
                  _pickedXFile == null ? 'Choose Avatar' : 'Tap to change',
                  style: AppTypography.bodySecondary,
                ),
                const SizedBox(height: 24),
                AuthTextField(
                  label: 'Display Name',
                  controller: _displayNameController,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.displayName,
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 24),
                RoleSelector(
                  selectedRole: _role,
                  onChanged: (value) => setState(() => _role = value),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Create Account',
                  onPressed: _signup,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(
                    'Already have an account? Login',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.accent),
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