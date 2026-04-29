import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/session_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../widgets/answer_option_tile.dart';
import '../widgets/timer_bar.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final SessionModel session;
  final String participantId;

  const QuizScreen({
    super.key,
    required this.session,
    required this.participantId,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _sessionService = SessionService();
  int _secondsLeft = 20; // changed to 20 seconds
  Timer? _timer;
  String? _selectedAnswerId;
  bool _isLocked = false; // locked after answering but timer still runs
  bool _submitted = false; // answer submitted to db
  bool _navigating = false;
  int _displayIndex = 0; // ← controls what the UI shows, not the provider
  bool _waitingForOthers = false; // ← new
  bool _navigatedToResult = false; // ← new


  @override
  void initState() {
    super.initState();
    _displayIndex = 0;
    _initQuiz();
  }

  Future<void> _initQuiz() async {
    await context.read<QuizProvider>().loadQuestions(
      widget.session.id,
      widget.participantId,
    );
    _startTimer();
  }

  void _startTimer() {
    _secondsLeft = 20;
    _isLocked = false;
    _submitted = false;
    _selectedAnswerId = null;
    _timer?.cancel();
    final quiz = context.read<QuizProvider>();

    if (quiz.isFinished) {

      // Wait until ALL participants have finished before showing results
      _waitForAllAndNavigate();
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted) { t.cancel(); return; }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        await _submitAnswer(_selectedAnswerId);
      }
    });
  }

  Future<void> _selectAnswer(String answerId) async {
    if (_isLocked) return;
    setState(() {
      _isLocked = true;
      _selectedAnswerId = answerId;
    });

    if (!_submitted) {
      _submitted = true;
      final quiz = context.read<QuizProvider>();
      final question = quiz.currentQuestion;
      if (question == null) return;

      final isCorrect = question.answers.any((a) => a.id == answerId && a.isCorrect);
      await quiz.submitAnswer(
        answerId: answerId,
        isCorrect: isCorrect,
        secondsLeft: _secondsLeft,
      );


    }
  }

  Future<void> _submitAnswer(String? answerId) async {
    if (_navigating) return; // ← prevent double navigation

    if (!_submitted) {

      _submitted = true;
      final quiz = context.read<QuizProvider>();
      final question = quiz.currentQuestion;
      if (question == null) return;

      bool isCorrect = false;
      if (answerId != null) {
        isCorrect = question.answers.any((a) => a.id == answerId && a.isCorrect);
      }
      try {
        await quiz.submitAnswer(
          answerId: answerId,
          isCorrect: isCorrect,
          secondsLeft: 0,
        );
      } catch (e) {
        print('⚠️ submitAnswer error: $e');
      }
    }

    await _nextQuestion();
  }

  Future<void> _nextQuestion() async {
    print('test m fou9');
    if (!mounted || _navigating) return;
    print('test m louta');
    _navigating = true;

    final quiz = context.read<QuizProvider>();
    print('index quiz: ${quiz.currentIndex}');
    print('long quiz: ${quiz.questions.length}');

    if (quiz.isFinished) {
      print('test display ');
      _timer?.cancel();

      // Wait until ALL participants have finished before showing results
      _waitForAllAndNavigate();
    } else {
      quiz.moveToNext();
      setState(() => _displayIndex= quiz.currentIndex);
      print(_displayIndex);

      _navigating = false;
      _startTimer();
    }
  }

  void _waitForAllAndNavigate() async {
    print('test wait ');
    setState(() => _waitingForOthers = true);

    // Fetch real participant count from the participants table
    final totalPlayers =
    await _sessionService.getParticipantCount(widget.session.id);
    _sessionService
        .listenToAllParticipantsFinished(widget.session.id, totalPlayers)
        .listen((allDone) async {
      if (allDone && mounted && !_navigatedToResult) {
        print('test result finished');
        _navigatedToResult = true;
        await _sessionService.finishSession(widget.session.id);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              sessionId: widget.session.id,
              participantId: widget.participantId,
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final quiz = context.watch<QuizProvider>();

      if (quiz.isLoading) return const LoadingIndicator();

      // ← show waiting screen BEFORE the null question check
      if (_waitingForOthers) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: AppColors.accent),
                const SizedBox(height: 24),
                Text('You finished!', style: AppTypography.headingMedium),
                const SizedBox(height: 12),
                Text(
                  'Waiting for other players to finish...',
                  style: AppTypography.bodySecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      final question = _displayIndex < quiz.questions.length
          ? quiz.questions[_displayIndex]
          : null;
      if (question == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Q${_displayIndex + 1}/10',
                    style: AppTypography.headingSmall,
                  ),
                  Text(
                    'Score: ${quiz.score}',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.accent),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timer bar — 20 seconds
              TimerBar(
                secondsLeft: _secondsLeft,
                totalSeconds: 20,
              ),
              const SizedBox(height: 24),

              // Question
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  question.text,
                  style: AppTypography.headingSmall,
                ),
              ),
              const SizedBox(height: 16),

              // Locked message
              if (_isLocked && _secondsLeft > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Text(
                    'Answer submitted! Waiting for time to run out...',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_isLocked && _secondsLeft > 0)
                const SizedBox(height: 12),

              // Answers
              Expanded(
                child: ListView.builder(
                  itemCount: question.answers.length,
                  itemBuilder: (context, i) {
                    final answer = question.answers[i];
                    return AnswerOptionTile(
                      answer: answer,
                      index: i,
                      isSelected: _selectedAnswerId == answer.id,
                      isLocked: _isLocked,
                      onTap: () => _selectAnswer(answer.id),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}