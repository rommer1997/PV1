import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/theme_provider.dart';

class TeamRadarSection extends StatelessWidget {
  final Map<String, double> stats;
  final bool isDark;
  final String title;

  const TeamRadarSection({
    super.key,
    required this.stats,
    required this.isDark,
    this.title = 'ANÁLISIS DE EQUIPO',
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE2F163),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.radar, size: 16, color: AppColors.buttonBg(isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 180,
              width: 180,
              child: CustomPaint(
                painter: SimpleRadarPainter(stats: stats, isDark: isDark),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TeamMetric(
                label: 'Máximo',
                val: _getHighestStat(),
                color: Colors.green,
                isDark: isDark,
              ),
              _TeamMetric(
                label: 'Mínimo',
                val: _getLowestStat(),
                color: Colors.red,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getHighestStat() {
    if (stats.isEmpty) return 'N/A';
    final entry = stats.entries.reduce((a, b) => a.value > b.value ? a : b);
    return '${entry.key} (${entry.value.toStringAsFixed(1)})';
  }

  String _getLowestStat() {
    if (stats.isEmpty) return 'N/A';
    final entry = stats.entries.reduce((a, b) => a.value < b.value ? a : b);
    return '${entry.key} (${entry.value.toStringAsFixed(1)})';
  }
}

class _TeamMetric extends StatelessWidget {
  final String label, val;
  final Color color;
  final bool isDark;

  const _TeamMetric({
    required this.label,
    required this.val,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted(isDark),
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class SimpleRadarPainter extends CustomPainter {
  final Map<String, double> stats;
  final bool isDark;

  SimpleRadarPainter({required this.stats, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    if (stats.isEmpty) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final keys = stats.keys.toList();
    final points = <Offset>[];

    final paintLine = Paint()
      ..color = AppColors.border(isDark)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = const Color(0xFFE2F163).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFFE2F163)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Dibujar círculos guía
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), paintLine);
    }

    // Dibujar ejes y calcular puntos
    for (var i = 0; i < keys.length; i++) {
      final angle = (i * 2 * math.pi / keys.length) - math.pi / 2;
      final val = stats[keys[i]]! / 10.0;
      final x = center.dx + radius * val * math.cos(angle);
      final y = center.dy + radius * val * math.sin(angle);
      points.add(Offset(x, y));
      
      canvas.drawLine(
        center,
        Offset(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
        paintLine,
      );
    }

    if (points.isNotEmpty) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, paintFill);
      canvas.drawPath(path, paintStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
