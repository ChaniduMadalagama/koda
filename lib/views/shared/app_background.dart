// filepath: /Users/developer/Desktop/flutter/koda/lib/views/shared/app_background.dart
import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget child;
  final String backgroundImagePath;

  const AppBackground({
    super.key,
    required this.child,
    this.backgroundImagePath = 'assets/images/background.png',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Configured Background Image Layer
        Positioned.fill(
          child: Image.asset(
            backgroundImagePath,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to solid color if there is an loading issue
              return Container(
                color: const Color(0xFFFEF8FC),
              );
            },
          ),
        ),
        // 2. Custom Painter for soft radial gradients & vector aesthetics
        Positioned.fill(
          child: CustomPaint(
            painter: _BackgroundPainter(),
          ),
        ),
        // 3. Screen content
        Positioned.fill(
          child: child,
        ),
      ],
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // --- Paint Layer 1: Sun-Drenched Radial Glows ---
    final glowPaint = Paint()..style = PaintingStyle.fill;

    // 1. Warm Yellow Glow (Top-Right representing Morning Sun)
    final yellowGlowRect = Rect.fromCircle(
      center: Offset(width * 0.95, height * 0.05),
      radius: width * 0.95,
    );
    glowPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFFFB82B).withOpacity(0.12),
        const Color(0xFFFFB82B).withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    ).createShader(yellowGlowRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), glowPaint);

    // 2. Gentle Purple Glow (Bottom-Left representing Evening Rest)
    final purpleGlowRect = Rect.fromCircle(
      center: Offset(width * 0.05, height * 0.95),
      radius: width * 1.1,
    );
    glowPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFC8C0E5).withOpacity(0.14),
        const Color(0xFFC8C0E5).withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    ).createShader(purpleGlowRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), glowPaint);

    // 3. Soft Pink/Coral Glow (Middle-Right representing Warmth)
    final pinkGlowRect = Rect.fromCircle(
      center: Offset(width * 0.9, height * 0.5),
      radius: width * 0.85,
    );
    glowPaint.shader = RadialGradient(
      colors: [
        const Color(0xFFF9D8DB).withOpacity(0.11),
        const Color(0xFFF9D8DB).withOpacity(0.0),
      ],
      stops: const [0.0, 1.0],
    ).createShader(pinkGlowRect);
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), glowPaint);

    // --- Paint Layer 2: Tactile Modernism Vector Lines & Dots ---
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFF837561).withOpacity(0.08); // Outlines

    // Top-Right Organic Swoosh
    final path1 = Path();
    path1.moveTo(width * 0.65, 0);
    path1.quadraticBezierTo(
      width * 0.8,
      height * 0.1,
      width,
      height * 0.15,
    );
    canvas.drawPath(path1, strokePaint);

    // Bottom-Left Organic Swoosh
    final path2 = Path();
    path2.moveTo(0, height * 0.82);
    path2.quadraticBezierTo(
      width * 0.22,
      height * 0.86,
      width * 0.38,
      height,
    );
    canvas.drawPath(path2, strokePaint);

    // Small Memphis alignment dot grid (top left area)
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF837561).withOpacity(0.05);

    const int cols = 4;
    const int rows = 5;
    const double spacing = 16.0;
    const double startX = 28.0;
    const double startY = 120.0;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(startX + (c * spacing), startY + (r * spacing)),
          1.5,
          dotPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
