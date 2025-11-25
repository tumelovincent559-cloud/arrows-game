import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying remaining hint count
class HintCounterWidget extends StatelessWidget {
  final int remainingHints;
  final VoidCallback onHintPressed;

  const HintCounterWidget({
    super.key,
    required this.remainingHints,
    required this.onHintPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: remainingHints > 0 ? onHintPressed : null,
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: remainingHints > 0
                ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
                : (isDark
                      ? AppTheme.textDisabledDark
                      : AppTheme.textDisabledLight),
            borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomIconWidget(
                iconName: 'lightbulb',
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 1.w),
              Text(
                '$remainingHints',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
