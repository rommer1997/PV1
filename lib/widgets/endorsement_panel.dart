// ──────────────────────────────────────────────────────────────────────────────
// endorsement_panel.dart
// Panel de reconocimiento entre pares para el perfil del jugador.
// Muestra habilidades más avaladas por compañeros y votación MVP de la semana.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spotlight_models.dart';
import '../providers/theme_provider.dart';

class EndorsementPanel extends ConsumerWidget {
  final bool isOwnProfile;
  const EndorsementPanel({super.key, this.isOwnProfile = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final endorsements = ref.watch(endorsementsProvider);
    final mvpVotes = ref.watch(mvpVotesProvider);
    final notifier = ref.read(endorsementsProvider.notifier);
    final topSkills = notifier.topSkills;

    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.buttonBg(isDark).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.buttonBg(isDark).withValues(alpha: 0.3)),
                ),
                child: Text(
                  'AVALADO POR COMPAÑEROS',
                  style: TextStyle(
                    color: AppColors.buttonBg(isDark),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              // MVP votes badge
              Row(
                children: [
                  Icon(Icons.military_tech_rounded, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$mvpVotes Votos MVP esta semana',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Top skills (con recuento) ──────────────────────────────────────
          if (topSkills.isEmpty)
            Text(
              'Aún no tienes avales. ¡Pide a tus compañeros que te avalen!',
              style: TextStyle(color: muted, fontSize: 13),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: topSkills.take(5).map((entry) {
                return _SkillBadge(
                  skill: entry.key,
                  count: entry.value,
                  isDark: isDark,
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // ── Sección: Avalar habilidades (solo si perfil ajeno) ─────────────
          if (!isOwnProfile) ...[
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text(
              'Avalar habilidades',
              style: TextStyle(
                color: text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SkillTag.values.map((skill) {
                final alreadyEndorsed = (endorsements[skill] ?? [])
                    .any((e) => e.fromUserId == 'current_user');
                return _EndorseButton(
                  skill: skill,
                  alreadyDone: alreadyEndorsed,
                  isDark: isDark,
                  onTap: () {
                    if (!alreadyEndorsed) {
                      HapticFeedback.lightImpact();
                      ref.read(endorsementsProvider.notifier).addEndorsement(
                            skill,
                            'current_user',
                            'Tú',
                          );
                    }
                  },
                );
              }).toList(),
            ),
          ],

          // ── Si es el perfil propio: ver quién avaló ───────────────────────
          if (isOwnProfile && topSkills.isNotEmpty) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => _showEndorsersDetail(context, endorsements, isDark),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ver quién te avaló',
                    style: TextStyle(
                      color: AppColors.buttonBg(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.buttonBg(isDark),
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showEndorsersDetail(
    BuildContext context,
    Map<SkillTag, List<Endorsement>> endorsements,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Avales recibidos',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            ...endorsements.entries
                .where((e) => e.value.isNotEmpty)
                .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Text(
                            entry.key.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: TextStyle(
                                color: AppColors.text(isDark),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            entry.value.map((e) => e.fromUserName).join(', '),
                            style: TextStyle(
                              color: AppColors.textMuted(isDark),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
    );
  }
}

// ── Badge de habilidad con recuento ──────────────────────────────────────────
class _SkillBadge extends StatelessWidget {
  final SkillTag skill;
  final int count;
  final bool isDark;
  const _SkillBadge({required this.skill, required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.bg(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(skill.emoji, style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 5),
          Text(
            skill.label,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.buttonBg(isDark).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: AppColors.buttonBg(isDark),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Botón para avalar ─────────────────────────────────────────────────────────
class _EndorseButton extends StatelessWidget {
  final SkillTag skill;
  final bool alreadyDone;
  final bool isDark;
  final VoidCallback onTap;
  const _EndorseButton({
    required this.skill,
    required this.alreadyDone,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: alreadyDone
              ? AppColors.buttonBg(isDark).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: alreadyDone
                ? AppColors.buttonBg(isDark).withValues(alpha: 0.4)
                : AppColors.border(isDark),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(skill.emoji, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 5),
            Text(
              skill.label,
              style: TextStyle(
                color: alreadyDone
                    ? AppColors.buttonBg(isDark)
                    : AppColors.textMuted(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (alreadyDone) ...[
              const SizedBox(width: 4),
              Icon(Icons.check_rounded, size: 12, color: AppColors.buttonBg(isDark)),
            ],
          ],
        ),
      ),
    );
  }
}
