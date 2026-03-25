import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../providers/theme_provider.dart';
import '../providers/match_evaluations_provider.dart';
import '../widgets/ovr_progression_chart.dart';
import '../widgets/offers_section.dart';
import '../widgets/achievements_carousel.dart';
import '../widgets/tutor_section.dart';
import '../widgets/team_radar_chart.dart';
import '../widgets/help_button.dart';
import '../models/user_role.dart';
import 'shared/profile_edit_screen.dart';
import 'shared/settings_screen.dart';
import '../widgets/match_history_section.dart';
import '../widgets/profile_hero_clean.dart';
import '../widgets/endorsement_panel.dart';
import '../providers/players_provider.dart';

// ── Provider de Estado Local para CV Atlético (Optimizada v3) ────────────────
final athleticCVProvider = Provider.autoDispose
    .family<
      ({
        Map<String, double> global,
        Map<String, double> referee,
        Map<String, double> coach,
        Map<String, double> community,
      }),
      String
    >((ref, playerId) {
      final allEvals = ref
          .watch(matchEvaluationsProvider)
          .where((e) => e.playerId == playerId)
          .toList();

      final refs = allEvals.where((e) => e.source == EvaluationSource.referee).toList();
      final coaches = allEvals.where((e) => e.source == EvaluationSource.coach).toList();
      final comms = allEvals.where((e) => e.source == EvaluationSource.community).toList();

      final refStats = _calcSourceAvg(refs);
      final coachStats = _calcSourceAvg(coaches);
      final commStats = _calcSourceAvg(comms);

      final global = {
        'TEC': (refStats['TEC'] ?? 0) * 0.6 + (coachStats['TEC'] ?? 0) * 0.2 + (commStats['TEC'] ?? 0) * 0.2,
        'VEL': 7.5,
        'RES': (refStats['RES'] ?? 0) * 0.6 + (coachStats['RES'] ?? 0) * 0.2 + (commStats['RES'] ?? 0) * 0.2,
        'FUE': 8.0,
        'TÁC': 7.8,
        'FPL': (refStats['FPL'] ?? 0) * 0.6 + (coachStats['FPL'] ?? 0) * 0.2 + (commStats['FPL'] ?? 0) * 0.2,
      };

      return (
        global: global,
        referee: refStats,
        coach: coachStats,
        community: commStats,
      );
    });

Map<String, double> _calcSourceAvg(List<MatchEvaluation> evals) {
  if (evals.isEmpty) return {};
  final n = evals.length;
  double totalWeight = 0, sumTec = 0, sumRes = 0, sumFP = 0;

  for (int i = 0; i < n; i++) {
    final weight = (n - i).toDouble();
    totalWeight += weight;
    sumTec += evals[i].tecnica * weight;
    sumRes += evals[i].resistencia * weight;
    sumFP += evals[i].fairPlay * weight;
  }
  return {
    'TEC': sumTec / totalWeight,
    'RES': sumRes / totalWeight,
    'FPL': sumFP / totalWeight,
  };
}

class FishCardScreen extends ConsumerWidget {
  final String? playerId;
  final AppUser? viewedUser;

  const FishCardScreen({super.key, this.playerId, this.viewedUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isLocked = ref.watch(safetyLockProvider);
    final rawUser = ref.watch(sessionProvider);

    final resolvedUser = viewedUser ?? (playerId != null 
        ? ref.watch(playersProvider).where((p) => p.user.id == playerId).firstOrNull?.user 
        : null) ?? rawUser?.sanitize(isAuthorized: !isLocked);
        
    final user = resolvedUser;
    final isCurrentUser = (user?.id == rawUser?.id);
    final targetPlayerId = user?.id ?? '1';

    final state = ref.watch(athleticCVProvider(targetPlayerId));
    final stats = state.global;

    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.refresh(athleticCVProvider(targetPlayerId)),
          color: text,
          backgroundColor: surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, ref, user, isCurrentUser, isLocked, isDark, text, muted, surface, border),
                const SizedBox(height: 24),
                ProfileHeroClean(user: user, stats: stats, isDark: isDark),
                const SizedBox(height: 32),
                if (user?.bio != null) _buildBio(user!.bio!, text, muted, surface, border),
                const EndorsementPanel(isOwnProfile: true),
                const SizedBox(height: 32),
                TeamRadarSection(stats: stats, isDark: isDark, title: 'RADIOGRAFÍA TÁCTICA'),
                const SizedBox(height: 48),
                AchievementsCarousel(badges: user?.achievements ?? [], isDark: isDark),
                const SizedBox(height: 48),
                OvrProgressionChart(
                  history: ref.watch(playerOvrHistoryProvider(targetPlayerId)),
                  isDark: isDark,
                ),
                const SizedBox(height: 48),
                MatchHistorySection(playerId: targetPlayerId, isDark: isDark),
                const SizedBox(height: 48),
                if (rawUser?.role == UserRole.tutor) TutorSection(user: user!, isDark: isDark),
                if (isCurrentUser) OffersSection(playerId: targetPlayerId, isDark: isDark),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppUser? user, bool isCurrentUser, bool isLocked, bool isDark, Color text, Color muted, Color surface, Color border) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isCurrentUser)
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
            onPressed: () => Navigator.pop(context),
          )
        else
          Text('ATHLETIC-CV', style: TextStyle(color: muted, fontSize: 11, letterSpacing: 3, fontWeight: FontWeight.bold)),
        Row(
          children: [
            const HelpButton(screenKey: 'athletic_cv'),
            const SizedBox(width: 8),
            if (isCurrentUser) ...[
              IconButton(icon: Icon(Icons.settings_outlined, color: muted, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),
              IconButton(icon: Icon(Icons.edit_outlined, color: muted, size: 22), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileEditScreen()))),
            ],
            GestureDetector(
              onTap: () => ref.read(safetyLockProvider.notifier).toggle(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isLocked ? Colors.red.withValues(alpha: 0.1) : surface, shape: BoxShape.circle, border: Border.all(color: isLocked ? Colors.red : border)),
                child: Icon(isLocked ? Icons.security : Icons.security_outlined, size: 16, color: isLocked ? Colors.red : muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBio(String bio, Color text, Color muted, Color surface, Color border) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(24), border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.format_quote_rounded, color: Color(0xFFE2F163), size: 20),
              const SizedBox(width: 8),
              Text('CARTA DE PRESENTACIÓN', style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 16),
          Text(bio, style: TextStyle(color: text, fontSize: 14, height: 1.6, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
