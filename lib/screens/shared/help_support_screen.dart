import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

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
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Soporte y Ayuda',
          style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFAQTile('¿Cómo gano SportCoins?', 'Evaluando partidos, viendo contenido publicitario o recibiendo propinas (Tips) por tus highlights.', text, muted),
            _buildFAQTile('¿Qué es el Athletic-CV?', 'Es el formato digital estándar en donde convergen tus evaluaciones y métricas de desempeño.', text, muted),
            _buildFAQTile('No veo M-Search', 'El mercado de búsqueda avanzada está restringido. Necesitas ser un Staff verificado con validación institucional para buscar menores o talentos globales.', text, muted),
            const SizedBox(height: 32),
            Text(
              'Contacto Rápido',
              style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionTile(Icons.chat_bubble_outline, 'Hablar con Soporte', isDark, () {}),
            _buildActionTile(Icons.policy_outlined, 'Términos y Condiciones', isDark, () {}),
            _buildActionTile(Icons.privacy_tip_outlined, 'Centro de Protección', isDark, () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQTile(String title, String answer, Color textColor, Color mutedColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 6),
          Text(answer, style: TextStyle(color: mutedColor, fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, bool isDark, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.text(isDark)),
      title: Text(title, style: TextStyle(color: AppColors.text(isDark))),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(isDark)),
      onTap: onTap,
    );
  }
}
