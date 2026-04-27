import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class AvatarWidget extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double radius;

  const AvatarWidget({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
            errorWidget: (context, url, error) => _buildInitials(),
          ),
        ),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Text(
      Helpers.initialsFromName(displayName),
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: radius * 0.7,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}