import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Header widget showing total progress and completed levels
class ProgressHeaderWidget extends StatelessWidget {
  final int completedLevels;
  final int totalLevels;

  const ProgressHeaderWidget({
    super.key,
    required this.completedLevels,
    required this.totalLevels,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final progress = totalLevels > 0 ? completedLevels / totalLevels : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Progress',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textHighEmphasisDark
                      : AppTheme.textHighEmphasisLight,
                ),
              ),
              Text(
                '$completedLevels / $totalLevels',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 1.h,
              backgroundColor: isDark
                  ? AppTheme.dividerDark
                  : AppTheme.dividerLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% Complete',
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
            ),
          ),
        ],
      ),
    );
  }
}
