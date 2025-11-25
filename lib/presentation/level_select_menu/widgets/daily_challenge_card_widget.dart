import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Daily challenge card with golden styling and countdown timer
class DailyChallengeCardWidget extends StatelessWidget {
  final String timeRemaining;
  final bool isCompleted;
  final int starsEarned;
  final VoidCallback onTap;

  const DailyChallengeCardWidget({
    super.key,
    required this.timeRemaining,
    required this.isCompleted,
    required this.starsEarned,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFBBF24).withValues(alpha: 0.2),
              const Color(0xFFF59E0B).withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFBBF24), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Trophy icon
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: CustomIconWidget(
                iconName: 'emoji_events',
                size: 32,
                color: const Color(0xFFF59E0B),
              ),
            ),
            SizedBox(width: 4.w),
            // Challenge info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Daily Challenge',
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppTheme.textHighEmphasisDark
                              : AppTheme.textHighEmphasisLight,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      if (isCompleted)
                        CustomIconWidget(
                          iconName: 'check_circle',
                          size: 18,
                          color: AppTheme.successLight,
                        ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'schedule',
                        size: 14,
                        color: isDark
                            ? AppTheme.textMediumEmphasisDark
                            : AppTheme.textMediumEmphasisLight,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        timeRemaining,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ],
                  ),
                  if (isCompleted) ...[
                    SizedBox(height: 0.5.h),
                    Row(
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 1.w),
                          child: CustomIconWidget(
                            iconName: index < starsEarned
                                ? 'star'
                                : 'star_border',
                            size: 14,
                            color: index < starsEarned
                                ? AppTheme.warningLight
                                : (isDark
                                      ? AppTheme.textDisabledDark
                                      : AppTheme.textDisabledLight),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
            // Arrow icon
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              size: 20,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
      ),
    );
  }
}
