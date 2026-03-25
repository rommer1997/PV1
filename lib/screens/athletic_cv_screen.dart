import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;
import '../models/app_user.dart';
import '../providers/theme_provider.dart';
import '../providers/match_evaluations_provider.dart';
import '../widgets/help_button.dart';
import '../models/user_role.dart';
import 'shared/profile_edit_screen.dart';
import 'shared/settings_screen.dart';
import '../widgets/video_highlight_card.dart';
import '../widgets/totw_player_card.dart';
import '../widgets/endorsement_panel.dart';
import '../providers/players_provider.dart';

// ── Paleta semáforo por rendimiento ──────────────────────────────────────────
Color _statColor(double v) {
  if (v >= 8.5) return const Color(0xFF34C759); // verde
  if (v >= 7.0) return const Color(0xFFFF9F0A); // naranja
  return const Color(0xFFFF3B30); // rojo
}

// ── Stats del jugador ─────────────────────────────────────────────────────────
// TEC, RES, FPL vienen del promedio ponderado de evaluaciones del árbitro.
// VEL, FUE, TÁC son evaluaciones privadas del entrenador (pendiente integración).

// ── Widget Perfil Hero (Minimalista) ──────────────────────────────────────────────
class _ProfileHeroClean extends ConsumerWidget {
  final AppUser? user;
  final Map<String, double> stats;
  final bool isDark;

