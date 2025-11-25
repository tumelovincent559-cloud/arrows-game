import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Widget displaying heart-based life system
class HeartCounterWidget extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;

  const HeartCounterWidget({
    super.key,
    required this.currentHearts,
    this.maxHearts = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.5)
            : AppTheme.surfaceLight.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.defaultBorderRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxHearts, (index) {
          final isFilled = index < currentHearts;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.5.w),
            child: CustomIconWidget(
              iconName: isFilled ? 'favorite' : 'favorite_border',
              color: isFilled
                  ? AppTheme.errorLight
                  : AppTheme.textDisabledLight,
              size: 20.sp,
            ),
          );
        }),
      ),
    );
  }
}
