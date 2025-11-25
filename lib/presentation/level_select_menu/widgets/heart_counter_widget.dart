import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Heart counter widget showing current hearts and regeneration timer
class HeartCounterWidget extends StatelessWidget {
  final int currentHearts;
  final int maxHearts;
  final String? regenerationTime;

  const HeartCounterWidget({
    super.key,
    required this.currentHearts,
    required this.maxHearts,
    this.regenerationTime,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Hearts display
          Row(
            children: List.generate(maxHearts, (index) {
              return Padding(
                padding: EdgeInsets.only(right: 1.w),
                child: CustomIconWidget(
                  iconName: index < currentHearts
                      ? 'favorite'
                      : 'favorite_border',
                  size: 24,
                  color: index < currentHearts
                      ? AppTheme.errorLight
                      : (isDark
                            ? AppTheme.textDisabledDark
                            : AppTheme.textDisabledLight),
                ),
              );
            }),
          ),
          // Regeneration timer
          if (regenerationTime != null && currentHearts < maxHearts) ...[
            SizedBox(width: 3.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.primaryDark.withValues(alpha: 0.1)
                    : AppTheme.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'schedule',
                    size: 14,
                    color: isDark
                        ? AppTheme.primaryDark
                        : AppTheme.primaryLight,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    regenerationTime!,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.primaryDark
                          : AppTheme.primaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
