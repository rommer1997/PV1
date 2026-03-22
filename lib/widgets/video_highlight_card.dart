import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VideoHighlightCard extends ConsumerWidget {
  final String title;
  final String description;
  final String matchDate;
  final bool isDark;
  final VoidCallback onAdjustStats;
  final VoidCallback onShareToFeed;
  final bool canAdjustStats; // Para entrenadores, staff, comunidad
  final bool canBroadcast; // Para periodistas

  const VideoHighlightCard({
    super.key,
    required this.title,
    required this.description,
    required this.matchDate,
    required this.isDark,
    required this.onAdjustStats,
    required this.onShareToFeed,
    this.canAdjustStats = false,
    this.canBroadcast = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Video Player Area
          Stack(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: DecorationImage(
                    image: const NetworkImage('https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=1000&auto=format&fit=crop'), // Placeholder de fútbol
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.4), BlendMode.darken),
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.buttonBg(isDark).withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('04:15', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.videocam_outlined, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('SLP VEO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Video Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: muted, fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  'Grabado el $matchDate',
                  style: TextStyle(color: text.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                
                // Action Buttons based on Role
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      if (canAdjustStats)
                        _ActionButton(
                          icon: Icons.tune_rounded,
                          label: 'Ajustar Stats',
                          color: Colors.amber,
                          onTap: onAdjustStats,
                          isDark: isDark,
                        ),
                      if (canAdjustStats) const SizedBox(width: 10),
                      if (canBroadcast)
                        _ActionButton(
                          icon: Icons.podcasts_outlined,
                          label: 'Usar en Studio',
                          color: Colors.purpleAccent,
                          onTap: onShareToFeed,
                          isDark: isDark,
                        ),
                      if (canBroadcast && !canAdjustStats) const SizedBox(width: 10),
                      
                      // Shared actions
                      _ActionButton(
                        icon: Icons.monetization_on_outlined,
                        label: 'Apoyar',
                        color: const Color(0xFFE2F163),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Has enviado +1 SC como propina al jugador por este highlight.',
                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Color(0xFFE2F163),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _ActionButton(
                        icon: Icons.share_outlined,
                        label: 'Compartir',
                        color: AppColors.buttonBg(isDark),
                        onTap: () {},
                        isDark: isDark,
                        isGhost: true,
                      ),
                    ],
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;
  final bool isGhost;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.isDark,
    this.isGhost = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isGhost ? Colors.transparent : color.withValues(alpha: 0.1),
          border: isGhost ? Border.all(color: AppColors.border(isDark)) : Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: isGhost ? AppColors.text(isDark) : color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isGhost ? AppColors.text(isDark) : color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
