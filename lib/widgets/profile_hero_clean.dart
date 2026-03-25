import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/app_user.dart';
import '../providers/theme_provider.dart';
import '../providers/players_provider.dart';
import '../theme/cantera_premium_styles.dart';
import 'interest_metric_card.dart';
import 'totw_player_card.dart';
import '../screens/shared/profile_edit_screen.dart';

class ProfileHeroClean extends ConsumerWidget {
  final AppUser? user;
  final Map<String, double> stats;
  final bool isDark;

  const ProfileHeroClean({
    super.key,
    required this.user,
    required this.stats,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calcular Overall (OVR)
    final avg = stats.values.isEmpty ? 0.0 : stats.values.reduce((a, b) => a + b) / stats.length;
    final ovr = (avg * 10).round();

    final pac = ((stats['VEL'] ?? 0) * 10).round();
    final sho = ((stats['FPL'] ?? 0) * 10).round();
    final pas = ((stats['TÁC'] ?? 0) * 10).round();
    final dri = ((stats['TEC'] ?? 0) * 10).round();
    final def = ((stats['RES'] ?? 0) * 10).round();
    final phy = ((stats['FUE'] ?? 0) * 10).round();

    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: CanteraSpacing.k10),
      decoration: CanteraPremiumColors.glass(color: isDark ? Colors.white : Colors.black).copyWith(
        borderRadius: BorderRadius.circular(24),
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
                  decoration: CanteraPremiumColors.glass(color: CanteraPremiumColors.neonCyan).copyWith(
                    borderRadius: BorderRadius.circular(16),
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
                        color: CanteraPremiumColors.surface,
                        border: Border.all(color: CanteraPremiumColors.neonCyan.withOpacity(0.5), width: 1.5),
                        boxShadow: CanteraEffects.neonGlow(CanteraPremiumColors.neonCyan.withOpacity(0.2)),
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
                      onTap: () => _showQRCode(context, user?.uniqueId ?? 'Cantera-UNK'),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: CanteraPremiumColors.neonCyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: CanteraPremiumColors.background, width: 2),
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
            onTap: () => _showPositionPicker(context, user),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: CanteraPremiumColors.neonGas(CanteraPremiumColors.premiumGold, opacity: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${user?.position ?? 'ST'} • SPAIN',
                style: const TextStyle(
                  color: CanteraPremiumColors.premiumGold,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
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
          const SizedBox(height: 16),
          // ── Métrica de Interés (Engagement) ──
          Consumer(
            builder: (context, ref, _) {
              final players = ref.watch(playersProvider);
              final pData = players.where((p) => p.user.id == user?.id || p.user.uniqueId == user?.uniqueId).firstOrNull;
              return InterestMetricCard(
                count: pData?.scoutWatchlistIds.length ?? 0,
                isDark: isDark,
              );
            },
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
              'TU CREDENCIAL Cantera',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
            const SizedBox(height: 24),
            QrImageView(
              data: 'https://cantera.pro/cv/$uid',
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

  void _showPositionPicker(BuildContext context, AppUser? user) {
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
