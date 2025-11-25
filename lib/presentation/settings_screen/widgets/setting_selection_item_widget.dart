import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Selection list setting item with icon, label, and current value
class SettingSelectionItemWidget extends StatelessWidget {
  final String iconName;
  final String label;
  final String currentValue;
  final VoidCallback onTap;

  const SettingSelectionItemWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.currentValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                size: 24,
                color: isDark
                    ? const Color(0xFF9CA3AF)
                    : const Color(0xFF6B7280),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: isDark
                        ? const Color(0xFFF9FAFB)
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                currentValue,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
              SizedBox(width: 2.w),
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
