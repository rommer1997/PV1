import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_user.dart';
import '../../services/user_storage_service.dart';
import '../auth/welcome_screen.dart';
import 'notifications_settings_screen.dart';
import 'help_support_screen.dart';
import 'privacy_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature estará disponible próximamente.'),
        backgroundColor: const Color(0xFFF4CA25), // Brand yellow
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final user = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Configuración',
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // ── 1. Privacidad y Seguridad ──────────────────────────────────────
          _buildSectionHeader('Privacidad y Seguridad', muted),
          _buildListTile(
            icon: Icons.lock_outline,
            title: 'Control de Visibilidad del Perfil',
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsScreen())),
          ),
          _buildListTile(
            icon: Icons.shield_outlined,
            title: 'Modo Menores / Crisis',
            subtitle: 'Oculta tus datos sensibles',
            isDark: isDark,
            trailing: Consumer(builder: (context, ref, _) {
              final isLocked = ref.watch(safetyLockProvider);
              return Switch(
                value: isLocked,
                activeThumbColor: Colors.red,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  ref.read(safetyLockProvider.notifier).toggle();
                },
              );
            }),
            onTap: () {},
          ),
          _buildListTile(icon: Icons.data_usage, title: 'Gestión de Datos Personales', isDark: isDark, onTap: () => _showComingSoon(context, 'Gestión de Datos')),
          _buildListTile(icon: Icons.security, title: 'Autenticación de Dos Factores (2FA)', isDark: isDark, onTap: () => _showComingSoon(context, '2FA')),
          _buildListTile(icon: Icons.devices, title: 'Dispositivos Conectados', isDark: isDark, onTap: () => _showComingSoon(context, 'Dispositivos Conectados')),
          _buildListTile(icon: Icons.password, title: 'Cambiar Contraseña', isDark: isDark, onTap: () => _showComingSoon(context, 'Cambio de Contraseña')),
          const SizedBox(height: 24),

          // ── 2. Notificaciones ──────────────────────────────────────────────
          _buildSectionHeader('Notificaciones', muted),
          _buildListTile(
            icon: Icons.notifications_active_outlined,
            title: 'Preferencias de Notificación',
            isDark: isDark,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsSettingsScreen())),
          ),
          _buildListTile(
            icon: Icons.mail_outline,
            title: 'Canales de Notificación',
            subtitle: 'Push, Email, SMS',
            isDark: isDark,
            onTap: () => _showComingSoon(context, 'Canales de Notificación'),
          ),
          const SizedBox(height: 24),

          // ── 3. Apariencia y Accesibilidad ──────────────────────────────────
          _buildSectionHeader('Apariencia y Accesibilidad', muted),
          _buildListTile(
            icon: isDark ? Icons.nightlight_round : Icons.wb_sunny,
            title: 'Modo Oscuro',
            isDark: isDark,
            trailing: Switch(
              value: isDark,
              activeThumbColor: AppColors.buttonBg(isDark),
              onChanged: (val) {
                HapticFeedback.lightImpact();
                ref.read(themeProvider.notifier).toggle();
              },
            ),
            onTap: () {},
          ),
          _buildListTile(icon: Icons.language, title: 'Idioma', subtitle: 'Español (ES)', isDark: isDark, onTap: () => _showComingSoon(context, 'Selector de Idiomas')),
          _buildListTile(icon: Icons.text_fields, title: 'Tamaño de Fuente', isDark: isDark, onTap: () => _showComingSoon(context, 'Tamaño de Fuente')),
          const SizedBox(height: 24),

          // ── 4. Gestión de SportCoins ───────────────────────────────────────
          _buildSectionHeader('Gestión de SportCoins', muted),
          _buildListTile(
            icon: Icons.monetization_on_outlined,
            title: 'Saldo Actual',
            subtitle: '${user?.sportcoins ?? 0} SC',
            isDark: isDark,
            onTap: () {},
          ),
          _buildListTile(icon: Icons.history, title: 'Historial de Transacciones', isDark: isDark, onTap: () => _showComingSoon(context, 'Historial de SportCoins')),
          _buildListTile(icon: Icons.add_circle_outline, title: 'Recargar SportCoins', isDark: isDark, onTap: () => _showComingSoon(context, 'Recarga de SportCoins')),
          _buildListTile(icon: Icons.money_off, title: 'Retirar SportCoins', isDark: isDark, onTap: () => _showComingSoon(context, 'Retirada de SportCoins')),
          const SizedBox(height: 24),

          // ── 5. Ayuda y Soporte ─────────────────────────────────────────────
          _buildSectionHeader('Ayuda y Soporte', muted),
          _buildListTile(icon: Icons.question_answer_outlined, title: 'Preguntas Frecuentes (FAQ)', isDark: isDark, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
          _buildListTile(icon: Icons.contact_support_outlined, title: 'Contactar Soporte', isDark: isDark, onTap: () => _showComingSoon(context, 'Soporte Directo')),
          _buildListTile(icon: Icons.bug_report_outlined, title: 'Reportar un Problema', isDark: isDark, onTap: () => _showComingSoon(context, 'Reporte de Errores')),
          const SizedBox(height: 32),

          // ── Cerrar Sesión ──────────────────────────────────────────────────
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface(isDark),
                  title: Text('Cerrar Sesión', style: TextStyle(color: text)),
                  content: Text('¿Seguro que deseas salir de Cantera?', style: TextStyle(color: muted)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancelar', style: TextStyle(color: text)),
                    ),
                    TextButton(
                      onPressed: () async {
                        ref.read(sessionProvider.notifier).logout();
                        await UserStorageService.clearSession();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                          (route) => false,
                        );
                      },
                      child: const Text('Salir', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text(isDark)),
      title: Text(title, style: TextStyle(color: AppColors.text(isDark))),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12)) : null,
      trailing: trailing ?? Icon(Icons.chevron_right, color: AppColors.textMuted(isDark)),
      onTap: onTap,
    );
  }
}
