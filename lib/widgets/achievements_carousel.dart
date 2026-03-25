import 'package:flutter/material.dart';
import '../theme/cantera_premium_styles.dart';

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
    final muted = CanteraPremiumColors.textMuted;
    
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
      decoration: CanteraPremiumColors.glass(
        color: isSpecial ? CanteraPremiumColors.premiumGold : (isDark ? Colors.white : Colors.black),
      ).copyWith(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isSpecial ? CanteraEffects.neonGlow(CanteraPremiumColors.premiumGold.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Icon(
            isSpecial ? Icons.verified : Icons.workspace_premium, 
            color: isSpecial ? CanteraPremiumColors.premiumGold : CanteraPremiumColors.textMuted, 
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSpecial ? CanteraPremiumColors.premiumGold : CanteraPremiumColors.text,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
