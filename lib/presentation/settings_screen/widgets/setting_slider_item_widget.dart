import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Slider setting item with icon, label, and value display
class SettingSliderItemWidget extends StatelessWidget {
  final String iconName;
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  const SettingSliderItemWidget({
    super.key,
    required this.iconName,
    required this.label,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions = 10,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                '${(value * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF818CF8)
                      : const Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: isDark
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF6366F1),
              inactiveTrackColor: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFE5E7EB),
              thumbColor: isDark
                  ? const Color(0xFF818CF8)
                  : const Color(0xFF6366F1),
              overlayColor:
                  (isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1))
                      .withValues(alpha: 0.2),
              trackHeight: 4.0,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
