import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Full-screen background with radial nebula gradient and subtle grid overlay.
///
/// Wrap every screen's `Scaffold.body` with this widget for the Cyanide Pulse
/// deep-space aesthetic.
class NebulaBackground extends StatelessWidget {
  const NebulaBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Radial nebula gradient
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppColors.surfaceContainer, // #161a21 center
                  AppColors.background, // #0b0e14 edges
                ],
              ),
            ),
            child: SizedBox.expand(),
          ),
        ),
        // 40px grid overlay
        Positioned.fill(
          child: Opacity(
            opacity: 0.4,
            child: CustomPaint(
              painter: _GridPainter(
                lineColor: AppColors.gridLine,
                gridSize: 40,
              ),
            ),
          ),
        ),
        // Actual content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.lineColor, required this.gridSize});

  final Color lineColor;
  final double gridSize;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    // Vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.gridSize != gridSize;
}
