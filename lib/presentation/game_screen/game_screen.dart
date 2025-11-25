import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/celebration_overlay.dart';
import './widgets/heart_counter_widget.dart';
import './widgets/hint_counter_widget.dart';
import './widgets/maze_painter.dart';
import './widgets/timer_widget.dart';

class GameScreen extends StatefulWidget {
  final int levelNumber;

  const GameScreen({
    super.key,
    this.levelNumber = 1,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  // Game state
  late List<List<MazeCell>> _grid;
  List<Offset> _currentPath = [];
  List<Offset> _completedPath = [];
  final List<List<Offset>> _pathHistory = [];

  // Player stats
  int _currentHearts = 5;
  int _remainingHints = 3;
  bool _isFirstTry = true;

  // Timer
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  bool _isTimerRunning = false;

  // Touch state
  bool _isDrawing = false;
  Offset? _lastValidCell;

  // Animation
  bool _showCelebration = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeLevel();
    _startTimer();
    _initializeAnimations();
    _loadProgress();
  }

  void _initializeAnimations() {
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 10)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  void _initializeLevel() {
    // Generate maze based on level number
    final gridSize = _getGridSize(widget.levelNumber);
    _grid = _generateMaze(gridSize, widget.levelNumber);
  }

  int _getGridSize(int level) {
    if (level <= 5) return 4;
    if (level <= 10) return 5;
    if (level <= 20) return 6;
    return 7;
  }

  List<List<MazeCell>> _generateMaze(int size, int level) {
    // Generate maze with increasing complexity
    final grid = List.generate(
      size,
      (row) => List.generate(
        size,
        (col) => MazeCell(
          arrowDirection: _getArrowDirection(row, col, size, level),
          isStart: row == 0 && col == 0,
          isEnd: row == size - 1 && col == size - 1,
        ),
      ),
    );
    return grid;
  }

  ArrowDirection _getArrowDirection(int row, int col, int size, int level) {
    // Start and end cells have no arrows
    if ((row == 0 && col == 0) || (row == size - 1 && col == size - 1)) {
      return ArrowDirection.none;
    }

    // Generate arrow pattern based on level
    final seed = level * 100 + row * 10 + col;
    final directions = [
      ArrowDirection.up,
      ArrowDirection.down,
      ArrowDirection.left,
      ArrowDirection.right,
    ];

    return directions[seed % directions.length];
  }

  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTimerRunning) {
        setState(() {
          _elapsedTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _timer?.cancel();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHearts = prefs.getInt('hearts_level_${widget.levelNumber}');
    final savedHints = prefs.getInt('hints_level_${widget.levelNumber}');

    if (savedHearts != null && savedHints != null) {
      setState(() {
        _currentHearts = savedHearts;
        _remainingHints = savedHints;
      });
    }
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hearts_level_${widget.levelNumber}', _currentHearts);
    await prefs.setInt('hints_level_${widget.levelNumber}', _remainingHints);
    await prefs.setInt('completed_level', widget.levelNumber);
  }

  void _onPanStart(DragStartDetails details, Size mazeSize) {
    final cellSize = mazeSize.width / _grid[0].length;
    final localPosition = details.localPosition;

    final col = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();

    if (_isValidCell(row, col) && _grid[row][col].isStart) {
      setState(() {
        _isDrawing = true;
        _currentPath = [Offset(col.toDouble(), row.toDouble())];
        _lastValidCell = Offset(col.toDouble(), row.toDouble());
        _grid[row][col].isVisited = true;
      });

      _triggerHapticFeedback();
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size mazeSize) {
    if (!_isDrawing) return;

    final cellSize = mazeSize.width / _grid[0].length;
    final localPosition = details.localPosition;

    final col = (localPosition.dx / cellSize).floor();
    final row = (localPosition.dy / cellSize).floor();

    if (!_isValidCell(row, col)) return;

    final newCell = Offset(col.toDouble(), row.toDouble());

    // Check if moving to adjacent cell
    if (_lastValidCell != null && _isAdjacentCell(_lastValidCell!, newCell)) {
      // Validate arrow direction
      if (_isValidMove(_lastValidCell!, newCell)) {
        // Check for path collision
        if (!_hasPathCollision(newCell)) {
          setState(() {
            _currentPath.add(newCell);
            _lastValidCell = newCell;
            _grid[row][col].isVisited = true;
          });

          _triggerHapticFeedback();

          // Check if reached end
          if (_grid[row][col].isEnd) {
            _onLevelComplete();
          }
        } else {
          _onInvalidMove();
        }
      } else {
        _onInvalidMove();
      }
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
      if (_currentPath.isNotEmpty) {
        _pathHistory.add(List.from(_currentPath));
        _completedPath = List.from(_currentPath);
      }
    });
  }

  bool _isValidCell(int row, int col) {
    return row >= 0 && row < _grid.length && col >= 0 && col < _grid[0].length;
  }

  bool _isAdjacentCell(Offset from, Offset to) {
    final dx = (to.dx - from.dx).abs();
    final dy = (to.dy - from.dy).abs();
    return (dx == 1 && dy == 0) || (dx == 0 && dy == 1);
  }

  bool _isValidMove(Offset from, Offset to) {
    final fromRow = from.dy.toInt();
    final fromCol = from.dx.toInt();
    final toRow = to.dy.toInt();
    final toCol = to.dx.toInt();

    final cell = _grid[fromRow][fromCol];
    final direction = cell.arrowDirection;

    if (direction == ArrowDirection.none) return true;

    // Check if move matches arrow direction
    if (direction == ArrowDirection.up && toRow < fromRow) return true;
    if (direction == ArrowDirection.down && toRow > fromRow) return true;
    if (direction == ArrowDirection.left && toCol < fromCol) return true;
    if (direction == ArrowDirection.right && toCol > fromCol) return true;

    return false;
  }

  bool _hasPathCollision(Offset newCell) {
    return _currentPath.contains(newCell);
  }

  void _onInvalidMove() {
    _triggerErrorFeedback();
    _shakeController.forward(from: 0);

    setState(() {
      _currentHearts--;
      _isFirstTry = false;
    });

    if (_currentHearts <= 0) {
      _onGameOver();
    }
  }

  void _onLevelComplete() {
    _stopTimer();
    _saveProgress();

    // Stars are calculated later when navigating — no need to store here.

    setState(() {
      _showCelebration = true;
    });

    _triggerSuccessFeedback();
  }

  int _calculateStars() {
    int stars = 1; // Base star for completion

    // Time bonus
    if (_elapsedTime.inSeconds < 60) stars++;

    // Hint bonus
    if (_remainingHints == 3) stars++;

    // First try bonus
    if (_isFirstTry) stars = 3;

    return stars.clamp(1, 3);
  }

  void _onGameOver() {
    _stopTimer();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Game Over',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'You ran out of hearts! Try again?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/level-select-menu');
            },
            child: const Text('Level Select'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restartLevel();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _restartLevel() {
    setState(() {
      _currentPath.clear();
      _completedPath.clear();
      _pathHistory.clear();
      _lastValidCell = null;
      _isDrawing = false;
      _elapsedTime = Duration.zero;
      _currentHearts = 5;
      _remainingHints = 3;
      _isFirstTry = true;

      // Reset grid
      for (var row in _grid) {
        for (var cell in row) {
          cell.isVisited = false;
        }
      }
    });

    _startTimer();
  }

  void _undoLastMove() {
    if (_pathHistory.isEmpty) return;

    setState(() {
      _pathHistory.removeLast();
      if (_pathHistory.isNotEmpty) {
        _completedPath = List.from(_pathHistory.last);
        _currentPath = List.from(_pathHistory.last);
      } else {
        _completedPath.clear();
        _currentPath.clear();
      }

      // Reset visited cells
      for (var row in _grid) {
        for (var cell in row) {
          cell.isVisited = false;
        }
      }

      // Mark visited cells from current path
      for (var point in _currentPath) {
        _grid[point.dy.toInt()][point.dx.toInt()].isVisited = true;
      }
    });

    _triggerHapticFeedback();
  }

  void _showHint() {
    if (_remainingHints <= 0) return;

    setState(() {
      _remainingHints--;
    });

    // Show hint dialog with next 2-3 moves
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Hint',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'lightbulb',
              color: AppTheme.warningLight,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              'Follow the arrows from your current position.\nThe next moves will be highlighted briefly.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );

    _triggerHapticFeedback();
  }

  void _triggerHapticFeedback() {
    HapticFeedback.lightImpact();
  }

  void _triggerErrorFeedback() {
    HapticFeedback.heavyImpact();
  }

  void _triggerSuccessFeedback() {
    HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar.game(
        levelNumber: widget.levelNumber.toString(),
        onHintPressed: _showHint,
        onSettingsPressed: () {
          _stopTimer();
          Navigator.pushNamed(context, '/settings-screen').then((_) {
            _startTimer();
          });
        },
        onBackPressed: () {
          _stopTimer();
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top stats bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      HeartCounterWidget(
                        currentHearts: _currentHearts,
                        maxHearts: 5,
                      ),
                      TimerWidget(
                        elapsedTime: _elapsedTime,
                        isRunning: _isTimerRunning,
                      ),
                      HintCounterWidget(
                        remainingHints: _remainingHints,
                        onHintPressed: _showHint,
                      ),
                    ],
                  ),
                ),

                // Maze area
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(_shakeAnimation.value, 0),
                          child: child,
                        );
                      },
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final double sizeValue =
                              constraints.maxWidth < constraints.maxHeight
                                  ? constraints.maxWidth
                                  : constraints.maxHeight;
                          final Size size = Size(sizeValue, sizeValue);

                          return Center(
                            child: GestureDetector(
                              onPanStart: (details) =>
                                  _onPanStart(details, size),
                              onPanUpdate: (details) =>
                                  _onPanUpdate(details, size),
                              onPanEnd: _onPanEnd,
                              child: Container(
                                width: size.width,
                                height: size.height,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.surfaceDark
                                      : AppTheme.surfaceLight,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.defaultBorderRadius,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.shadowLight,
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.defaultBorderRadius,
                                  ),
                                  child: CustomPaint(
                                    painter: MazePainter(
                                      grid: _grid,
                                      currentPath: _currentPath,
                                      completedPath: _completedPath,
                                      isDark: isDark,
                                    ),
                                    size: size,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 2.h),
              ],
            ),

            // Celebration overlay
            if (_showCelebration)
              Positioned.fill(
                child: CelebrationOverlay(
                  onComplete: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/level-complete-screen',
                      arguments: {
                        'level': widget.levelNumber,
                        'stars': _calculateStars(),
                        'time': _elapsedTime.inSeconds,
                        'hints': 3 - _remainingHints,
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar.game(
        onUndoPressed: _undoLastMove,
        onHintPressed: _showHint,
        undoEnabled: _pathHistory.isNotEmpty,
      ),
    );
  }
}
