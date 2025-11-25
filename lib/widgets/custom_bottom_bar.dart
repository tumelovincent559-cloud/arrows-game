import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom Bottom Navigation Bar for the puzzle game application
/// Provides primary navigation access optimized for thumb reach
/// Positioned in the bottom 60% of screen for comfortable one-handed use
class CustomBottomBar extends StatelessWidget {
  /// Currently selected navigation index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int> onTap;

  /// Bottom bar variant for different navigation contexts
  final BottomBarVariant variant;

  // Private fields for game variant
  final VoidCallback? _onUndoPressed;
  final VoidCallback? _onHintPressed;
  final bool? _undoEnabled;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.variant = BottomBarVariant.main,
  }) : _onUndoPressed = null,
       _onHintPressed = null,
       _undoEnabled = null;

  /// Factory constructor for main navigation (Level Select, Settings)
  factory CustomBottomBar.main({
    Key? key,
    required int currentIndex,
    required ValueChanged<int> onTap,
  }) {
    return CustomBottomBar(
      key: key,
      currentIndex: currentIndex,
      onTap: onTap,
      variant: BottomBarVariant.main,
    );
  }

  /// Factory constructor for game screen navigation (Undo, Hint)
  factory CustomBottomBar.game({
    Key? key,
    required VoidCallback onUndoPressed,
    required VoidCallback onHintPressed,
    bool undoEnabled = true,
  }) {
    return CustomBottomBar._game(
      key: key,
      onUndoPressed: onUndoPressed,
      onHintPressed: onHintPressed,
      undoEnabled: undoEnabled,
    );
  }

  // Private constructor for game variant
  const CustomBottomBar._game({
    super.key,
    required VoidCallback onUndoPressed,
    required VoidCallback onHintPressed,
    bool undoEnabled = true,
  }) : currentIndex = 0,
       onTap = _defaultOnTap,
       variant = BottomBarVariant.main,
       _onUndoPressed = onUndoPressed,
       _onHintPressed = onHintPressed,
       _undoEnabled = undoEnabled;

  // Add default no-op callback
  static void _defaultOnTap(int index) {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Check if this is game variant
    if (_onUndoPressed != null && _onHintPressed != null) {
      return Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Undo button
                _GameActionButton(
                  icon: Icons.undo_rounded,
                  label: 'Undo',
                  onPressed: (_undoEnabled ?? true) ? _onUndoPressed : null,
                  enabled: _undoEnabled ?? true,
                ),
                // Hint button
                _GameActionButton(
                  icon: Icons.lightbulb_outline_rounded,
                  label: 'Hint',
                  onPressed: _onHintPressed,
                  enabled: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Define navigation items based on variant
    final items = _getNavigationItems(isDark);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            // Navigate to appropriate screen based on index
            _handleNavigation(context, index);
            onTap(index);
          },
          items: items,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: theme.bottomNavigationBarTheme.selectedItemColor,
          unselectedItemColor:
              theme.bottomNavigationBarTheme.unselectedItemColor,
          selectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 24,
        ),
      ),
    );
  }

  /// Get navigation items based on variant
  List<BottomNavigationBarItem> _getNavigationItems(bool isDark) {
    switch (variant) {
      case BottomBarVariant.main:
        return [
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            activeIcon: Icon(Icons.grid_view),
            label: 'Levels',
            tooltip: 'Level Select',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
            tooltip: 'Settings',
          ),
        ];
    }
  }

  /// Handle navigation based on selected index
  void _handleNavigation(BuildContext context, int index) {
    switch (variant) {
      case BottomBarVariant.main:
        switch (index) {
          case 0:
            // Navigate to Level Select
            if (ModalRoute.of(context)?.settings.name != '/level-select-menu') {
              Navigator.pushReplacementNamed(context, '/level-select-menu');
            }
            break;
          case 1:
            // Navigate to Settings
            if (ModalRoute.of(context)?.settings.name != '/settings-screen') {
              Navigator.pushNamed(context, '/settings-screen');
            }
            break;
        }
        break;
    }
  }
}

/// Action button for game screen bottom bar
class _GameActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  const _GameActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = enabled
        ? (isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1))
        : (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF));

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Enum defining different bottom bar variants
enum BottomBarVariant {
  /// Main navigation bar for app-level navigation
  main,
}
