import 'package:flutter/material.dart';
import 'package:aquaponic/core/constants/app_colors.dart';

enum BarType { suhu, pH }

class ColoredBarIndicator extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final BarType barType;
  final double barHeight;

  const ColoredBarIndicator({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.barType,
    this.barHeight = 8,
  });

  List<Color> get _gradientColors {
    switch (barType) {
      case BarType.suhu:
        return const [
          Color(0xFFF44336), Color(0xFFFF9800), Color(0xFFFFEB3B), Color(0xFF4CAF50),
          Color(0xFF4CAF50), Color(0xFFFFEB3B), Color(0xFFFF9800), Color(0xFFF44336),
        ];
      case BarType.pH:
        return const [
          Color(0xFFF44336), Color(0xFFFF9800), Color(0xFFFFEB3B), Color(0xFF4CAF50),
          Color(0xFF4CAF50), Color(0xFF29B6F6), Color(0xFF7C4DFF),
        ];
    }
  }

  List<double> get _gradientStops {
    switch (barType) {
      case BarType.suhu:
        return const [0.0, 0.12, 0.22, 0.35, 0.65, 0.78, 0.88, 1.0];
      case BarType.pH:
        return const [0.0, 0.15, 0.30, 0.42, 0.58, 0.78, 1.0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(minValue, maxValue);
    final fraction = (clampedValue - minValue) / (maxValue - minValue);

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final markerPosition = fraction * barWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 8,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: markerPosition - 5,
                    top: 0,
                    child: CustomPaint(
                      size: const Size(10, 8),
                      painter: _TrianglePainter(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Container(
              width: double.infinity,
              height: barHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(barHeight / 2),
                gradient: LinearGradient(colors: _gradientColors, stops: _gradientStops),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) => color != oldDelegate.color;
}