  const _ProfileHeroClean({
    required this.user,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calcular Overall (OVR)
    final avg = stats.values.reduce((a, b) => a + b) / stats.length;
    final ovr = (avg * 10).round();

    final pac = ((stats['VEL'] ?? 0) * 10).round();
    final sho = ((stats['FPL'] ?? 0) * 10).round();
    final pas = ((stats['TÁC'] ?? 0) * 10).round();
    final dri = ((stats['TEC'] ?? 0) * 10).round();
    final def = ((stats['RES'] ?? 0) * 10).round();
    final phy = ((stats['FUE'] ?? 0) * 10).round();

    final bg = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: Colors.transparent,
                      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Center(
                        child: TOTWPlayerCard(
                          user: user,
                          stats: stats,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$ovr',
                        style: TextStyle(
                          color: text,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'OVR',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileEditScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                        border: Border.all(color: border, width: 2),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 50,
                        color: muted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => _showQRCode(context, user?.uniqueId ?? 'SLP-UNK'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.bg(isDark), width: 2),
                        ),
                        child: const Icon(Icons.qr_code_2, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            (user?.name ?? 'M. SILVA').toUpperCase(),
            style: TextStyle(
              color: text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showPositionPicker(context, ref),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4CA25).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${user?.position ?? 'ST'} • 🇪🇸',
                style: const TextStyle(
                  color: Color(0xFFF4CA25),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _HeroStat(label: 'PAC', value: pac, isDark: isDark),
              _HeroStat(label: 'SHO', value: sho, isDark: isDark),
              _HeroStat(label: 'PAS', value: pas, isDark: isDark),
              _HeroStat(label: 'DRI', value: dri, isDark: isDark),
              _HeroStat(label: 'DEF', value: def, isDark: isDark),
              _HeroStat(label: 'PHY', value: phy, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context, String uid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'TU CREDENCIAL SLP',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: 'https://sportlink.pro/cv/$uid',
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: Colors.black,
            ),
            const SizedBox(height: 16),
            Text(uid, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text(
              'Escanea para ver el CV dinámico',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  void _showPositionPicker(BuildContext context, WidgetRef ref) {
    final positions = ['POR', 'DF', 'MC', 'DEL', 'EXT', 'MCO'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            const Text('SELECCIONA TU POSICIÓN', style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: positions.map((p) => ChoiceChip(
                label: Text(p),
                selected: user?.position == p,
                onSelected: (_) {
                  // En un caso real aquí llamaríamos a un método en el provider
                  Navigator.pop(context);
                },
              )).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label;
  final int value;
  final bool isDark;

  const _HeroStat({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            color: text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: muted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

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

      final refs = allEvals
          .where((e) => e.source == EvaluationSource.referee)
          .toList();
      final coaches = allEvals
          .where((e) => e.source == EvaluationSource.coach)
          .toList();
      final comms = allEvals
          .where((e) => e.source == EvaluationSource.community)
          .toList();

      final refStats = _calcSourceAvg(refs);
      final coachStats = _calcSourceAvg(coaches);
      final commStats = _calcSourceAvg(comms);

      final global = {
        'TEC':
            (refStats['TEC'] ?? 0) * 0.6 +
            (coachStats['TEC'] ?? 0) * 0.2 +
            (commStats['TEC'] ?? 0) * 0.2,
        'VEL':
            (refStats['VEL'] ?? 0) * 0.6 +
            (coachStats['VEL'] ?? 0) * 0.2 +
            (commStats['VEL'] ?? 0) * 0.2,
        'RES':
            (refStats['RES'] ?? 0) * 0.6 +
            (coachStats['RES'] ?? 0) * 0.2 +
            (commStats['RES'] ?? 0) * 0.2,
        'FUE':
            (refStats['FUE'] ?? 0) * 0.6 +
            (coachStats['FUE'] ?? 0) * 0.2 +
            (commStats['FUE'] ?? 0) * 0.2,
        'TÁC':
            (refStats['TÁC'] ?? 0) * 0.6 +
            (coachStats['TÁC'] ?? 0) * 0.2 +
            (commStats['TÁC'] ?? 0) * 0.2,
        'FPL':
            (refStats['FPL'] ?? 0) * 0.6 +
            (coachStats['FPL'] ?? 0) * 0.2 +
            (commStats['FPL'] ?? 0) * 0.2,
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
  double totalWeight = 0;
  double sumTec = 0, sumRes = 0, sumFP = 0;

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
    // VEL, FUE, TÁC se asumen tmb en 0 si no hay evals específicas
  };
}

// ── Pantalla principal ────────────────────────────────────────────────────────
class AthleticCVScreen extends ConsumerWidget {
  final AppUser? viewedUser;
  const AthleticCVScreen({super.key, this.viewedUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final isLocked = ref.watch(safetyLockProvider);
    final rawUser = ref.watch(sessionProvider);

    // Aplicamos sanitización
    final user = viewedUser ?? rawUser?.sanitize(isAuthorized: !isLocked);
    final isCurrentUser = viewedUser == null || viewedUser!.id == rawUser?.id;

    final targetPlayerId = user?.uniqueId ?? 'SLP-XXXX';
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
          onRefresh: () async =>
              ref.refresh(athleticCVProvider(targetPlayerId)),
          color: text,
          backgroundColor: surface,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header animado ─────────────────────────────────────────
                if (isCurrentUser)
                  _FadeSlide(
                    delay: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ATHLETIC-CV',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  const HelpButton(screenKey: 'athletic_cv'),
                            const SizedBox(width: 8),
                            // Botón QR
                            GestureDetector(
                              onTap: () => _showQRPass(context, user, isDark),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: border),
                                ),
                                child: Icon(Icons.qr_code_2, size: 16, color: muted),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Crisis Toggle (Simulación)
                            GestureDetector(
                              onTap: () => ref
                                  .read(safetyLockProvider.notifier)
                                  .toggle(),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isLocked
                                      ? Colors.red.withValues(alpha: 0.1)
                                      : surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isLocked ? Colors.red : border,
                                  ),
                                ),
                                child: Icon(
                                  isLocked
                                      ? Icons.security
                                      : Icons.security_outlined,
                                  size: 14,
                                  color: isLocked ? Colors.red : text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ProfileEditScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 14, color: text),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Editar',
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(Icons.share, color: bg, size: 20),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Generando imagen para Instagram...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppColors.buttonBg(isDark),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.ios_share,
                                      size: 14,
                                      color: text,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Compartir',
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: surface,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: border),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings_outlined,
                                      size: 14,
                                      color: text,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Ajustes',
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (user?.isVerified ?? false)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFFD700,
                                    ).withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withValues(alpha: 0.07),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 13,
                                      color: Color(0xFFFFD700),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'Verificado',
                                      style: TextStyle(
                                        color: Color(0xFFFFD700),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'Perfil del Jugador',
                          style: TextStyle(
                            color: text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (isCurrentUser) const SizedBox(height: 24),

                // ── Social Metrics & Follow Button (Phase 1) ───────────────
                _FadeSlide(
                  delay: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Followers block
                      Column(
                        children: [
                          Text(
                            '${user?.followersCount ?? 0}',
                            style: TextStyle(
                              color: text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Seguidores',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // Divider
                      Container(
                        height: 30,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        color: border,
                      ),

                      // Following block
                      Column(
                        children: [
                          Text(
                            '${user?.followingCount ?? 0}',
                            style: TextStyle(
                              color: text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Siguiendo',
                            style: TextStyle(
                              color: muted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(width: 32),

                      // Follow Button (Mock interaction)
                      if (!isCurrentUser)
                        GestureDetector(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Has empezado a seguir a ${user?.name}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                backgroundColor: const Color(0xFF007AFF),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF007AFF,
                              ), // Blue follow button
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Seguir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Scout Interest Metric ──
                _FadeSlide(
                  delay: 90,
                  child: Center(
                    child: Consumer(
                      builder: (ctx, ref, _) {
                        final players = ref.watch(playersProvider);
                        final pData = players.where((p) => p.user.id == user?.id || p.user.uniqueId == user?.uniqueId).firstOrNull;
                        final count = pData?.scoutWatchlistIds.length ?? 0;
                        
                        if (count == 0) return const SizedBox.shrink();
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4CA25).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF4CA25).withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, color: Color(0xFFF4CA25), size: 14),
                              const SizedBox(width: 8),
                              Text(
                                '$count scouts siguiendo tu progreso',
                                style: const TextStyle(
                                  color: Color(0xFFF4CA25),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Presentación del Jugador (Bio) ─────────────────────────
                if (user?.bio != null)
                  _FadeSlide(
                    delay: 100,
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.format_quote_rounded, color: const Color(0xFFE2F163), size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'CARTA DE PRESENTACIÓN',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user!.bio!,
                            style: TextStyle(
                              color: text,
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Reconocimiento entre Compañeros ────────────────────
                _FadeSlide(
                  delay: 120,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: EndorsementPanel(isOwnProfile: isCurrentUser),
                  ),
                ),

                _FadeSlide(
                  delay: 160,
                  child: Center(
                    child: _ProfileHeroClean(
                      user: viewedUser,
                      stats: stats,
                      isDark: isDark,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Métrica de Interés (Engagement) ──
                _FadeSlide(
                  delay: 180,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final players = ref.watch(playersProvider);
                      final pData = players.where((p) => p.user.id == targetPlayerId).firstOrNull;
                      return _InterestMetricCard(
                        count: pData?.scoutWatchlistIds.length ?? 0,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 48),

                // ── Radar Chart ────────────────────────────────────────────
                _FadeSlide(
                  delay: 240,
                  child: Center(
                    child: _AnimatedRadarChart(scores: stats, isDark: isDark),
                  ),
                ),
                const SizedBox(height: 48),

                // 🚀 SECCIÓN TUTOR: Solo visible para el tutor legal
                if (rawUser?.role == UserRole.tutor) ...[
                  _FadeSlide(
                    delay: 250,
                    child: _TutorSection(
                      user: user!,
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      muted: muted,
                      text: text,
                    ),
                  ),
                  const SizedBox(height: 48),
                ],

                // ── Insignias / Logros ─────────────────────────────────────
                _FadeSlide(
                  delay: 260,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Text(
                          'LOGROS E INSIGNIAS',
                          style: TextStyle(
                            color: muted,
                            fontSize: 10,
                            letterSpacing: 2.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _buildBadgeCard('Top 10% Vel.', Icons.bolt, const Color(0xFFFF9F0A), isDark),
                            _buildBadgeCard('Talento SLP', Icons.verified_user, const Color(0xFF34C759), isDark),
                            _buildBadgeCard('Scout Fav', Icons.star, const Color(0xFFF4CA25), isDark),
                            _buildBadgeCard('Líder', Icons.local_fire_department, Colors.redAccent, isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Label stats ────────────────────────────────────────────
                _FadeSlide(
                  delay: 240,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'HABILIDADES CERTIFICADAS',
                        style: TextStyle(
                          color: muted,
                          fontSize: 10,
                          letterSpacing: 2.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.lock_outline, size: 10, color: muted),
                          const SizedBox(width: 4),
                          Text(
                            'Solo lectura',
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Lista limpia de stats (sin barras, solo número con color) ─
                Column(
                  children: stats.entries.toList().asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    return _FadeSlide(
                      delay: 300 + i * 55,
                      child: _StatRow(
                        label: e.key,
                        value: e.value,
                        isDark: isDark,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 36),

                // ── Carrusel de Logros ──
                _FadeSlide(
                  delay: 500,
                  child: _AchievementsCarousel(
                    badges: viewedUser?.achievements ?? [],
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Info certificación ─────────────────────────────────────
                _FadeSlide(
                  delay: 640,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FUENTES DE VALIDACIÓN',
                          style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _WeightRow(
                          label: 'Árbitro',
                          sublabel:
                              'Evaluación clínica · Hasta 3 nominados/partido',
                          pct: 60,
                          score: _avg(state.referee),
                          color: const Color(0xFF007AFF),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _WeightRow(
                          label: 'Entrenador',
                          sublabel:
                              'Evaluación privada · Partidos y entrenamientos',
                          pct: 20,
                          score: _avg(state.coach),
                          color: const Color(0xFFFF9F0A),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        _WeightRow(
                          label: 'Comunidad',
                          sublabel:
                              'Certificación pública · Online y presencial',
                          pct: 20,
                          score: _avg(state.community),
                          color: const Color(0xFF34C759),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // ── Gráfico de Progresión ──
                _FadeSlide(
                  delay: 680,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final history = ref.watch(playerOvrHistoryProvider(targetPlayerId));
                      return _OvrProgressionChart(
                        history: history,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 36),

                // ── Historial de Partidos ──────────────────────────────────
                _FadeSlide(
                  delay: 720,
                  child: _MatchHistorySection(
                    playerId: targetPlayerId,
                    isDark: isDark,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Vídeos y Highlights (VOD) ──────────────────────────────
                if (rawUser?.role == UserRole.coach || rawUser?.role == UserRole.staff) ...[
                  _FadeSlide(
                    delay: 800,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECURSO PARA EVALUADORES (SLP VEO)',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        VideoHighlightCard(
                          title: 'Actuación Estelar vs. Academia F.C.',
                          description: 'Resumen táctico generado por cámaras IA para la evaluación de Stats del jugador.',
                          matchDate: '15/03/2026',
                          isDark: isDark,
                          canAdjustStats: true, 
                          canBroadcast: false,
                          onAdjustStats: () => _showAdjustStatsModal(context, viewedUser, isDark),
                          onShareToFeed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],

                // ── Nueva Sección: Ofertas y Contratos (Loop Scout -> Player) ──
                if (isCurrentUser)
                  _FadeSlide(
                    delay: 900,
                    child: _OffersSection(playerId: targetPlayerId, isDark: isDark),
                  ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadgeCard(String title, IconData icon, Color color, bool isDark) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: -2,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget de animación de entrada: fade + deslizamiento hacia arriba ─────────
class _FadeSlide extends StatefulWidget {
  final Widget child;
  final int delay; // ms
  const _FadeSlide({required this.child, required this.delay});
  @override
  State<_FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<_FadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _opacity = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    
    // Reduce delays dramatically for snappier navigation
    final optimizedDelay = widget.delay ~/ 4;
    Future.delayed(Duration(milliseconds: optimizedDelay), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Skeleton mientras carga ───────────────────────────────────────────────────
class _SkeletonRadar extends StatefulWidget {
  const _SkeletonRadar();
  @override
  State<_SkeletonRadar> createState() => _SkeletonRadarState();
}

class _SkeletonRadarState extends State<_SkeletonRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(
            isDark ? const Color(0xFF111111) : const Color(0xFFF5F5F7),
            isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE8E8EA),
            _c.value,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: const Color(0xFF007AFF).withValues(alpha: 0.5),
              strokeWidth: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

// _SkeletonStatsList removed as it is no longer used in the V5 design.

// ── Fila de stat — número + color semáforo, SIN barra ────────────────────────
class _StatRow extends StatefulWidget {
  final String label;
  final double value;
  final bool isDark;
  const _StatRow({
    required this.label,
    required this.value,
    required this.isDark,
  });
  @override
  State<_StatRow> createState() => _StatRowState();
}

class _StatRowState extends State<_StatRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _num;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _num = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(widget.isDark);
    final border = AppColors.border(widget.isDark);
    final vc = _statColor(widget.value);

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Etiqueta + indicador de candado
          Row(
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(color: vc, shape: BoxShape.circle),
              ),
              Text(
                widget.label,
                style: TextStyle(
                  color: muted,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.lock_outline, size: 9, color: muted.withValues(alpha: 0.5)),
            ],
          ),

          // Número contado animado con color semáforo
          AnimatedBuilder(
            animation: _num,
            builder: (_, _) {
              final displayed = widget.value * _num.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    displayed.toStringAsFixed(1),
                    style: TextStyle(
                      color: vc,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    ' /10',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Barra de peso de validación ───────────────────────────────────────────────
class _WeightRow extends StatefulWidget {
  final String label;
  final String? sublabel;
  final int pct;
  final double score;
  final Color color;
  final bool isDark;
  const _WeightRow({
    required this.label,
    required this.pct,
    required this.score,
    required this.color,
    required this.isDark,
    this.sublabel,
  });
  @override
  State<_WeightRow> createState() => _WeightRowState();
}

class _WeightRowState extends State<_WeightRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _w;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _w = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(widget.isDark);
    final border = AppColors.border(widget.isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.color,
                      ),
                    ),
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: AppColors.text(widget.isDark),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.sublabel != null) ...[
                  const SizedBox(height: 3),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      widget.sublabel!,
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            Row(
              children: [
                Text(
                  widget.score.toStringAsFixed(1),
                  style: TextStyle(
                    color: widget.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  ' /10',
                  style: TextStyle(
                    color: muted.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.pct}%',
                  style: TextStyle(
                    color: widget.color.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _w,
          builder: (_, _) => ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (widget.pct / 100.0) * _w.value,
              minHeight: 3,
              backgroundColor: border,
              valueColor: AlwaysStoppedAnimation(widget.color.withValues(alpha: 0.8)),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated Radar Chart ──────────────────────────────────────────────────────
class _AnimatedRadarChart extends StatefulWidget {
  final Map<String, double> scores;
  final bool isDark;
  const _AnimatedRadarChart({required this.scores, required this.isDark});

  @override
  State<_AnimatedRadarChart> createState() => _AnimatedRadarChartState();
}

class _AnimatedRadarChartState extends State<_AnimatedRadarChart>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  // Pulso sutil continuo
  late final AnimationController _pulse;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward(from: 0);

    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulse, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _ctrl.forward(from: 0),
      child: AnimatedBuilder(
        animation: Listenable.merge([_anim, _pulseAnim]),
        builder: (_, _) => CustomPaint(
          size: const Size(280, 280),
          painter: _RadarPainter(
            scores: widget.scores,
            progress: _anim.value,
            pulse: _pulseAnim.value,
            isDark: widget.isDark,
          ),
        ),
      ),
    );
  }
}

// ── Radar Painter ─────────────────────────────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final Map<String, double> scores;
  final double progress;
  final double pulse;
  final bool isDark;
  const _RadarPainter({
    required this.scores,
    required this.progress,
    required this.pulse,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = cx * 0.76;
    final n = scores.length;
    final angle = (2 * math.pi) / n;

    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.06);
    final spokeColor = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.05);

    // ── Anillos de cuadrícula ─────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (int ring = 1; ring <= 5; ring++) {
      final rr = r * ring / 5;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final a = i * angle - math.pi / 2;
        final pt = Offset(cx + rr * math.cos(a), cy + rr * math.sin(a));
        i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // ── Radios (spokes) ───────────────────────────────────────────────────
    for (int i = 0; i < n; i++) {
      final a = i * angle - math.pi / 2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
        Paint()
          ..color = spokeColor
          ..strokeWidth = 1,
      );
    }

    // ── Construir vértices y colores ──────────────────────────────────────
    final entries = scores.entries.toList();
    final totalPoints = n + 1;
    final drawnCount = (progress * totalPoints).ceil().clamp(1, totalPoints);

    final dataPath = Path();
    final List<Offset> points = [];
    final List<Color> colors = [];
    for (int i = 0; i < n; i++) {
      final v = entries[i].value / 10.0;
      final a = i * angle - math.pi / 2;
      points.add(Offset(cx + r * v * math.cos(a), cy + r * v * math.sin(a)));
      colors.add(_statColor(entries[i].value));
    }

    // Color promedio del relleno
    final avgColor = colors.fold<Color>(
      Colors.transparent,
      (acc, c) => Color.lerp(acc, c, 0.5)!,
    );

    // Dibujado progresivo
    for (int i = 0; i < drawnCount && i < n; i++) {
      if (i == 0) {
        dataPath.moveTo(points[0].dx, points[0].dy);
      } else {
        if (i == drawnCount - 1 && drawnCount < totalPoints) {
          final segProgress = (progress * totalPoints) - (drawnCount - 1);
          final prev = points[i - 1];
          final curr = points[i];
          final mid = Offset.lerp(prev, curr, segProgress)!;
          dataPath.lineTo(mid.dx, mid.dy);
        } else {
          dataPath.lineTo(points[i].dx, points[i].dy);
        }
      }
    }
    if (drawnCount >= n) dataPath.close();

    // Relleno con gradiente radial del color promedio + pulso sutil
    canvas.drawPath(
      dataPath,
      Paint()
        ..shader = RadialGradient(
          colors: [
            avgColor.withValues(alpha: (0.22 + 0.06 * pulse) * progress),
            avgColor.withValues(alpha: 0.03),
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r))
        ..style = PaintingStyle.fill,
    );

    // Borde exterior con glow (color promedio)
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = avgColor.withValues(alpha: (0.7 + 0.2 * pulse) * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 + 2 * pulse),
    );

    // Línea nítida encima
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85 * progress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..strokeJoin = StrokeJoin.round,
    );

    // ── Puntos de color en vértices (semáforo) ────────────────────────────
    for (int i = 0; i < n; i++) {
      if (i >= drawnCount) break;
      final vc = colors[i];
      // Halo exterior con pulso
      canvas.drawCircle(
        points[i],
        10 + 3 * pulse,
        Paint()
          ..color = vc.withValues(alpha: (0.2 + 0.1 * pulse) * progress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Punto sólido del color de la stat
      canvas.drawCircle(
        points[i],
        4.5,
        Paint()..color = vc.withValues(alpha: progress),
      );
      // Centro blanco
      canvas.drawCircle(
        points[i],
        2.0,
        Paint()..color = Colors.white.withValues(alpha: progress),
      );

      // Label con el color de la stat
      final la = i * angle - math.pi / 2;
      final labelOffset = Offset(
        cx + (r + 24) * math.cos(la),
        cy + (r + 24) * math.sin(la),
      );
      _drawLabel(canvas, entries[i].key, labelOffset, vc.withValues(alpha: progress));
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset offset, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(offset.dx - tp.width / 2, offset.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter old) =>
      old.progress != progress || old.pulse != pulse || old.isDark != isDark;
}

// ── Badge de gamificación ────────────────────────────────────────────────────
// _BadgeIcon removed as it is no longer used in the V5 design.

void _showQRPass(BuildContext context, AppUser? user, bool isDark) {
  if (user == null) return;
  final qrData = 'sportlink://user/${user.uniqueId}';
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
              ? [const Color(0xFF1E1E1E), const Color(0xFF0F0F0F)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF0F0F0)],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: const Color(0xFFF4CA25).withValues(alpha: 0.3),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Grabber
              Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 28),
                decoration: BoxDecoration(
                  color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              // Header del Ticket
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PASE DIGITAL VIP',
                        style: TextStyle(
                          color: Color(0xFFF4CA25),
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ACREDITACIÓN DE JUGADOR',
                        style: TextStyle(
                          color: AppColors.textMuted(isDark),
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4CA25).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star, color: Color(0xFFF4CA25), size: 24),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              
              // Contenedor del QR
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF4CA25).withValues(alpha: 0.15),
                      blurRadius: 30,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 240.0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  errorCorrectionLevel: QrErrorCorrectLevel.Q,
                ),
              ),
              
              const SizedBox(height: 36),
              
              // Detalles del Usuario
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(
                  children: [
                    Text(
                      user.uniqueId,
                      style: TextStyle(
                        color: AppColors.text(isDark),
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 5,
                        fontFamily: 'Courier',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user.name.toUpperCase(),
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 28),
              
              // Badge de Validación
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified_user, color: Color(0xFF34C759), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Identidad Validada en SportLink',
                      style: TextStyle(
                        color: Color(0xFF34C759),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        ),
      ),
    ),
  );
}

void _showAdjustStatsModal(BuildContext context, AppUser? user, bool isDark) {
  if (user == null) return;
  final surface = AppColors.surface(isDark);
  final text = AppColors.text(isDark);
  final muted = AppColors.textMuted(isDark);
  
  showModalBottomSheet(
    context: context,
    backgroundColor: surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajuste de Stats por Video', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Basado en la evidencia del video VEO, ¿cómo evaluarías el rendimiento del jugador en este partido?', style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Técnica', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (index) => Icon(Icons.star, color: index < 4 ? Colors.amber : muted, size: 28)),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Resistencia', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (index) => Icon(Icons.star, color: index < 3 ? Colors.amber : muted, size: 28)),
                )
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fair Play', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (index) => Icon(Icons.star, color: index < 5 ? Colors.amber : muted, size: 28)),
                )
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBg(isDark),
                  foregroundColor: AppColors.buttonFg(isDark),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: AppColors.buttonBg(isDark), content: Text('Stats actualizadas en el Smart Contract', style: TextStyle(color: AppColors.buttonFg(isDark)))));
                },
                child: const Text('Confirmar Evaluación de Video', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


double _avg(Map<String, double> stats) {
  if (stats.isEmpty) return 0.0;
  return stats.values.reduce((a, b) => a + b) / stats.length;
}

// ── Historial de Partidos (Transparencia) ───────────────────────────────────
class _MatchHistorySection extends ConsumerWidget {
  final String playerId;
  final bool isDark;

  const _MatchHistorySection({required this.playerId, required this.isDark});

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

// ── Sección de Ofertas Recibidas ───────────────────────────────────────────
class _OffersSection extends ConsumerWidget {
  final String playerId;
  final bool isDark;

  const _OffersSection({required this.playerId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final players = ref.watch(playersProvider);
    final pData = players.where((p) => p.user.uniqueId == playerId || p.user.id == playerId).firstOrNull;
    final offers = pData?.pendingOffers ?? [];

    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OFERTAS Y CONTRATOS',
              style: TextStyle(
                color: muted,
                fontSize: 11,
                letterSpacing: 2,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (offers.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${offers.length} NUEVAS',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (offers.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_outlined, color: muted.withValues(alpha: 0.3), size: 40),
                const SizedBox(height: 12),
                Text(
                  'No tienes ofertas pendientes',
                  style: TextStyle(color: muted, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sigue mejorando tu OVR para llamar la atención',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted.withValues(alpha: 0.5), fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...offers.map((offer) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF4CA25).withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF4CA25).withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFF4CA25).withValues(alpha: 0.1),
                      child: const Icon(Icons.business, color: Color(0xFFF4CA25), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer['club'] ?? 'Club Interesado',
                            style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            'Enviada por: ${offer['scout'] ?? 'Scout de SportLink'}',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TIPO DE CONTRATO', style: TextStyle(color: muted, fontSize: 9, letterSpacing: 1)),
                        const SizedBox(height: 4),
                        Text(offer['type'] ?? 'Becas Deportivas', style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 13)),
                      ],
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34C759),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: const Text('Ver Detalles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          )),
      ],
    );
  }
}

// ── Gráfico de Progresión de OVR (Premium Custom Paint) ─────────────────────
class _OvrProgressionChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> history;
  final bool isDark;

  const _OvrProgressionChart({required this.history, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (history.length < 2) return const SizedBox.shrink();

    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final accent = const Color(0xFF007AFF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESIÓN DE RENDIMIENTO',
          style: TextStyle(
            color: muted,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 180,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.border(isDark)),
          ),
          child: Column(
            children: [
              Expanded(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _ChartPainter(history: history, isDark: isDark, accent: accent),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Ene', style: TextStyle(color: muted, fontSize: 10)),
                  Text('Feb', style: TextStyle(color: muted, fontSize: 10)),
                  Text('Mar', style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> history;
  final bool isDark;
  final Color accent;

  _ChartPainter({required this.history, required this.isDark, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [accent.withValues(alpha: 0.3), accent.withValues(alpha: 0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final minOvr = history.map((e) => e.value).reduce(math.min) - 5;
    final maxOvr = history.map((e) => e.value).reduce(math.max) + 5;
    final range = maxOvr - minOvr;

    for (int i = 0; i < history.length; i++) {
      final x = (size.width / (history.length - 1)) * i;
      final y = size.height - ((history[i].value - minOvr) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
      
      if (i == history.length - 1) {
        fillPath.lineTo(x, size.height);
        fillPath.close();
      }
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Puntos
    final dotPaint = Paint()..color = accent;
    final dotOuterPaint = Paint()..color = Colors.white;
    for (int i = 0; i < history.length; i++) {
      final x = (size.width / (history.length - 1)) * i;
      final y = size.height - ((history[i].value - minOvr) / range) * size.height;
      canvas.drawCircle(Offset(x, y), 5, dotOuterPaint);
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ── Carrusel de Logros (Badges) ──────────────────────────────────────────────
class _AchievementsCarousel extends StatelessWidget {
  final List<String> badges;
  final bool isDark;

  const _AchievementsCarousel({required this.badges, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    
    // Mock badges if empty for pitch
    final displayBadges = badges.isEmpty 
      ? ['Primer Match', 'OVR +75', 'Verificado', 'Scout Interest'] 
      : badges;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOGROS Y RECONOCIMIENTOS',
          style: TextStyle(
            color: muted,
            fontSize: 11,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: displayBadges.map((b) => _BadgeItem(label: b, isDark: isDark)).toList(),
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String label;
  final bool isDark;

  const _BadgeItem({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isPro = label == 'Verificado';
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPro ? const Color(0xFFF4CA25) : AppColors.border(isDark)),
        boxShadow: [
          if (isPro)
            BoxShadow(color: const Color(0xFFF4CA25).withValues(alpha: 0.1), blurRadius: 10)
        ],
      ),
      child: Row(
        children: [
          Icon(isPro ? Icons.verified : Icons.workspace_premium, 
               color: isPro ? const Color(0xFFF4CA25) : Colors.grey, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Métrica de Interés Global (Anónima) ─────────────────────────────────────
class _InterestMetricCard extends StatelessWidget {
  final int count;
  final bool isDark;

  const _InterestMetricCard({required this.count, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove_red_eye_outlined, color: Colors.blue, size: 24),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INTERÉS RECIBIDO',
                  style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Scouts te tienen en Watchlist',
                  style: TextStyle(color: text, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Tu visibilidad ha subido un 12% esta semana',
                  style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _TutorSection extends StatelessWidget {
  final AppUser user;
  final bool isDark;
  final Color surface, border, muted, text;

  const _TutorSection({
    required this.user,
    required this.isDark,
    required this.surface,
    required this.border,
    required this.muted,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.family_restroom, color: AppColors.buttonBg(isDark), size: 20),
            const SizedBox(width: 12),
            Text(
              'PANEL DEL TUTOR',
              style: TextStyle(
                color: muted,
                fontSize: 10,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        
        // Timeline de Hitos
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cronología de Hitos',
                style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              _MilestoneItem(
                date: 'Hoy',
                title: 'OVR subió a 78.4',
                desc: 'Progreso destacado en Técnica individual.',
                isLast: false,
                isDark: isDark,
              ),
              _MilestoneItem(
                date: '24 Mar',
                title: 'Primer Acta Sellada',
                desc: 'Partido validado por árbitro colegiado.',
                isLast: false,
                isDark: isDark,
              ),
              _MilestoneItem(
                date: '20 Mar',
                title: 'Registro en SportLink',
                desc: 'Inicio del historial deportivo digital.',
                isLast: true,
                isDark: isDark,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Control de Privacidad
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seguridad y Privacidad',
                style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              _PrivacySwitch(
                label: 'Visibilidad en Mercado de Talentos',
                value: user.privacySettings['scoutVisible'] ?? true,
                isDark: isDark,
              ),
              _PrivacySwitch(
                label: 'Permitir Contacto de Clubes',
                value: user.privacySettings['contactEnabled'] ?? false,
                isDark: isDark,
              ),
              _PrivacySwitch(
                label: 'Ocultar Localización Exacta',
                value: user.privacySettings['hideLocation'] ?? true,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MilestoneItem extends StatelessWidget {
  final String date, title, desc;
  final bool isLast, isDark;
  const _MilestoneItem({required this.date, required this.title, required this.desc, required this.isLast, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    final text = AppColors.text(isDark);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.buttonBg(isDark),
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 1,
                height: 40,
                color: AppColors.border(isDark),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(date, style: TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Text(title, style: TextStyle(color: text, fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              Text(desc, style: TextStyle(color: muted, fontSize: 11, height: 1.4)),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacySwitch extends StatelessWidget {
  final String label;
  final bool value;
  final bool isDark;
  const _PrivacySwitch({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(color: AppColors.text(isDark), fontSize: 13))),
          Switch(
            value: value,
            onChanged: (v) {},
            activeColor: AppColors.buttonBg(isDark),
          ),
        ],
      ),
    );
  }
}
