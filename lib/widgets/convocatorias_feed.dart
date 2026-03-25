// ──────────────────────────────────────────────────────────────────────────────
// convocatorias_feed.dart
// Sistema de Convocatorias y Oportunidades publicadas por scouts/entrenadores.
// Los jugadores pueden postularse directamente desde la tarjeta.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spotlight_models.dart';
import '../providers/theme_provider.dart';
import '../theme/cantera_premium_styles.dart';

// Estado de postulaciones del jugador actual
class PostulacionesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};
  void postularse(String convocatoriaId) {
    state = {...state, convocatoriaId};
  }
  bool yaPostulado(String id) => state.contains(id);
}

final postulacionesProvider = NotifierProvider<PostulacionesNotifier, Set<String>>(
  () => PostulacionesNotifier(),
);

class ConvocatoriasFeed extends ConsumerWidget {
  const ConvocatoriasFeed({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final convocatorias = ref.watch(convocatoriasProvider);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de sección
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OPORTUNIDADES',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Convocatorias Abiertas',
                  style: TextStyle(
                    color: text,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
              gradient: CanteraPremiumColors.neonGas(CanteraPremiumColors.neonCyan, opacity: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${convocatorias.length} activas',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Lista de tarjetas
        ...convocatorias.map((c) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ConvocatoriaCard(convocatoria: c, isDark: isDark),
        )),
      ],
    );
  }
}

class _ConvocatoriaCard extends ConsumerStatefulWidget {
  final Convocatoria convocatoria;
  final bool isDark;
  const _ConvocatoriaCard({required this.convocatoria, required this.isDark});

  @override
  ConsumerState<_ConvocatoriaCard> createState() => _ConvocatoriaCardState();
}

class _ConvocatoriaCardState extends ConsumerState<_ConvocatoriaCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.convocatoria;
    final isDark = widget.isDark;
    final postulaciones = ref.watch(postulacionesProvider);
    final yaPostulado = postulaciones.contains(c.id);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    final daysLeft = c.fechaLimite.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    final typeColor = c.tipo == ConvocatoriaType.reto ? Colors.purple : Colors.blue;

    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: CanteraPremiumColors.glass(
          color: yaPostulado ? Colors.green : (isDark ? Colors.white : Colors.black),
        ).copyWith(
          borderRadius: BorderRadius.circular(18),
          boxShadow: yaPostulado ? CanteraEffects.neonGlow(Colors.green.withOpacity(0.2)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tipo badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: CanteraPremiumColors.neonGas(typeColor, opacity: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    c.tipo == ConvocatoriaType.reto ? '⚡ RETO' : '📢 ABIERTA',
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Posición
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bg(isDark),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    c.posicion,
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                // Días restantes
                Row(
                  children: [
                    if (isUrgent) ...[
                      const Icon(Icons.flash_on_rounded, color: Colors.red, size: 12),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      '${daysLeft}d',
                      style: TextStyle(
                        color: isUrgent ? Colors.red : muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Organización + título
            Text(
              c.organizacion,
              style: TextStyle(
                color: AppColors.buttonBg(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              c.titulo,
              style: TextStyle(
                color: text,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),

            // Descripción expandible
            if (_expanded) ...[
              const SizedBox(height: 10),
              Text(
                c.descripcion,
                style: TextStyle(
                  color: muted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (c.requiereVideo) ...[
                    Icon(Icons.videocam_rounded, color: muted, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Requiere vídeo',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Icon(Icons.location_on_rounded, color: muted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    c.region,
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.people_rounded, color: muted, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${c.candidatos} candidatos',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 12),

            // Acción
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: yaPostulado
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            ref.read(postulacionesProvider.notifier).postularse(c.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('¡Solicitud enviada correctamente!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 40,
                      decoration: BoxDecoration(
                        color: yaPostulado
                            ? Colors.green.withValues(alpha: 0.1)
                            : AppColors.buttonBg(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: yaPostulado
                            ? Border.all(color: Colors.green.withValues(alpha: 0.4))
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        yaPostulado ? '✓ Solicitud enviada' : 'Postularme',
                        style: TextStyle(
                          color: yaPostulado ? Colors.green : AppColors.buttonFg(isDark),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.bg(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: muted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
