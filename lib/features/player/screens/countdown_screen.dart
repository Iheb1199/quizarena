import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import 'quiz_screen.dart';

class CountdownScreen extends StatefulWidget {
  final SessionModel session;
  final String participantId;

  const CountdownScreen({
    super.key,
    required this.session,
    required this.participantId,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen>
    with SingleTickerProviderStateMixin {
  int _count = 3;
  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 1.5, end: 0.8).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _animController.forward();
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_count <= 1) {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              session: widget.session,
              participantId: widget.participantId,
            ),
          ),
        );
        return;
      }
      setState(() => _count--);
      _animController.reset();
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Get Ready!', style: AppTypography.headingLarge),
            const SizedBox(height: 48),
            ScaleTransition(
              scale: _scaleAnim,
              child: Text(
                '$_count',
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                  shadows: [
                    Shadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}