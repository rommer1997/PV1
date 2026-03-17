import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ScoutDashboardScreen extends ConsumerWidget {
  const ScoutDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Favoritos', style: TextStyle(color: text)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 60, color: muted),
            const SizedBox(height: 16),
            Text(
              'No tienes talentos en seguimiento',
              style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ve al Mercado para descubrir perfiles',
              style: TextStyle(color: muted, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
