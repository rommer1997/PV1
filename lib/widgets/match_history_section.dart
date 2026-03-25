import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/match_evaluations_provider.dart';
import '../providers/theme_provider.dart';

class MatchHistorySection extends ConsumerWidget {
  final String playerId;
  final bool isDark;

  const MatchHistorySection({
    super.key,
    required this.playerId,
    required this.isDark,
  });

  Color _statColor(double v) {
    if (v >= 8.5) return const Color(0xFF34C759); // verde
    if (v >= 7.0) return const Color(0xFFFF9F0A); // naranja
    return const Color(0xFFFF3B30); // rojo
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEvals = ref.watch(matchEvaluationsProvider);
    final userEvals = allEvals.where((e) => e.playerId == playerId).toList();

    // Ordenar de más reciente a más antiguo
    userEvals.sort((a, b) => b.date.compareTo(a.date));

    // Tomar solo los últimos 3
    final recent = userEvals.take(3).toList();

    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }

    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HISTORIAL DE PARTIDOS',
          style: TextStyle(
            color: muted,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            children: recent.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;

              // Promedio simple para mostrar un solo número "semaforizado"
              final avg =
                  (e.tecnica + e.resistencia + e.fairPlay) /
                  ((e.tecnica > 0 ? 1 : 0) +
                          (e.resistencia > 0 ? 1 : 0) +
                          (e.fairPlay > 0 ? 1 : 0))
                      .clamp(1, 3);
              final color = _statColor(avg);

              // Identificar la fuente
              IconData sourceIcon;
              String sourceText;
              if (e.source == EvaluationSource.referee) {
                sourceIcon = Icons.sports;
                sourceText = 'Árbitro';
              } else if (e.source == EvaluationSource.coach) {
                sourceIcon = Icons.sports_kabaddi;
                sourceText = 'Entrenador';
              } else {
                sourceIcon = Icons.groups;
                sourceText = 'Comunidad';
              }

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Text(
                        avg.toStringAsFixed(1),
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Icon(sourceIcon, size: 14, color: muted),
                        const SizedBox(width: 4),
                        Text(
                          sourceText,
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Partido SLP-${e.matchId.hashCode.abs().toString().substring(0, 4)}',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),
                    trailing: Text(
                        '${e.date.day.toString().padLeft(2, '0')}/${e.date.month.toString().padLeft(2, '0')}/${e.date.year}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                  ),
                  if (i < recent.length - 1)
                    Divider(
                      color: border,
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
