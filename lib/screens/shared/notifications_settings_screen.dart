import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class NotificationsSettingsScreen extends ConsumerStatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  ConsumerState<NotificationsSettingsScreen> createState() => _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState extends ConsumerState<NotificationsSettingsScreen> {
  // Simulando estado guardado
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _scoutAlerts = true;
  bool _matchReminders = true;

  @override
  Widget build(BuildContext context) {
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
          'Notificaciones',
          style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        children: [
          _buildToggle(
            'Notificaciones Push',
            'Recibe alertas instantáneas en tu dispositivo.',
            _pushEnabled,
            (v) => setState(() => _pushEnabled = v),
            isDark,
          ),
          const Divider(height: 32),
          _buildToggle(
            'Resumen Semanal por Email',
            'Un correo cada lunes con estadísticas de tu perfil.',
            _emailEnabled,
            (v) => setState(() => _emailEnabled = v),
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferencias de Alertas', muted),
          _buildToggle('Alertas de Ojeadores (Scouts)', '', _scoutAlerts, (v) => setState(() => _scoutAlerts = v), isDark),
          _buildToggle('Recordatorios de Partidos', '', _matchReminders, (v) => setState(() => _matchReminders = v), isDark),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, bool value, ValueChanged<bool> onChanged, bool isDark) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: AppColors.text(isDark))),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12)) : null,
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.buttonBg(isDark),
        onChanged: (val) {
          HapticFeedback.lightImpact();
          onChanged(val);
        },
      ),
    );
  }
}
