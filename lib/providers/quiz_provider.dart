import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/question_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../services/question_service.dart';
import '../services/player_service.dart';
import '../core/utils/helpers.dart';

class QuizProvider extends ChangeNotifier {
  final _questionService = QuestionService();
  final _playerService = PlayerService();

  List<QuestionModel> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _participantId;
  bool _isLoading = false;
  List<LeaderboardEntryModel> _leaderboard = [];

  List<QuestionModel> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  bool get isLoading => _isLoading;
  List<LeaderboardEntryModel> get leaderboard => _leaderboard;
  QuestionModel? get currentQuestion =>
      _currentIndex < _questions.length ? _questions[_currentIndex] : null;
  bool get isFinished => _currentIndex >= _questions.length;

  Future<void> loadQuestions(String sessionId, String participantId) async {
    _isLoading = true;
    _participantId = participantId;
    _currentIndex = 0;
    _score = 0;
    notifyListeners();

    _questions = await _questionService.getSessionQuestions(sessionId);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitAnswer({
    required String? answerId,
    required bool isCorrect,
    required int secondsLeft,
  }) async {
    if (_participantId == null || currentQuestion == null) return;

    final gained = Helpers.calculateScore(isCorrect, secondsLeft);
    _score += gained;

    await _playerService.submitAnswer(
      participantId: _participantId!,
      questionId: currentQuestion!.id,
      answerId: answerId,
      isCorrect: isCorrect,
      score: _score,
    );

    _currentIndex++;
    notifyListeners();
  }

  Future<void> loadLeaderboard(String sessionId) async {
    _leaderboard = await _playerService.getLeaderboard(sessionId);
    notifyListeners();
  }

  void reset() {
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _participantId = null;
    _leaderboard = [];
    notifyListeners();
  }
}