import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

/// Splash Screen - Branded app launch experience with initialization
///
/// Features:
/// - Animated logo with scale effect (respects reduced motion)
/// - Background initialization of game systems
/// - Smart navigation based on user progress
/// - Graceful error handling with retry mechanism
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _initializationFailed = false;
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _initializeApp();
  }

  /// Setup logo scale animation with accessibility support
  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    // Check for reduced motion preference
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .reduceMotion;

    if (!reduceMotion) {
      _animationController.forward();
    } else {
      // Skip animation if reduced motion is enabled
      _animationController.value = 1.0;
    }
  }

  /// Initialize app systems and load saved progress
  Future<void> _initializeApp() async {
    try {
      // Hide system UI for immersive splash experience
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

      // Minimum display time for branding (2 seconds)
      await Future.delayed(const Duration(seconds: 2));

      // Initialize SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // Load saved game progress
      final hasCompletedOnboarding =
          prefs.getBool('completed_onboarding') ?? false;
      final currentLevel = prefs.getInt('current_level') ?? 1;
      final completedDailyChallenge =
          prefs.getBool(
            'completed_daily_challenge_${DateTime.now().toString().split(' ')[0]}',
          ) ??
          false;

      // Validate level unlock status
      final unlockedLevels = prefs.getInt('unlocked_levels') ?? 1;

      // Additional initialization time for smooth transition
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      // Restore system UI before navigation
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );

      // Navigate based on user progress
      _navigateToNextScreen(
        hasCompletedOnboarding: hasCompletedOnboarding,
        currentLevel: currentLevel,
        completedDailyChallenge: completedDailyChallenge,
        unlockedLevels: unlockedLevels,
      );
    } catch (e) {
      // Handle initialization failure
      if (mounted) {
        setState(() {
          _initializationFailed = true;
        });

        // Auto-retry after 5 seconds
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && !_isRetrying) {
            _retryInitialization();
          }
        });
      }
    }
  }

  /// Navigate to appropriate screen based on user state
  void _navigateToNextScreen({
    required bool hasCompletedOnboarding,
    required int currentLevel,
    required bool completedDailyChallenge,
    required int unlockedLevels,
  }) {
    // Fade transition for smooth navigation
    Navigator.pushReplacementNamed(
      context,
      hasCompletedOnboarding ? '/level-select-menu' : '/onboarding-tutorial',
    );
  }

  /// Retry initialization after failure
  Future<void> _retryInitialization() async {
    setState(() {
      _initializationFailed = false;
      _isRetrying = true;
    });

    await _initializeApp();

    if (mounted) {
      setState(() {
        _isRetrying = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Ensure system UI is restored
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: _initializationFailed
              ? _buildErrorState()
              : _buildSplashContent(),
        ),
      ),
    );
  }

  /// Build main splash content with animated logo
  Widget _buildSplashContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: 2),
        // Animated logo
        ScaleTransition(scale: _scaleAnimation, child: _buildLogo()),
        SizedBox(height: 4.h),
        // Loading indicator
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        const Spacer(flex: 3),
      ],
    );
  }

  /// Build game logo with arrow design
  Widget _buildLogo() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Arrow icon representing the game
          CustomIconWidget(
            iconName: 'arrow_forward',
            size: 15.w,
            color: AppTheme.lightTheme.colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          // Game title
          Text(
            'Arrows',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            'PUZZLE',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.0,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Error icon
          Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.errorContainer.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'error_outline',
                size: 12.w,
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          // Error message
          Text(
            'Initialization Failed',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Unable to load game data. Please check your connection and try again.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          // Retry button
          SizedBox(
            width: 50.w,
            height: 6.h,
            child: ElevatedButton(
              onPressed: _isRetrying ? null : _retryInitialization,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isRetrying
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Retry',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const Spacer(flex: 3),
          // Auto-retry message
          if (!_isRetrying)
            Text(
              'Auto-retry in 5 seconds...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
