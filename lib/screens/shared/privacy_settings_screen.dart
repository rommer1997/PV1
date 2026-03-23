import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_user.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final isLocked = ref.watch(safetyLockProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Privacidad y Seguridad',
          style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.shield, color: Colors.red),
                    const SizedBox(width: 8),
                    Text('Modo Menores / Crisis', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Si activas esta opción extrafuerte, ocultarás de inmediato todos los datos de contacto y biografía en cualquier parte del mundo. Solo instituciones verificadas verán tu información.',
                  style: TextStyle(color: muted, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Bloqueo Activo', style: TextStyle(color: text)),
                  value: isLocked,
                  activeColor: Colors.red,
                  onChanged: (val) {
                    HapticFeedback.heavyImpact();
                    ref.read(safetyLockProvider.notifier).toggle();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Visibilidad General',
            style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildOptionTile('Aparecer publicamente en el mercado', true, isDark),
          _buildOptionTile('Permitir Mensajes Directos (DMs)', false, isDark),
          _buildOptionTile('Ocultar Equipo Actual a rivales', false, isDark),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, bool val, bool isDark) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: AppColors.text(isDark))),
      value: val,
      activeColor: AppColors.buttonBg(isDark),
      onChanged: (_) {}, // Para propósitos de maquetado interactivo
    );
  }
}
