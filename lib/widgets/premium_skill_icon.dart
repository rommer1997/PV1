import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/spotlight_models.dart';
import '../theme/cantera_premium_styles.dart';

class PremiumSkillIcon extends StatelessWidget {
  final SkillTag skill;
  final double size;

  const PremiumSkillIcon({
    super.key,
    required this.skill,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = skill.color;
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glow
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: CanteraEffects.neonGlow(color),
            ),
          ),
          // Custom Icon via Painter
          CustomPaint(
            size: Size(size, size),
            painter: _SkillPainter(skill: skill, color: color),
          ),
        ],
      ),
    );
  }
}

class _SkillPainter extends CustomPainter {
  final SkillTag skill;
  final Color color;

  _SkillPainter({required this.skill, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (skill) {
      case SkillTag.regate:
        _drawBolt(canvas, center, size);
        break;
      case SkillTag.velocidad:
        _drawSpeed(canvas, center, size);
        break;
      case SkillTag.finalizacion:
        _drawTarget(canvas, center, size);
        break;
      case SkillTag.defensa:
        _drawShield(canvas, center, size);
        break;
      case SkillTag.liderazgo:
        _drawStar(canvas, center, size);
        break;
      case SkillTag.vision:
        _drawEye(canvas, center, size);
        break;
      case SkillTag.remate:
        _drawSoccerBall(canvas, center, size);
        break;
      case SkillTag.pase:
        _drawArrows(canvas, center, size);
        break;
    }
  }

  void _drawBolt(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.6, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.55)
      ..lineTo(size.width * 0.5, size.height * 0.55)
      ..lineTo(size.width * 0.4, size.height * 0.85);
    canvas.drawPath(path, p);
  }

  void _drawSpeed(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width * 0.3), 
        3.14, 2.5, false, p);
    canvas.drawLine(center, center + const Offset(10, -10), p);
  }

  void _drawTarget(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawCircle(center, size.width * 0.35, p);
    canvas.drawCircle(center, size.width * 0.15, p);
    canvas.drawLine(center + const Offset(-15, 0), center + const Offset(15, 0), p);
    canvas.drawLine(center + const Offset(0, -15), center + const Offset(0, 15), p);
  }

  void _drawShield(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.5, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.2, size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.8, size.height * 0.8, size.width * 0.5, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.8, size.width * 0.2, size.height * 0.5)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.5, size.height * 0.2);
    canvas.drawPath(path, p);
  }

  void _drawStar(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    final path = Path();
    double degToRad(double deg) => deg * (math.pi / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth * 0.4;
    final internalRadius = externalRadius * 0.5;
    final step = degToRad(360 / numberOfPoints);
    final halfStep = step / 2;

    for (int i = 0; i < numberOfPoints; i++) {
      final x = halfWidth + math.cos(step * i - math.pi / 2) * externalRadius;
      final y = halfWidth + math.sin(step * i - math.pi / 2) * externalRadius;
      if (i == 0) path.moveTo(x, y); else path.lineTo(x, y);
      
      final xInternal = halfWidth + math.cos(step * i + halfStep - math.pi / 2) * internalRadius;
      final yInternal = halfWidth + math.sin(step * i + halfStep - math.pi / 2) * internalRadius;
      path.lineTo(xInternal, yInternal);
    }
    path.close();
    canvas.drawPath(path, p);
  }

  void _drawEye(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawArc(Rect.fromCenter(center: center, width: size.width * 0.7, height: size.height * 0.4), 
        0, 3.14, false, p);
    canvas.drawArc(Rect.fromCenter(center: center, width: size.width * 0.7, height: size.height * 0.4), 
        3.14, 3.14, false, p);
    canvas.drawCircle(center, 4, p);
  }

  void _drawSoccerBall(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.5..style = PaintingStyle.stroke;
    canvas.drawCircle(center, size.width * 0.35, p);
    // Mimic ball patterns with simple circles
    canvas.drawCircle(center, size.width * 0.1, p);
    canvas.drawCircle(center + const Offset(10, 5), 3, p);
    canvas.drawCircle(center + const Offset(-10, -5), 3, p);
  }

  void _drawArrows(Canvas canvas, Offset center, Size size) {
    final p = Paint()..color = color..strokeWidth = 2..style = PaintingStyle.stroke;
    canvas.drawLine(center + const Offset(-12, 5), center + const Offset(12, -5), p);
    // Head 1
    canvas.drawLine(center + const Offset(12, -5), center + const Offset(4, -5), p);
    canvas.drawLine(center + const Offset(12, -5), center + const Offset(12, 3), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
