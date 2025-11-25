import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

/// Custom painter for rendering maze grid with arrows and paths
class MazePainter extends CustomPainter {
  final List<List<MazeCell>> grid;
  final List<Offset> currentPath;
  final List<Offset> completedPath;
  final bool isDark;

  MazePainter({
    required this.grid,
    required this.currentPath,
    required this.completedPath,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / grid[0].length;

    // Draw grid lines
    _drawGridLines(canvas, size, cellSize);

    // Draw arrows in cells
    _drawArrows(canvas, cellSize);

    // Draw completed path
    if (completedPath.isNotEmpty) {
      _drawPath(
        canvas,
        completedPath,
        cellSize,
        AppTheme.pathCompleteDark,
        4.0,
      );
    }

    // Draw current path
    if (currentPath.isNotEmpty) {
      _drawPath(canvas, currentPath, cellSize, AppTheme.pathActiveDark, 6.0);
    }

    // Draw start and end points
    _drawStartEndPoints(canvas, cellSize);
  }

  void _drawGridLines(Canvas canvas, Size size, double cellSize) {
    final paint = Paint()
      ..color = isDark ? AppTheme.mazeLinesDark : AppTheme.mazeLinesLight
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    for (int i = 0; i <= grid[0].length; i++) {
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int i = 0; i <= grid.length; i++) {
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        paint,
      );
    }
  }

  void _drawArrows(Canvas canvas, double cellSize) {
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        final cell = grid[row][col];
        if (cell.arrowDirection != ArrowDirection.none) {
          _drawArrow(canvas, row, col, cell.arrowDirection, cellSize);
        }
      }
    }
  }

  void _drawArrow(
    Canvas canvas,
    int row,
    int col,
    ArrowDirection direction,
    double cellSize,
  ) {
    final centerX = (col + 0.5) * cellSize;
    final centerY = (row + 0.5) * cellSize;
    final arrowSize = cellSize * 0.4;

    final paint = Paint()
      ..color = isDark
          ? AppTheme.textMediumEmphasisDark
          : AppTheme.textMediumEmphasisLight
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    switch (direction) {
      case ArrowDirection.up:
        path.moveTo(centerX, centerY + arrowSize / 2);
        path.lineTo(centerX, centerY - arrowSize / 2);
        path.moveTo(centerX - arrowSize / 3, centerY - arrowSize / 6);
        path.lineTo(centerX, centerY - arrowSize / 2);
        path.lineTo(centerX + arrowSize / 3, centerY - arrowSize / 6);
        break;
      case ArrowDirection.down:
        path.moveTo(centerX, centerY - arrowSize / 2);
        path.lineTo(centerX, centerY + arrowSize / 2);
        path.moveTo(centerX - arrowSize / 3, centerY + arrowSize / 6);
        path.lineTo(centerX, centerY + arrowSize / 2);
        path.lineTo(centerX + arrowSize / 3, centerY + arrowSize / 6);
        break;
      case ArrowDirection.left:
        path.moveTo(centerX + arrowSize / 2, centerY);
        path.lineTo(centerX - arrowSize / 2, centerY);
        path.moveTo(centerX - arrowSize / 6, centerY - arrowSize / 3);
        path.lineTo(centerX - arrowSize / 2, centerY);
        path.lineTo(centerX - arrowSize / 6, centerY + arrowSize / 3);
        break;
      case ArrowDirection.right:
        path.moveTo(centerX - arrowSize / 2, centerY);
        path.lineTo(centerX + arrowSize / 2, centerY);
        path.moveTo(centerX + arrowSize / 6, centerY - arrowSize / 3);
        path.lineTo(centerX + arrowSize / 2, centerY);
        path.lineTo(centerX + arrowSize / 6, centerY + arrowSize / 3);
        break;
      case ArrowDirection.none:
        break;
    }

    canvas.drawPath(path, paint);
  }

  void _drawPath(
    Canvas canvas,
    List<Offset> path,
    double cellSize,
    Color color,
    double width,
  ) {
    if (path.length < 2) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pathToDraw = Path();

    // Convert grid coordinates to canvas coordinates
    final firstPoint = Offset(
      (path[0].dx + 0.5) * cellSize,
      (path[0].dy + 0.5) * cellSize,
    );
    pathToDraw.moveTo(firstPoint.dx, firstPoint.dy);

    for (int i = 1; i < path.length; i++) {
      final point = Offset(
        (path[i].dx + 0.5) * cellSize,
        (path[i].dy + 0.5) * cellSize,
      );
      pathToDraw.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(pathToDraw, paint);
  }

  void _drawStartEndPoints(Canvas canvas, double cellSize) {
    // Find start and end points
    Offset? startPoint;
    Offset? endPoint;

    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col].isStart) {
          startPoint = Offset(col.toDouble(), row.toDouble());
        }
        if (grid[row][col].isEnd) {
          endPoint = Offset(col.toDouble(), row.toDouble());
        }
      }
    }

    // Draw start point (green circle)
    if (startPoint != null) {
      final paint = Paint()
        ..color = AppTheme.successLight
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          (startPoint.dx + 0.5) * cellSize,
          (startPoint.dy + 0.5) * cellSize,
        ),
        cellSize * 0.25,
        paint,
      );
    }

    // Draw end point (red circle)
    if (endPoint != null) {
      final paint = Paint()
        ..color = AppTheme.errorLight
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset((endPoint.dx + 0.5) * cellSize, (endPoint.dy + 0.5) * cellSize),
        cellSize * 0.25,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MazePainter oldDelegate) {
    return oldDelegate.currentPath != currentPath ||
        oldDelegate.completedPath != completedPath ||
        oldDelegate.grid != grid;
  }
}

/// Represents a single cell in the maze grid
class MazeCell {
  final ArrowDirection arrowDirection;
  final bool isStart;
  final bool isEnd;
  bool isVisited;

  MazeCell({
    required this.arrowDirection,
    this.isStart = false,
    this.isEnd = false,
    this.isVisited = false,
  });
}

/// Arrow direction enum
enum ArrowDirection { none, up, down, left, right }
