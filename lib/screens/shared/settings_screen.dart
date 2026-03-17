import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/app_user.dart';
import '../../services/user_storage_service.dart';
import '../auth/welcome_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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
          'Configuración',
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildSectionHeader('Cuenta', muted),
          _buildListTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            isDark: isDark,
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.notifications_none,
            title: 'Notificaciones',
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          
          _buildSectionHeader('Preferencias', muted),
          ListTile(
            leading: Icon(
              isDark ? Icons.nightlight_round : Icons.wb_sunny,
              color: AppColors.text(isDark),
            ),
            title: Text('Modo Oscuro', style: TextStyle(color: text)),
            trailing: Switch(
              value: isDark,
              activeColor: AppColors.buttonBg(isDark),
              onChanged: (val) {
                HapticFeedback.lightImpact();
                ref.read(themeProvider.notifier).toggle();
              },
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Privacidad y Seguridad', muted),
          ListTile(
            leading: Icon(Icons.security, color: AppColors.text(isDark)),
            title: Text('Modo Menores / Crisis', style: TextStyle(color: text)),
            subtitle: Text(
              'Oculta tus datos sensibles públicamente',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            trailing: Consumer(builder: (context, ref, _) {
              final isLocked = ref.watch(safetyLockProvider);
              return Switch(
                value: isLocked,
                activeColor: Colors.red,
                onChanged: (val) {
                  HapticFeedback.mediumImpact();
                  ref.read(safetyLockProvider.notifier).toggle();
                },
              );
            }),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('Más', muted),
          _buildListTile(
            icon: Icons.help_outline,
            title: 'Soporte y Ayuda',
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(height: 32),
          
          GestureDetector(
            onTap: () async {
              HapticFeedback.mediumImpact();
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: AppColors.surface(isDark),
                  title: Text('Cerrar Sesión', style: TextStyle(color: text)),
                  content: Text('¿Seguro que deseas salir de SportLink Pro?', style: TextStyle(color: muted)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Cancelar', style: TextStyle(color: text)),
                    ),
                    TextButton(
                      onPressed: () async {
                        // FIX DEMO LOGOUT
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
                border: Border.all(color: Colors.red.withOpacity(0.5)),
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
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.text(isDark)),
      title: Text(title, style: TextStyle(color: AppColors.text(isDark))),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted(isDark)),
      onTap: onTap,
    );
  }
}
