import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

/// Level Complete Screen - Celebrates successful puzzle completion
/// Features: Particle effects, star rating, achievement summary, progression options
class LevelCompleteScreen extends StatefulWidget {
  const LevelCompleteScreen({super.key});

  @override
  State<LevelCompleteScreen> createState() => _LevelCompleteScreenState();
}

class _LevelCompleteScreenState extends State<LevelCompleteScreen>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _particleController;
  late AnimationController _contentController;
  late AnimationController _starController;
  late AnimationController _countdownController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;

  // Level data (passed via route arguments or mock data)
  int currentLevel = 5;
  int starsEarned = 3;
  String completionTime = "45s";
  int hintsUsed = 1;
  bool isFirstTry = true;
  bool heartBonus = true;
  bool isDailyChallenge = false;
  int leaderboardPosition = 12;
  bool isFinalLevel = false;

  // Auto-progression
  int countdownSeconds = 5;
  bool userInteracted = false;

  // Particle system
  final List<Particle> particles = [];
  final int particleCount = 50;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
    _startCountdown();
  }

  void _initializeAnimations() {
    // Particle animation (continuous)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // Content reveal animation
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    // Star animation (staggered)
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Countdown animation
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Start animations
    _contentController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _starController.forward();
    });
  }

  void _generateParticles() {
    final random = math.Random();
    for (int i = 0; i < particleCount; i++) {
      particles.add(
        Particle(
          x: random.nextDouble(),
          y: random.nextDouble(),
          size: random.nextDouble() * 4 + 2,
          speed: random.nextDouble() * 0.5 + 0.3,
          color: _getRandomParticleColor(random),
        ),
      );
    }
  }

  Color _getRandomParticleColor(math.Random random) {
    final colors = [
      AppTheme.lightTheme.colorScheme.tertiary,
      AppTheme.lightTheme.colorScheme.primary,
      AppTheme.lightTheme.colorScheme.secondary,
      const Color(0xFFFBBF24),
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted || userInteracted) return;
      _countdownController.forward(from: 0);
      setState(() => countdownSeconds--);

      if (countdownSeconds > 0) {
        _startCountdown();
      } else {
        _navigateToNextLevel();
      }
    });
  }

  void _handleUserInteraction() {
    setState(() => userInteracted = true);
  }

  void _navigateToNextLevel() {
    if (isFinalLevel) {
      Navigator.pushReplacementNamed(context, '/level-select-menu');
    } else {
      Navigator.pushReplacementNamed(
        context,
        '/game-screen',
        arguments: {'level': currentLevel + 1},
      );
    }
  }

  void _replayLevel() {
    _handleUserInteraction();
    Navigator.pushReplacementNamed(
      context,
      '/game-screen',
      arguments: {'level': currentLevel},
    );
  }

  void _shareAchievement() {
    _handleUserInteraction();
    // Share functionality would be implemented here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Share feature coming soon!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: EdgeInsets.all(4.w),
      ),
    );
  }

  @override
  void dispose() {
    _particleController.dispose();
    _contentController.dispose();
    _starController.dispose();
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark.withValues(alpha: 0.95)
          : AppTheme.backgroundLight.withValues(alpha: 0.95),
      appBar: CustomAppBar(
        title: 'Level $currentLevel',
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'close',
            color: isDark
                ? AppTheme.textHighEmphasisDark
                : AppTheme.textHighEmphasisLight,
            size: 24,
          ),
          onPressed: () {
            _handleUserInteraction();
            Navigator.pushReplacementNamed(context, '/level-select-menu');
          },
        ),
      ),
      body: Stack(
        children: [
          // Particle effects background
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                painter: ParticlePainter(
                  particles: particles,
                  animation: _particleController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _contentController,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: child,
                    ),
                  ),
                );
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Celebration icon
                    Container(
                      width: 20.w,
                      height: 20.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.tertiary,
                            AppTheme.lightTheme.colorScheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: CustomIconWidget(
                          iconName: isFinalLevel ? 'emoji_events' : 'check',
                          color: Colors.white,
                          size: 10.w,
                        ),
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Title
                    Text(
                      isFinalLevel ? 'All Levels Complete!' : 'Level Complete!',
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textHighEmphasisDark
                            : AppTheme.textHighEmphasisLight,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 1.h),

                    // Subtitle
                    Text(
                      isFinalLevel
                          ? 'Congratulations on completing all levels!'
                          : 'Great job! You solved the puzzle!',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark
                            ? AppTheme.textMediumEmphasisDark
                            : AppTheme.textMediumEmphasisLight,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 4.h),

                    // Star rating
                    _buildStarRating(isDark),

                    SizedBox(height: 4.h),

                    // Achievement summary
                    _buildAchievementSummary(isDark),

                    SizedBox(height: 3.h),

                    // Heart bonus (if applicable)
                    if (heartBonus) _buildHeartBonus(isDark),

                    // Daily challenge badge (if applicable)
                    if (isDailyChallenge) _buildDailyChallengeBadge(isDark),

                    SizedBox(height: 4.h),

                    // Action buttons
                    _buildActionButtons(isDark),

                    SizedBox(height: 2.h),

                    // Auto-progression countdown
                    if (!userInteracted && !isFinalLevel)
                      _buildCountdownIndicator(isDark),

                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarRating(bool isDark) {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_starController.value - delay).clamp(
              0.0,
              1.0,
            );
            final isEarned = index < starsEarned;

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: Transform.scale(
                scale: Curves.elasticOut.transform(animationValue),
                child: CustomIconWidget(
                  iconName: isEarned ? 'star' : 'star_border',
                  color: isEarned
                      ? const Color(0xFFFBBF24)
                      : (isDark
                            ? AppTheme.textDisabledDark
                            : AppTheme.textDisabledLight),
                  size: 15.w,
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildAchievementSummary(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Performance Summary',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: isDark
                  ? AppTheme.textHighEmphasisDark
                  : AppTheme.textHighEmphasisLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.h),
          _buildMetricRow(
            'Time',
            completionTime,
            'schedule',
            _getTimeColor(),
            isDark,
          ),
          SizedBox(height: 1.5.h),
          _buildMetricRow(
            'Hints Used',
            '$hintsUsed',
            'lightbulb_outline',
            hintsUsed == 0 ? AppTheme.successLight : AppTheme.warningLight,
            isDark,
          ),
          SizedBox(height: 1.5.h),
          _buildMetricRow(
            'First Try',
            isFirstTry ? 'Yes' : 'No',
            isFirstTry ? 'check_circle' : 'cancel',
            isFirstTry ? AppTheme.successLight : AppTheme.errorLight,
            isDark,
          ),
          if (isDailyChallenge) ...[
            SizedBox(height: 1.5.h),
            _buildMetricRow(
              'Leaderboard',
              '#$leaderboardPosition',
              'leaderboard',
              AppTheme.lightTheme.colorScheme.secondary,
              isDark,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    String iconName,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 5.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getTimeColor() {
    final seconds = int.tryParse(completionTime.replaceAll('s', '')) ?? 0;
    if (seconds <= 30) return AppTheme.successLight;
    if (seconds <= 60) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  Widget _buildHeartBonus(bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2),
            AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.tertiary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'favorite',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text(
            '+1 Heart Bonus!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.tertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChallengeBadge(bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
        ),
        borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFBBF24).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'emoji_events',
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(width: 2.w),
          Text(
            'Daily Challenge Complete!',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Column(
      children: [
        // Next Level button
        if (!isFinalLevel)
          SizedBox(
            width: double.infinity,
            height: 6.h,
            child: ElevatedButton(
              onPressed: () {
                _handleUserInteraction();
                _navigateToNextLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppTheme.buttonBorderRadius,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Next Level',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: Colors.white,
                    size: 5.w,
                  ),
                ],
              ),
            ),
          ),

        SizedBox(height: 2.h),

        // Replay Level button
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: OutlinedButton(
            onPressed: _replayLevel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.lightTheme.colorScheme.primary,
              side: BorderSide(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppTheme.buttonBorderRadius,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'replay',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Replay Level',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Share Achievement button
        TextButton.icon(
          onPressed: _shareAchievement,
          icon: CustomIconWidget(
            iconName: 'share',
            color: isDark
                ? AppTheme.textMediumEmphasisDark
                : AppTheme.textMediumEmphasisLight,
            size: 5.w,
          ),
          label: Text(
            'Share Achievement',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isDark
                  ? AppTheme.textMediumEmphasisDark
                  : AppTheme.textMediumEmphasisLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountdownIndicator(bool isDark) {
    return AnimatedBuilder(
      animation: _countdownController,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.cardDark.withValues(alpha: 0.8)
                : AppTheme.cardLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.3,
              ),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 4.w,
                height: 4.w,
                child: CircularProgressIndicator(
                  value: _countdownController.value,
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                'Next level in ${countdownSeconds}s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Particle class for celebration effects
class Particle {
  double x;
  double y;
  final double size;
  final double speed;
  final Color color;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.color,
  });
}

// Custom painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({required this.particles, required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var particle in particles) {
      // Update particle position
      particle.y = (particle.y + particle.speed * 0.01) % 1.0;

      // Calculate screen position
      final dx = particle.x * size.width;
      final dy = particle.y * size.height;

      // Draw particle with fade effect
      final opacity = (1.0 - particle.y) * 0.6;
      paint.color = particle.color.withValues(alpha: opacity);

      canvas.drawCircle(Offset(dx, dy), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
