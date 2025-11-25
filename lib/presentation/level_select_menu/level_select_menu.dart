import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/daily_challenge_card_widget.dart';
import './widgets/heart_counter_widget.dart';
import './widgets/level_card_widget.dart';
import './widgets/progress_header_widget.dart';

/// Level Select Menu screen for choosing puzzle levels
class LevelSelectMenu extends StatefulWidget {
  const LevelSelectMenu({super.key});

  @override
  State<LevelSelectMenu> createState() => _LevelSelectMenuState();
}

class _LevelSelectMenuState extends State<LevelSelectMenu> {
  final int _totalLevels = 30;
  int _currentLevel = 1;
  int _completedLevels = 0;
  int _currentHearts = 5;
  final int _maxHearts = 5;
  String? _heartRegenerationTime;
  bool _isDailyChallengeCompleted = false;
  int _dailyChallengeStars = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;

  // Mock level data
  final Map<int, Map<String, dynamic>> _levelData = {};

  @override
  void initState() {
    super.initState();
    _loadGameProgress();
    _calculateHeartRegeneration();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Load game progress from local storage
  Future<void> _loadGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _currentLevel = prefs.getInt('current_level') ?? 1;
        _completedLevels = prefs.getInt('completed_levels') ?? 0;
        _currentHearts = prefs.getInt('current_hearts') ?? 5;
        _isDailyChallengeCompleted =
            prefs.getBool('daily_challenge_completed') ?? false;
        _dailyChallengeStars = prefs.getInt('daily_challenge_stars') ?? 0;

        // Load level data
        for (int i = 1; i <= _totalLevels; i++) {
          final stars = prefs.getInt('level_${i}_stars') ?? 0;
          final bestTime = prefs.getString('level_${i}_best_time');
          final hintsUsed = prefs.getInt('level_${i}_hints_used');

          _levelData[i] = {
            'stars': stars,
            'bestTime': bestTime,
            'hintsUsed': hintsUsed,
            'isCompleted': stars > 0,
          };
        }
      });
    } catch (e) {
      debugPrint('Error loading game progress: $e');
    }
  }

  /// Save game progress to local storage
  Future<void> _saveGameProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('current_level', _currentLevel);
      await prefs.setInt('completed_levels', _completedLevels);
      await prefs.setInt('current_hearts', _currentHearts);
      await prefs.setBool(
        'daily_challenge_completed',
        _isDailyChallengeCompleted,
      );
      await prefs.setInt('daily_challenge_stars', _dailyChallengeStars);
    } catch (e) {
      debugPrint('Error saving game progress: $e');
    }
  }

  /// Calculate heart regeneration time
  void _calculateHeartRegeneration() {
    if (_currentHearts < _maxHearts) {
      setState(() {
        _heartRegenerationTime = '15:30';
      });
    } else {
      setState(() {
        _heartRegenerationTime = null;
      });
    }
  }

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No new daily challenge available',
            style: GoogleFonts.inter(fontSize: 12.sp),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Handle level selection
  void _handleLevelTap(int levelNumber) {
    if (_currentHearts <= 0) {
      _showNoHeartsDialog();
      return;
    }

    Navigator.pushNamed(
      context,
      '/game-screen',
      arguments: {'levelNumber': levelNumber},
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        _handleLevelCompletion(result);
      }
    });
  }

  /// Handle level completion result
  void _handleLevelCompletion(Map<String, dynamic> result) {
    final levelNumber = result['levelNumber'] as int;
    final stars = result['stars'] as int;
    final time = result['time'] as String;
    final hints = result['hintsUsed'] as int;

    setState(() {
      _levelData[levelNumber] = {
        'stars': stars,
        'bestTime': time,
        'hintsUsed': hints,
        'isCompleted': true,
      };

      if (levelNumber == _currentLevel) {
        _currentLevel++;
        _completedLevels++;
      }
    });

    _saveGameProgress();
  }

  /// Show no hearts dialog
  void _showNoHeartsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'No Hearts Left',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Wait for hearts to regenerate or watch an ad to continue playing.',
          style: GoogleFonts.inter(fontSize: 12.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  /// Show level options on long press
  void _showLevelOptions(int levelNumber) {
    final levelInfo = _levelData[levelNumber];
    if (levelInfo == null || !(levelInfo['isCompleted'] as bool)) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Level $levelNumber',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'replay',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                title: Text(
                  'Replay Level',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleLevelTap(levelNumber);
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'visibility',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                title: Text(
                  'View Solution',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Solution viewer coming soon!',
                        style: GoogleFonts.inter(fontSize: 12.sp),
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: CustomIconWidget(
                  iconName: 'share',
                  size: 24,
                  color: AppTheme.lightTheme.primaryColor,
                ),
                title: Text(
                  'Share Score',
                  style: GoogleFonts.inter(fontSize: 14.sp),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Share feature coming soon!',
                        style: GoogleFonts.inter(fontSize: 12.sp),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle daily challenge tap
  void _handleDailyChallengeTap() {
    if (_currentHearts <= 0) {
      _showNoHeartsDialog();
      return;
    }

    Navigator.pushNamed(
      context,
      '/game-screen',
      arguments: {'levelNumber': 0, 'isDailyChallenge': true},
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {
        setState(() {
          _isDailyChallengeCompleted = true;
          _dailyChallengeStars = result['stars'] as int;
        });
        _saveGameProgress();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.levelSelect(
        onSettingsPressed: () {
          Navigator.pushNamed(context, '/settings-screen');
        },
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Top padding
            SliverToBoxAdapter(child: SizedBox(height: 2.h)),
            // Progress header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: ProgressHeaderWidget(
                  completedLevels: _completedLevels,
                  totalLevels: _totalLevels,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 2.h)),
            // Daily challenge card
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: DailyChallengeCardWidget(
                  timeRemaining: '23:45:30',
                  isCompleted: _isDailyChallengeCompleted,
                  starsEarned: _dailyChallengeStars,
                  onTap: _handleDailyChallengeTap,
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 3.h)),
            // Levels section header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  'All Levels',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.textHighEmphasisDark
                        : AppTheme.textHighEmphasisLight,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 2.h)),
            // Level grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final levelNumber = index + 1;
                  final isLocked = levelNumber > _currentLevel;
                  final isCurrent = levelNumber == _currentLevel;
                  final levelInfo = _levelData[levelNumber];

                  return LevelCardWidget(
                    levelNumber: levelNumber,
                    starsEarned: levelInfo?['stars'] ?? 0,
                    isLocked: isLocked,
                    isCurrent: isCurrent,
                    bestTime: levelInfo?['bestTime'],
                    hintsUsed: levelInfo?['hintsUsed'],
                    onTap: () => _handleLevelTap(levelNumber),
                    onLongPress: () => _showLevelOptions(levelNumber),
                  );
                }, childCount: _totalLevels),
              ),
            ),
            // Bottom padding
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Heart counter
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            child: HeartCounterWidget(
              currentHearts: _currentHearts,
              maxHearts: _maxHearts,
              regenerationTime: _heartRegenerationTime,
            ),
          ),
          // Bottom navigation bar
          CustomBottomBar.main(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushNamed(context, '/settings-screen');
              }
            },
          ),
        ],
      ),
    );
  }
}
