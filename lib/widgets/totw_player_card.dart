import 'package:flutter/material.dart';
import '../models/app_user.dart';

// ── Carta FIFA (TOTW) Extraída ──────────────────────────────────────────────
class TOTWPlayerCard extends StatelessWidget {
  final AppUser? user;
  final Map<String, double> stats;
  final bool isDark;

  const TOTWPlayerCard({
    super.key,
    required this.user,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Calcular Overall (OVR)
    final avg = stats.values.reduce((a, b) => a + b) / stats.length;
    final ovr = (avg * 10).round();

    // Mapear stats de 0-10 a 0-99 estilo FIFA
    final pac = ((stats['VEL'] ?? 0) * 10).round();
    final sho = ((stats['FPL'] ?? 0) * 10).round();
    final pas = ((stats['TÁC'] ?? 0) * 10).round();
    final dri = ((stats['TEC'] ?? 0) * 10).round();
    final def = ((stats['RES'] ?? 0) * 10).round();
    final phy = ((stats['FUE'] ?? 0) * 10).round();

    const goldColor = Color(0xFFF4CA25); // Stitch V5 Gold
    const darkGold = Color(0xFFB8860B);

    return Container(
      width: 280,
      height: 440,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2C2C2C),
            Color(0xFF0A0A0A),
            Color(0xFF1A1A1A),
            Color(0xFF000000),
          ],
          stops: [0.0, 0.4, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: goldColor.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: goldColor.withValues(alpha: 0.9), width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Carbon Fiber Texture
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(painter: _CarbonFiberPainter()),
              ),
            ),

            // Premium Glossy Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.01),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Brillo superior
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [goldColor.withValues(alpha: 0.15), Colors.transparent],
                  ),
                ),
              ),
            ),

            // Contenido de la carta
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                children: [
                  // Parte superior: OVR, Logo, Foto
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Columna izquierda: OVR, Posición, País, Club
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '$ovr',
                              style: const TextStyle(
                                color: goldColor,
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                              ),
                            ),
                            const Text(
                              'ST',
                              style: TextStyle(
                                color: goldColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Bandera (Placeholder)
                            Container(
                              width: 26,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: darkGold, width: 0.5),
                              ),
                              child: const Center(
                                child: Text(
                                  '🇪🇸',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Escudo (Placeholder)
                            Icon(Icons.shield, color: goldColor, size: 28),
                          ],
                        ),

                        // Silueta/Foto del jugador
                        Expanded(
                          child: Container(
                            alignment: Alignment.bottomCenter,
                            child: Icon(
                              Icons.directions_run_rounded,
                              size: 140,
                              color: Colors.white.withValues(alpha: 0.9),
                              shadows: [
                                Shadow(
                                  color: goldColor.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Separador dorado
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          goldColor.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),

                  // Nombre
                  Text(
                    (user?.name ?? 'M. SILVA').toUpperCase(),
                    style: const TextStyle(
                      color: goldColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Stats (2 columnas x 3 filas)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Columna 1
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatItem(val: pac, label: 'PAC'),
                          const SizedBox(height: 6),
                          _StatItem(val: sho, label: 'SHO'),
                          const SizedBox(height: 6),
                          _StatItem(val: pas, label: 'PAS'),
                        ],
                      ),
                      const SizedBox(width: 32),
                      // Columna 2
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _StatItem(val: dri, label: 'DRI'),
                          const SizedBox(height: 6),
                          _StatItem(val: def, label: 'DEF'),
                          const SizedBox(height: 6),
                          _StatItem(val: phy, label: 'PHY'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final int val;
  final String label;

  const _StatItem({required this.val, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$val',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _CarbonFiberPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (!size.width.isFinite || !size.height.isFinite) return;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1;

    for (double i = 0; i < size.width + size.height; i += 8) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
