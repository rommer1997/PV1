import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';

class InterestMetricCard extends StatelessWidget {
  final int count;
  final bool isDark;

  const InterestMetricCard({
    super.key,
    required this.count,
    required this.isDark,
  });

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
            child: const Icon(
              Icons.remove_red_eye_outlined, 
              color: Colors.blue, 
              size: 24,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INTERÉS RECIBIDO',
                  style: TextStyle(
                    color: muted, 
                    fontSize: 10, 
                    fontWeight: FontWeight.w800, 
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count Scouts te tienen en Watchlist',
                  style: TextStyle(
                    color: text, 
                    fontSize: 14, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Tu visibilidad ha subido un 12% esta semana',
                  style: const TextStyle(
                    color: Colors.green, 
                    fontSize: 11, 
                    fontWeight: FontWeight.w500,
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
