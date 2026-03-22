import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

/// Un overlay interactivo premium que muestra funcionalidades clave
/// de la app para nuevos usuarios. Actúa como el tutorial inicial guiado.
class OnboardingWelcomeOverlay extends ConsumerStatefulWidget {
  final Widget child;

  const OnboardingWelcomeOverlay({super.key, required this.child});

  @override
  ConsumerState<OnboardingWelcomeOverlay> createState() =>
      _OnboardingWelcomeOverlayState();
}

class _OnboardingWelcomeOverlayState
    extends ConsumerState<OnboardingWelcomeOverlay>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Desatar animación al construir
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (mounted) {
      setState(() => _isVisible = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return widget.child;

    return Stack(
      children: [
        // App original debajo
        widget.child,

        // Fondo difuminado (Glassmorphism intenso)
        Positioned.fill(
          child: GestureDetector(
            onTap: _dismiss,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.6),
                        const Color(0xFF0F0F0F).withValues(alpha: 0.85),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Contenido Animado Frontal
        Positioned.fill(
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Icono Glow
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE2F163).withValues(alpha: 0.15),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                            border: Border.all(
                              color: const Color(0xFFE2F163).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.sports_soccer,
                            size: 64,
                            color: Color(0xFFE2F163), // Verde-Lima Neón/Amarillo
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '¡Bienvenido a SportLink!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                            height: 1.1,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Has entrado en la red donde el talento se convierte en valor real y certificado. Prepárate para el siguiente nivel.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            decoration: TextDecoration.none,
                          ),
                        ),
                        const SizedBox(height: 48),

                        // Features Glassmorphic
                        _FeatureCard(
                          icon: Icons.qr_code_scanner_rounded,
                          title: 'Asiste a Torneos Reales',
                          desc: 'Usa tu Pase QR VIP en puerta para jugar y optar al premio (Escrow).',
                        ),
                        const SizedBox(height: 16),
                        _FeatureCard(
                          icon: Icons.gpp_good_rounded,
                          title: 'Privacidad y Paz Mental',
                          desc: 'Activa el Modo Crisis si hay presión extra. Juega enfocado y sano.',
                        ),
                        const SizedBox(height: 16),
                        _FeatureCard(
                          icon: Icons.fact_check_rounded,
                          title: 'Árbitros Incorruptibles',
                          desc: 'Tus notas OVR provienen de jueces ciegos 100% verificados.',
                        ),
                        
                        const SizedBox(height: 56),

                        // Botón de Acción Principal (Glow Button)
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F163),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFE2F163).withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Entrar al Campo',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.2,
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
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04), // Glass effect
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F163).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFE2F163), size: 24),
          ),
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
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                    height: 1.4,
                    fontWeight: FontWeight.w400,
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
