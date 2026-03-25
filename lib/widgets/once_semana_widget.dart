// ──────────────────────────────────────────────────────────────────────────────
// once_semana_widget.dart
// Carrusel semanal de los 11 jugadores destacados en SportLink Pro.
// Calculado a partir de rating + avales + votos MVP de la semana.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spotlight_models.dart';
import '../providers/theme_provider.dart';

class OnceSemanaWidget extends ConsumerWidget {
  const OnceSemanaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final once = ref.watch(onceSemanProvider);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEMANA 13',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    letterSpacing: 2.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      'Once de la Semana',
                      style: TextStyle(
                        color: text,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          'Calculado con rating, avales y votos MVP de tus compañeros',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 14),

        // ── Carrusel horizontal ─────────────────────────────────────────────
        SizedBox(
          height: 164,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            itemCount: once.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final player = once[i];
              final isCurrentUser = player.playerId == 'SLP-0982';
              return _OnceSemanaCard(
                entry: player,
                rank: i + 1,
                isDark: isDark,
                isCurrentUser: isCurrentUser,
                surface: surface,
                muted: muted,
                text: text,
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // ── Info sobre cálculo ───────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: muted, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'El ranking se actualiza cada lunes a las 00:00. Participa en partidos y consigue avales de compañeros para aparecer.',
                  style: TextStyle(color: muted, fontSize: 11, height: 1.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OnceSemanaCard extends StatelessWidget {
  final OnceSemanEntry entry;
  final int rank;
  final bool isDark;
  final bool isCurrentUser;
  final Color surface;
  final Color muted;
  final Color text;

  const _OnceSemanaCard({
    required this.entry,
    required this.rank,
    required this.isDark,
    required this.isCurrentUser,
    required this.surface,
    required this.muted,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final highlightColor = isCurrentUser
        ? AppColors.buttonBg(isDark)
        : (rank == 1 ? Colors.amber : null);

    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.buttonBg(isDark).withValues(alpha: 0.08)
            : surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlightColor?.withValues(alpha: 0.4) ??
              AppColors.border(isDark),
          width: isCurrentUser ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank + nombre
          Row(
            children: [
              Text(
                '#$rank',
                style: TextStyle(
                  color: highlightColor ?? muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (isCurrentUser) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.buttonBg(isDark).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'TÚ',
                    style: TextStyle(
                      color: AppColors.buttonBg(isDark),
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 8),

          // Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bg(isDark),
              border: Border.all(
                color: highlightColor?.withValues(alpha: 0.5) ??
                    AppColors.border(isDark),
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              color: highlightColor ?? muted,
              size: 20,
            ),
          ),

          const SizedBox(height: 8),

          // Nombre del jugador
          Text(
            entry.playerName.split(' ').first,
            style: TextStyle(
              color: text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            entry.posicion,
            style: TextStyle(color: muted, fontSize: 10),
          ),

          const Spacer(),

          // Rating + endorsements
          Row(
            children: [
              Text(
                entry.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: highlightColor ?? text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '${entry.totalEndorsements}⭐',
                style: TextStyle(color: muted, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
