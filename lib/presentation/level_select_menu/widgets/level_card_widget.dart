import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LevelCardWidget extends StatelessWidget {
  final int levelNumber;
  final int starsEarned;
  final bool isLocked;
  final bool isCurrent;
  final String? bestTime;
  final int? hintsUsed;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const LevelCardWidget({
    super.key,
    required this.levelNumber,
    required this.starsEarned,
    required this.isLocked,
    required this.isCurrent,
    this.bestTime,
    this.hintsUsed,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      onLongPress: isLocked ? null : onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isCurrent
              ? (isDark
                  ? AppTheme.primaryDark.withValues(alpha: 0.1)
                  : AppTheme.primaryLight.withValues(alpha: 0.1))
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isCurrent
              ? Border.all(
                  color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                  width: 2,
                )
              : null,
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
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(2.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    child: Text(
                      levelNumber.toString(),
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: isLocked
                            ? (isDark
                                ? AppTheme.textDisabledDark
                                : AppTheme.textDisabledLight)
                            : (isDark
                                ? AppTheme.textHighEmphasisDark
                                : AppTheme.textHighEmphasisLight),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
                  if (isLocked)
                    CustomIconWidget(
                      iconName: 'lock',
                      size: 16, // reduced to avoid overflow
                      color: isDark
                          ? AppTheme.textDisabledDark
                          : AppTheme.textDisabledLight,
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0.3.w),
                          child: CustomIconWidget(
                            iconName:
                                index < starsEarned ? 'star' : 'star_border',
                            size: 12, // reduced from 14
                            color: index < starsEarned
                                ? AppTheme.warningLight
                                : (isDark
                                    ? AppTheme.textDisabledDark
                                    : AppTheme.textDisabledLight),
                          ),
                        );
                      }),
                    ),
                  if (!isLocked && bestTime != null) ...[
                    SizedBox(height: 0.3.h),
                    FittedBox(
                      child: Text(
                        bestTime!,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 7.sp,
                          fontWeight: FontWeight.w400,
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                      ),
                    ),
                  ],
                  if (!isLocked && hintsUsed != null && hintsUsed! > 0) ...[
                    SizedBox(height: 0.3.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: 'lightbulb',
                          size: 9,
                          color: isDark
                              ? AppTheme.textMediumEmphasisDark
                              : AppTheme.textMediumEmphasisLight,
                        ),
                        SizedBox(width: 0.4.w),
                        FittedBox(
                          child: Text(
                            hintsUsed.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppTheme.textMediumEmphasisDark
                                  : AppTheme.textMediumEmphasisLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isCurrent && !isLocked)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 1.2.w,
                    vertical: 0.25.h,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: FittedBox(
                    child: Text(
                      'PLAY',
                      style: GoogleFonts.inter(
                        fontSize: 7.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.onPrimaryDark
                            : AppTheme.onPrimaryLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
