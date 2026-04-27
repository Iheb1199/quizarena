import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

class AvatarPicker extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;

  const AvatarPicker({
    super.key,
    this.imageFile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.surface,
            backgroundImage:
            imageFile != null ? FileImage(imageFile!) : null,
            child: imageFile == null
                ? const Icon(
              Icons.add_a_photo,
              color: AppColors.accent,
              size: 32,
            )
                : null,
          ),
          const SizedBox(height: 8),
          Text('Choose Avatar', style: AppTypography.bodySecondary),
        ],
      ),
    );
  }
}