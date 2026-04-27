import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AnswerOptionField extends StatelessWidget {
  final TextEditingController controller;
  final bool isCorrect;
  final ValueChanged<bool> onCorrectToggled;
  final int index;

  const AnswerOptionField({
    super.key,
    required this.controller,
    required this.isCorrect,
    required this.onCorrectToggled,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => onCorrectToggled(!isCorrect),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCorrect ? AppColors.success : AppColors.surface,
              border: Border.all(
                color: isCorrect ? AppColors.success : AppColors.textSecondary,
                width: 2,
              ),
            ),
            child: isCorrect
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: controller,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Answer ${index + 1}',
              hintStyle:
              const TextStyle(color: AppColors.textSecondary, fontSize: 14),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) =>
            v == null || v.isEmpty ? 'Answer is required' : null,
          ),
        ),
      ],
    );
  }
}