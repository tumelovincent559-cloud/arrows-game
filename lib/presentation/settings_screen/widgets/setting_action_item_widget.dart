import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Action button setting item with icon and label
class SettingActionItemWidget extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const SettingActionItemWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final textColor = isDestructive
        ? (isDark ? const Color(0xFFF87171) : const Color(0xFFEF4444))
        : (isDark ? const Color(0xFFF9FAFB) : const Color(0xFF1F2937));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(iconName: iconName, size: 24, color: textColor),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),
              CustomIconWidget(
                iconName: 'chevron_right',
                size: 20,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
