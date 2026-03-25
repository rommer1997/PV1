import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/players_provider.dart';
import '../../models/app_user.dart';
import '../../screens/fish_card_screen.dart';

class ScoutDashboardScreen extends ConsumerWidget {
  const ScoutDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final players = ref.watch(playersProvider);
    final user = ref.watch(sessionProvider);
    
    // Identificar al scout actual (en demo usamos el ID '3' de David Torres)
    final scoutId = user?.id ?? '3';
    
    // Filtrar jugadores en seguimiento por este scout
    final following = players.where((p) => p.scoutWatchlistIds.contains(scoutId)).toList();

    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'MI SEGUIMIENTO',
          style: TextStyle(
            color: text,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline, color: muted),
            onPressed: () {},
          ),
        ],
      ),
      body: following.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.star_border_rounded, size: 64, color: muted),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'LISTA VACÍA',
                    style: TextStyle(
                      color: text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Explora el Mercado de Talentos para añadir perfiles a tu seguimiento.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: following.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final p = following[index];
                return _PlayerFollowCard(
                  player: p,
                  isDark: isDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FishCardScreen(playerId: p.user.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _PlayerFollowCard extends StatelessWidget {
  final PlayerData player;
  final bool isDark;
  final VoidCallback onTap;

  const _PlayerFollowCard({
    required this.player,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 2),
              ),
              child: Icon(
                Icons.person_rounded,
                color: muted.withValues(alpha: 0.5),
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.user.name.toUpperCase(),
                    style: TextStyle(
                      color: text,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.user.position} • ${player.user.teamName ?? 'Agente Libre'}',
                    style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: border, size: 28),
          ],
        ),
      ),
    );
  }
}
