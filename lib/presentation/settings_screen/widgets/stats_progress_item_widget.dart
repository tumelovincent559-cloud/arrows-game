import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Statistics progress bar item with label and percentage
class StatsProgressItemWidget extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final Color progressColor;

  const StatsProgressItemWidget({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    required this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final percentage = total > 0 ? (current / total) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: isDark
                      ? const Color(0xFFF9FAFB)
                      : const Color(0xFF1F2937),
                ),
              ),
              Text(
                '$current / $total',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
