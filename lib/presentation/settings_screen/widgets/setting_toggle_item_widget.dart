import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Toggle switch setting item with icon and label
class SettingToggleItemWidget extends StatelessWidget {
  final String iconName;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleItemWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: iconName,
                size: 24,
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
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
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor:
                    isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
