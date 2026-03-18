import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Un overlay interactivo que muestra las funcionalidades clave ("Aha! moment")
/// de la app para nuevos usuarios. Actúa como el tutorial inicial guiado.
class OnboardingWelcomeOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const OnboardingWelcomeOverlay({super.key, required this.child});

  @override
  ConsumerState<OnboardingWelcomeOverlay> createState() =>
      _OnboardingWelcomeOverlayState();
}

class _OnboardingWelcomeOverlayState
    extends ConsumerState<OnboardingWelcomeOverlay> {
  bool _isVisible = true;

  void _dismiss() {
    setState(() => _isVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return widget.child;

    return Stack(
      children: [
        // La app original debajo
        widget.child,

        // Capa oscura
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(color: Colors.black87),
          ),
        ),

        // Contenido del Onboarding
        Positioned.fill(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icon/icon.png',
                      height: 80,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.sports_soccer,
                        size: 80,
                        color: Color(0xFFF4CA25),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¡Bienvenido a SportLink Pro!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Has entrado en el ecosistema donde el talento se convierte en valor real. Aquí todo está certificado y cifrado.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Cards explicativas
                    _FeatureIntroBox(
                      icon: Icons.qr_code_2,
                      title: 'Asiste a Torneos Reales',
                      desc:
                          'Usa tu Pase QR en puerta para jugar y ganar el bote inteligente (Escrow).',
                    ),
                    const SizedBox(height: 12),
                    _FeatureIntroBox(
                      icon: Icons.shield,
                      title: 'Salud y Privacidad',
                      desc:
                          'Métricas sociales seguras. Nunca verás quién te sigue ni sentirás presión externa.',
                    ),
                    const SizedBox(height: 12),
                    _FeatureIntroBox(
                      icon: Icons.verified,
                      title: 'Certificación de Árbitros',
                      desc:
                          'Tus medias (como la técnica) provienen de evaluaciones 100% validadas por profesionales.',
                    ),

                    const SizedBox(height: 48),

                    GestureDetector(
                      onTap: _dismiss,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4CA25), // V5 Gold
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Comenzar Experiencia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeatureIntroBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureIntroBox({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFF4CA25), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
