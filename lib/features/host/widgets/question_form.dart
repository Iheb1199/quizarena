import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import 'answer_option_field.dart';

class QuestionForm extends StatefulWidget {
  final int questionNumber;
  final Function(Map<String, dynamic>) onSaved;

  const QuestionForm({
    super.key,
    required this.questionNumber,
    required this.onSaved,
  });

  @override
  State<QuestionForm> createState() => _QuestionFormState();
}

class _QuestionFormState extends State<QuestionForm> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers =
  List.generate(4, (_) => TextEditingController());
  final List<bool> _correctFlags = [false, false, false, false];

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final correctCount = _correctFlags.where((f) => f).length;
    if (correctCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mark at least 1 correct answer'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    widget.onSaved({
      'text': _questionController.text.trim(),
      'answers': List.generate(4, (i) => {
        'text': _answerControllers[i].text.trim(),
        'is_correct': _correctFlags[i],
      }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${widget.questionNumber}',
            style: AppTypography.headingSmall,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _questionController,
            style: const TextStyle(color: AppColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Enter your question...',
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) =>
            v == null || v.isEmpty ? 'Question is required' : null,
          ),
          const SizedBox(height: 16),
          Text('Answers (tap circle to mark correct)',
              style: AppTypography.bodySecondary),
          const SizedBox(height: 10),
          ...List.generate(
            4,
                (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AnswerOptionField(
                controller: _answerControllers[i],
                isCorrect: _correctFlags[i],
                index: i,
                onCorrectToggled: (val) =>
                    setState(() => _correctFlags[i] = val),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save),
            label: const Text('Save Question'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}