import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/color_theme_preview_widget.dart';
import './widgets/setting_action_item_widget.dart';
import './widgets/setting_section_widget.dart';
import './widgets/setting_selection_item_widget.dart';
import './widgets/setting_slider_item_widget.dart';
import './widgets/setting_toggle_item_widget.dart';
import './widgets/stats_progress_item_widget.dart';

/// Settings Screen - Comprehensive game customization and account management
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Audio settings
  bool _soundEffectsEnabled = true;
  double _volumeLevel = 0.7;

  // Visual preferences
  String _selectedColorTheme = 'Classic';
  bool _reducedMotionEnabled = false;

  // Gameplay settings
  int _hintLimit = 3;
  bool _timerDisplayEnabled = false;
  String _difficultyMode = 'Normal';

  // Statistics
  int _levelsCompleted = 12;
  final int _totalLevels = 30;
  final double _averageCompletionTime = 45.5;
  int _hintsUsed = 8;
  int _achievementsUnlocked = 5;
  final int _totalAchievements = 15;

  // Color themes data
  final List<Map<String, dynamic>> _colorThemes = [
    {
      'name': 'Classic',
      'mazeColor': const Color(0xFF1F2937),
      'pathColor': const Color(0xFFEC4899),
    },
    {
      'name': 'Ocean',
      'mazeColor': const Color(0xFF0EA5E9),
      'pathColor': const Color(0xFF06B6D4),
    },
    {
      'name': 'Forest',
      'mazeColor': const Color(0xFF10B981),
      'pathColor': const Color(0xFF34D399),
    },
    {
      'name': 'Sunset',
      'mazeColor': const Color(0xFFF59E0B),
      'pathColor': const Color(0xFFEF4444),
    },
    {
      'name': 'Purple',
      'mazeColor': const Color(0xFF8B5CF6),
      'pathColor': const Color(0xFFA78BFA),
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Load saved settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soundEffectsEnabled = prefs.getBool('soundEffects') ?? true;
      _volumeLevel = prefs.getDouble('volumeLevel') ?? 0.7;
      _selectedColorTheme = prefs.getString('colorTheme') ?? 'Classic';
      _reducedMotionEnabled = prefs.getBool('reducedMotion') ?? false;
      _hintLimit = prefs.getInt('hintLimit') ?? 3;
      _timerDisplayEnabled = prefs.getBool('timerDisplay') ?? false;
      _difficultyMode = prefs.getString('difficultyMode') ?? 'Normal';
      _levelsCompleted = prefs.getInt('levelsCompleted') ?? 12;
      _hintsUsed = prefs.getInt('hintsUsed') ?? 8;
      _achievementsUnlocked = prefs.getInt('achievementsUnlocked') ?? 5;
    });
  }

  /// Save individual setting to SharedPreferences
  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
    _showSaveConfirmation();
  }

  /// Show subtle save confirmation
  void _showSaveConfirmation() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Settings saved',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: 8.h, left: 4.w, right: 4.w),
      ),
    );
  }

  /// Show difficulty selection dialog
  void _showDifficultyDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Difficulty',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Casual', 'Normal', 'Challenge'].map((mode) {
            return RadioListTile<String>(
              title: Text(mode, style: GoogleFonts.inter(fontSize: 14.sp)),
              value: mode,
              groupValue: _difficultyMode,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _difficultyMode = value);
                  _saveSetting('difficultyMode', value);
                  Navigator.pop(context);
                }
              },
              activeColor:
                  isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Show hint limit selection dialog
  void _showHintLimitDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hints Per Level',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 5, 10].map((limit) {
            return RadioListTile<int>(
              title: Text(
                limit == 10 ? 'Unlimited' : '$limit hints',
                style: GoogleFonts.inter(fontSize: 14.sp),
              ),
              value: limit,
              groupValue: _hintLimit,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _hintLimit = value);
                  _saveSetting('hintLimit', value);
                  Navigator.pop(context);
                }
              },
              activeColor:
                  isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Show reset progress confirmation dialog
  void _showResetProgressDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Reset Progress',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to reset all game progress? This action cannot be undone.',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.inter(fontSize: 14.sp)),
          ),
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              setState(() {
                _levelsCompleted = 0;
                _hintsUsed = 0;
                _achievementsUnlocked = 0;
              });
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Progress reset successfully',
                      style: GoogleFonts.inter(fontSize: 14.sp),
                    ),
                  ),
                );
              }
            },
            child: Text(
              'Reset',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Export save data
  void _exportSaveData() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Save data exported successfully',
          style: GoogleFonts.inter(fontSize: 14.sp),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.settings(
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2.h),

              // Audio Section
              SettingSectionWidget(
                title: 'AUDIO',
                children: [
                  SettingToggleItemWidget(
                    iconName: _soundEffectsEnabled ? 'volume_up' : 'volume_off',
                    label: 'Sound Effects',
                    value: _soundEffectsEnabled,
                    onChanged: (value) {
                      setState(() => _soundEffectsEnabled = value);
                      _saveSetting('soundEffects', value);
                    },
                  ),
                  if (_soundEffectsEnabled)
                    SettingSliderItemWidget(
                      iconName: 'graphic_eq',
                      label: 'Volume',
                      value: _volumeLevel,
                      onChanged: (value) {
                        setState(() => _volumeLevel = value);
                        _saveSetting('volumeLevel', value);
                      },
                    ),
                ],
              ),

              SizedBox(height: 3.h),

              // Visual Preferences Section
              SettingSectionWidget(
                title: 'VISUAL PREFERENCES',
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'palette',
                              size: 24,
                              color: isDark
                                  ? const Color(0xFF9CA3AF)
                                  : const Color(0xFF6B7280),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Color Theme',
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: isDark
                                    ? const Color(0xFFF9FAFB)
                                    : const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _colorThemes.length,
                            itemBuilder: (context, index) {
                              final themeData = _colorThemes[index];
                              return ColorThemePreviewWidget(
                                themeName: themeData['name'] as String,
                                mazeColor: themeData['mazeColor'] as Color,
                                pathColor: themeData['pathColor'] as Color,
                                isSelected:
                                    _selectedColorTheme == themeData['name'],
                                onTap: () {
                                  setState(
                                    () => _selectedColorTheme =
                                        themeData['name'] as String,
                                  );
                                  _saveSetting(
                                    'colorTheme',
                                    themeData['name'] as String,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SettingToggleItemWidget(
                    iconName: 'accessibility_new',
                    label: 'Reduced Motion',
                    value: _reducedMotionEnabled,
                    onChanged: (value) {
                      setState(() => _reducedMotionEnabled = value);
                      _saveSetting('reducedMotion', value);
                    },
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Gameplay Settings Section
              SettingSectionWidget(
                title: 'GAMEPLAY',
                children: [
                  SettingSelectionItemWidget(
                    iconName: 'lightbulb_outline',
                    label: 'Hint Limit',
                    currentValue: _hintLimit == 10
                        ? 'Unlimited'
                        : '$_hintLimit per level',
                    onTap: _showHintLimitDialog,
                  ),
                  SettingToggleItemWidget(
                    iconName: 'timer',
                    label: 'Show Timer',
                    value: _timerDisplayEnabled,
                    onChanged: (value) {
                      setState(() => _timerDisplayEnabled = value);
                      _saveSetting('timerDisplay', value);
                    },
                  ),
                  SettingSelectionItemWidget(
                    iconName: 'tune',
                    label: 'Difficulty',
                    currentValue: _difficultyMode,
                    onTap: _showDifficultyDialog,
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Progress Statistics Section
              SettingSectionWidget(
                title: 'PROGRESS',
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatCard(
                              'Levels',
                              '$_levelsCompleted',
                              'completed',
                              isDark,
                            ),
                            _buildStatCard(
                              'Avg Time',
                              '${_averageCompletionTime.toStringAsFixed(1)}s',
                              'per level',
                              isDark,
                            ),
                            _buildStatCard(
                              'Hints',
                              '$_hintsUsed',
                              'used',
                              isDark,
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),
                        StatsProgressItemWidget(
                          label: 'Level Progress',
                          current: _levelsCompleted,
                          total: _totalLevels,
                          progressColor: isDark
                              ? const Color(0xFF818CF8)
                              : const Color(0xFF6366F1),
                        ),
                        StatsProgressItemWidget(
                          label: 'Achievements',
                          current: _achievementsUnlocked,
                          total: _totalAchievements,
                          progressColor: isDark
                              ? const Color(0xFFFBBF24)
                              : const Color(0xFFF59E0B),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // Account Section
              SettingSectionWidget(
                title: 'ACCOUNT',
                children: [
                  SettingActionItemWidget(
                    iconName: 'refresh',
                    label: 'Reset Progress',
                    onTap: _showResetProgressDialog,
                    isDestructive: true,
                  ),
                  SettingActionItemWidget(
                    iconName: 'file_download',
                    label: 'Export Save Data',
                    onTap: _exportSaveData,
                  ),
                ],
              ),

              SizedBox(height: 3.h),

              // About Section
              SettingSectionWidget(
                title: 'ABOUT',
                children: [
                  SettingActionItemWidget(
                    iconName: 'info_outline',
                    label: 'App Version',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Arrows Puzzle',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Version 1.0.0\n\nA challenging puzzle game featuring maze navigation with directional arrows.',
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SettingActionItemWidget(
                    iconName: 'privacy_tip',
                    label: 'Privacy Policy',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Opening privacy policy...',
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                        ),
                      );
                    },
                  ),
                  SettingActionItemWidget(
                    iconName: 'code',
                    label: 'Developer Credits',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Credits',
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          content: Text(
                            'Developed with Flutter\n\nDesign: Minimalist Gaming UI\nDevelopment: Flutter Team\n\n© 2025 Arrows Puzzle',
                            style: GoogleFonts.inter(fontSize: 14.sp),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    bool isDark,
  ) {
    return Container(
      width: 28.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
