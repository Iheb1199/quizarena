import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../models/session_model.dart';
import '../../../services/question_service.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../models/question_model.dart';
import '../widgets/question_form.dart';

class QuestionEditorScreen extends StatefulWidget {
  final SessionModel session;

  const QuestionEditorScreen({super.key, required this.session});

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _questionService = QuestionService();
  List<QuestionModel> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    _questions =
    await _questionService.getSessionQuestions(widget.session.id);
    setState(() => _isLoading = false);
  }

  Future<void> _saveQuestion(Map<String, dynamic> data) async {
    if (_questions.length >= 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 10 questions reached'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await _questionService.saveQuestion(
      sessionId: widget.session.id,
      text: data['text'],
      orderIndex: _questions.length + 1,
      answers: List<Map<String, dynamic>>.from(data['answers']),
    );
    await _loadQuestions();
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question saved!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Questions (${_questions.length}/10)',
          style: AppTypography.headingSmall,
        ),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_questions.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                itemBuilder: (context, i) {
                  final q = _questions[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primary,
                          radius: 16,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(q.text,
                              style: AppTypography.bodyMedium),
                        ),
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 18),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
            if (_questions.length < 10)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isSaving
                    ? const LoadingIndicator(message: 'Saving...')
                    : QuestionForm(
                  questionNumber: _questions.length + 1,
                  onSaved: _saveQuestion,
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      'All 10 questions added!',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.success),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}