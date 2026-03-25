import 'package:flutter/material.dart';
import '../theme/cantera_premium_styles.dart';

class OvrProgressionChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> history;
  final bool isDark;

  const OvrProgressionChart({
    super.key,
    required this.history,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final text = CanteraPremiumColors.text;
    final muted = CanteraPremiumColors.textMuted;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: CanteraPremiumColors.glass(color: isDark ? Colors.white : Colors.black).copyWith(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROGRESIÓN OVR',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rendimiento histórico',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '+7.5%',
                  style: TextStyle(
                    color: Color(0xFF34C759),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(
                data: history.map((e) => e.value).toList(),
                isDark: isDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: history.map((e) {
              final label = '${e.key.day}/${e.key.month}';
              return Text(
                label,
                style: TextStyle(color: muted, fontSize: 10),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> data;
  final bool isDark;

  _ChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = CanteraPremiumColors.neonCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CanteraPremiumColors.neonCyan.withOpacity(0.3),
          CanteraPremiumColors.neonCyan.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    if (size.width <= 0 || size.height <= 0) return;

    if (size.width <= 0 || size.height <= 0) return;

    final stepX = size.width / (data.length - 1);
    final minVal = data.reduce((a, b) => a < b ? a : b) - 2;
    final maxVal = data.reduce((a, b) => a > b ? a : b) + 2;
    var range = maxVal - minVal;
    if (range <= 0) range = 1.0;

    double getY(double val) => size.height - ((val - minVal) / range * size.height);

    path.moveTo(0, getY(data[0]));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, getY(data[0]));

    for (int i = 1; i < data.length; i++) {
      final x = i * stepX;
      final y = getY(data[i]);
      
      // Curva suave
      final prevX = (i - 1) * stepX;
      final prevY = getY(data[i - 1]);
      final cp1x = prevX + (x - prevX) / 2;
      path.cubicTo(cp1x, prevY, cp1x, y, x, y);
      fillPath.cubicTo(cp1x, prevY, cp1x, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Puntos
    final dotPaint = Paint()..color = CanteraPremiumColors.neonCyan;
    final bgPaint = Paint()..color = isDark ? const Color(0xFF131314) : Colors.white;
    
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = getY(data[i]);
      canvas.drawCircle(Offset(x, y), 5, dotPaint);
      canvas.drawCircle(Offset(x, y), 3, bgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
