import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';

/// Onboarding Tutorial Screen
/// Introduces new players to core maze navigation mechanics through interactive demonstration
class OnboardingTutorial extends StatefulWidget {
  const OnboardingTutorial({super.key});

  @override
  State<OnboardingTutorial> createState() => _OnboardingTutorialState();
}

class _OnboardingTutorialState extends State<OnboardingTutorial>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _fingerAnimationController;
  late AnimationController _hintAnimationController;
  late Animation<Offset> _fingerSlideAnimation;
  late Animation<double> _hintPulseAnimation;

  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Draw Your Path',
      description:
          'Touch and drag from the start point to trace your path through the maze',
      imagePath:
          'https://images.unsplash.com/photo-1611996575749-79a3a250f948?w=800&q=80',
      semanticLabel:
          'Simplified maze grid with bright pink path drawn from start to finish point',
      animationType: TutorialAnimationType.fingerDrag,
    ),
    TutorialStep(
      title: 'Follow the Arrows',
      description:
          'Your path must follow the direction shown by each arrow you pass through',
      imagePath:
          'https://images.unsplash.com/photo-1516981442399-a91139e20ff8?w=800&q=80',
      semanticLabel:
          'Maze with directional arrows highlighted showing correct path tracing',
      animationType: TutorialAnimationType.arrowHighlight,
    ),
    TutorialStep(
      title: 'Use Hints Wisely',
      description:
          'Tap the light bulb icon to reveal the next 2-3 moves when you\'re stuck',
      imagePath:
          'https://images.unsplash.com/photo-1534670007418-fbb7f6cf32c3?w=800&q=80',
      semanticLabel:
          'Game interface showing light bulb hint icon with glowing effect',
      animationType: TutorialAnimationType.hintPulse,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Finger drag animation
    _fingerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _fingerSlideAnimation =
        Tween<Offset>(
          begin: const Offset(-0.3, -0.3),
          end: const Offset(0.3, 0.3),
        ).animate(
          CurvedAnimation(
            parent: _fingerAnimationController,
            curve: Curves.easeInOut,
          ),
        );

    // Hint pulse animation
    _hintAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _hintPulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _hintAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fingerAnimationController.dispose();
    _hintAnimationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeTutorial();
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  void _completeTutorial() {
    Navigator.pushReplacementNamed(context, '/level-select-menu');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.tutorial(onSkipPressed: _skipTutorial),
      body: SafeArea(
        child: Column(
          children: [
            // Tutorial content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _tutorialSteps.length,
                itemBuilder: (context, index) {
                  return _buildTutorialPage(
                    _tutorialSteps[index],
                    index,
                    isDark,
                  );
                },
              ),
            ),

            // Progress indicators and navigation
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
              child: Column(
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _tutorialSteps.length,
                      (index) => _buildProgressDot(index, isDark),
                    ),
                  ),
                  SizedBox(height: 3.h),

                  // Next button
                  SizedBox(
                    width: double.infinity,
                    height: 6.h,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? AppTheme.primaryDark
                            : AppTheme.primaryLight,
                        foregroundColor: isDark
                            ? AppTheme.onPrimaryDark
                            : AppTheme.onPrimaryLight,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppTheme.defaultBorderRadius,
                          ),
                        ),
                        elevation: AppTheme.buttonElevation,
                      ),
                      child: Text(
                        _currentPage == _tutorialSteps.length - 1
                            ? 'Get Started'
                            : 'Next',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step, int index, bool isDark) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 4.h),

            // Tutorial illustration with animation
            Container(
              width: 80.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardDark : AppTheme.cardLight,
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.cardBorderRadius),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background image
                    CustomImageWidget(
                      imageUrl: step.imagePath,
                      width: 80.w,
                      height: 40.h,
                      fit: BoxFit.cover,
                      semanticLabel: step.semanticLabel,
                    ),

                    // Overlay with animation
                    _buildAnimationOverlay(step.animationType, isDark),
                  ],
                ),
              ),
            ),

            SizedBox(height: 4.h),

            // Title
            Text(
              step.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppTheme.textHighEmphasisDark
                    : AppTheme.textHighEmphasisLight,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 2.h),

            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                step.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  color: isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationOverlay(TutorialAnimationType type, bool isDark) {
    switch (type) {
      case TutorialAnimationType.fingerDrag:
        return SlideTransition(
          position: _fingerSlideAnimation,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color:
                  (isDark ? AppTheme.pathActiveDark : AppTheme.pathActiveLight)
                      .withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color:
                      (isDark
                              ? AppTheme.pathActiveDark
                              : AppTheme.pathActiveLight)
                          .withValues(alpha: 0.5),
                  blurRadius: 12,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'touch_app',
                color: Colors.white,
                size: 6.w,
              ),
            ),
          ),
        );

      case TutorialAnimationType.arrowHighlight:
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                (isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight)
                    .withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'arrow_forward',
              color: isDark ? AppTheme.secondaryDark : AppTheme.secondaryLight,
              size: 15.w,
            ),
          ),
        );

      case TutorialAnimationType.hintPulse:
        return ScaleTransition(
          scale: _hintPulseAnimation,
          child: Container(
            width: 20.w,
            height: 20.w,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.warningDark : AppTheme.warningLight)
                  .withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppTheme.warningDark : AppTheme.warningLight)
                      .withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'lightbulb',
                color: Colors.white,
                size: 10.w,
              ),
            ),
          ),
        );
    }
  }

  Widget _buildProgressDot(int index, bool isDark) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 1.w),
      width: isActive ? 8.w : 2.w,
      height: 2.w,
      decoration: BoxDecoration(
        color: isActive
            ? (isDark ? AppTheme.primaryDark : AppTheme.primaryLight)
            : (isDark ? AppTheme.textDisabledDark : AppTheme.textDisabledLight),
        borderRadius: BorderRadius.circular(1.w),
      ),
    );
  }
}

/// Tutorial step data model
class TutorialStep {
  final String title;
  final String description;
  final String imagePath;
  final String semanticLabel;
  final TutorialAnimationType animationType;

  TutorialStep({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.semanticLabel,
    required this.animationType,
  });
}

/// Animation types for tutorial demonstrations
enum TutorialAnimationType { fingerDrag, arrowHighlight, hintPulse }
