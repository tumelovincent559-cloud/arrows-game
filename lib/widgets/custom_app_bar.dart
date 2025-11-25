import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom AppBar widget for the puzzle game application
/// Provides contextual navigation with back button and action items
/// Optimized for one-handed portrait usage with top-left back placement
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Title text displayed in the app bar
  final String title;

  /// Optional leading widget (defaults to back button when canPop is true)
  final Widget? leading;

  /// List of action widgets displayed on the right side
  final List<Widget>? actions;

  /// Whether to show the back button automatically
  final bool automaticallyImplyLeading;

  /// Whether to center the title
  final bool centerTitle;

  /// Custom background color (defaults to theme background)
  final Color? backgroundColor;

  /// Custom foreground color for text and icons
  final Color? foregroundColor;

  /// Elevation of the app bar
  final double elevation;

  /// App bar variant for different contexts
  final AppBarVariant variant;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.automaticallyImplyLeading = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0.0,
    this.variant = AppBarVariant.standard,
  });

  /// Factory constructor for game screen app bar with hint and settings
  factory CustomAppBar.game({
    Key? key,
    required String levelNumber,
    required VoidCallback onHintPressed,
    required VoidCallback onSettingsPressed,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Level $levelNumber',
      variant: AppBarVariant.game,
      actions: [
        // Hint button with light bulb icon
        IconButton(
          icon: const Icon(Icons.lightbulb_outline),
          onPressed: onHintPressed,
          tooltip: 'Hint',
          iconSize: 24,
        ),
        const SizedBox(width: 8),
        // Settings button
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
          tooltip: 'Settings',
          iconSize: 24,
        ),
        const SizedBox(width: 8),
      ],
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
              tooltip: 'Back',
              iconSize: 24,
            )
          : null,
    );
  }

  /// Factory constructor for level select screen with settings only
  factory CustomAppBar.levelSelect({
    Key? key,
    required VoidCallback onSettingsPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Select Level',
      variant: AppBarVariant.levelSelect,
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: onSettingsPressed,
          tooltip: 'Settings',
          iconSize: 24,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  /// Factory constructor for settings screen
  factory CustomAppBar.settings({
    Key? key,
    VoidCallback? onBackPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: 'Settings',
      variant: AppBarVariant.settings,
      leading: onBackPressed != null
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackPressed,
              tooltip: 'Back',
              iconSize: 24,
            )
          : null,
    );
  }

  /// Factory constructor for tutorial/onboarding screen
  factory CustomAppBar.tutorial({
    Key? key,
    VoidCallback? onSkipPressed,
  }) {
    return CustomAppBar(
      key: key,
      title: 'How to Play',
      variant: AppBarVariant.tutorial,
      automaticallyImplyLeading: false,
      actions: onSkipPressed != null
          ? [
              TextButton(
                onPressed: onSkipPressed,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Determine colors based on variant and theme
    final effectiveBackgroundColor = backgroundColor ??
        (variant == AppBarVariant.transparent
            ? Colors.transparent
            : theme.appBarTheme.backgroundColor ??
                theme.scaffoldBackgroundColor);

    final effectiveForegroundColor = foregroundColor ??
        theme.appBarTheme.foregroundColor ??
        (isDark ? Colors.white : const Color(0xFF1F2937));

    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: effectiveForegroundColor,
          letterSpacing: 0.15,
        ),
      ),
      leading: leading ??
          (automaticallyImplyLeading && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                  iconSize: 24,
                  color: effectiveForegroundColor,
                )
              : null),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
      elevation: elevation,
      iconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: effectiveForegroundColor,
        size: 24,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Enum defining different app bar variants for various screens
enum AppBarVariant {
  /// Standard app bar with default styling
  standard,

  /// Game screen app bar with hint and settings actions
  game,

  /// Level select screen app bar
  levelSelect,

  /// Settings screen app bar
  settings,

  /// Tutorial/onboarding screen app bar
  tutorial,

  /// Transparent app bar for overlay contexts
  transparent,
}
