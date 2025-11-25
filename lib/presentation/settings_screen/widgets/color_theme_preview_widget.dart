import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Color theme preview swatch with selection indicator
class ColorThemePreviewWidget extends StatelessWidget {
  final String themeName;
  final Color mazeColor;
  final Color pathColor;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorThemePreviewWidget({
    super.key,
    required this.themeName,
    required this.mazeColor,
    required this.pathColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? (isDark
                            ? const Color(0xFF818CF8)
                            : const Color(0xFF6366F1))
                      : (isDark
                            ? const Color(0xFF374151)
                            : const Color(0xFFE5E7EB)),
                  width: isSelected ? 3 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Row(
                  children: [
                    Expanded(child: Container(color: mazeColor)),
                    Expanded(child: Container(color: pathColor)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              themeName,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isDark
                    ? const Color(0xFFF9FAFB)
                    : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
