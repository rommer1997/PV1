import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class AchievementsCarousel extends StatelessWidget {
  final List<String> badges;
  final bool isDark;

  const AchievementsCarousel({
    super.key,
    required this.badges,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    
    // Si no hay insignias, mostramos unas por defecto para el pitch
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
            children: displayBadges
                .map((b) => _BadgeItem(label: b, isDark: isDark))
                .toList(),
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
    // Definimos qué insignias son "especiales" visualmente
    final isSpecial = label == 'Verificado' || label == 'Elite MVP';
    
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSpecial ? const Color(0xFFF4CA25) : AppColors.border(isDark),
        ),
        boxShadow: [
          if (isSpecial)
            BoxShadow(
              color: const Color(0xFFF4CA25).withValues(alpha: 0.1),
              blurRadius: 10,
            )
        ],
      ),
      child: Row(
        children: [
          Icon(
            isSpecial ? Icons.verified : Icons.workspace_premium, 
            color: isSpecial ? const Color(0xFFF4CA25) : Colors.grey, 
            size: 18,
          ),
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
