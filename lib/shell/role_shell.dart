import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_role.dart';
import '../screens/fish_card_screen.dart';
import '../screens/stadium_feed_screen.dart';
import '../screens/scout/scout_marketplace_screen.dart';
import '../screens/coach/coach_dashboard_screen.dart';
import '../screens/coach/coach_marketplace_screen.dart';
import '../screens/tutor/tutor_approvals_screen.dart';
import '../screens/fan/predict_screen.dart';
import '../screens/journalist/journalist_screen.dart';
import '../screens/brand/brand_dashboard_screen.dart';
import '../screens/shared/wallet_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/staff/staff_dashboard_screen.dart';
import '../providers/theme_provider.dart';
import '../services/user_storage_service.dart';
import '../screens/shared/explore_hub_screen.dart';
import '../screens/shared/settings_screen.dart';
import '../screens/referee_terminal_screen.dart';

class RoleShell extends ConsumerStatefulWidget {
  final UserRole role;
  const RoleShell({super.key, required this.role});

  @override
  ConsumerState<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends ConsumerState<RoleShell> {
  int _index = 0;

  List<_NavItem> get _items {
    switch (widget.role) {
      case UserRole.player:
        return [
          _NavItem(Icons.person_outline, 'Perfil', FishCardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.dynamic_feed_outlined, 'Feed', StadiumFeedScreen()),
          const _NavItem(Icons.account_balance_wallet_outlined, 'Wallet', WalletScreen()),
        ];
      case UserRole.tutor:
        return [
          const _NavItem(Icons.approval_outlined, 'Docs', TutorApprovalsScreen()),
          _NavItem(Icons.person_outline, 'Hijo', FishCardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.dynamic_feed_outlined, 'Feed', StadiumFeedScreen()),
        ];
      case UserRole.coach:
        return [
          const _NavItem(Icons.sports_outlined, 'Equipo', CoachDashboardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.storefront_outlined, 'Mercado', CoachMarketplaceScreen()),
          const _NavItem(Icons.account_balance_wallet_outlined, 'Wallet', WalletScreen()),
        ];
      case UserRole.referee:
        return [
          const _NavItem(Icons.sports_soccer_outlined, 'Terminal', RefereeTerminalScreen()),
          const _NavItem(Icons.history_outlined, 'Historial', ExploreHubScreen()), // Placeholder para Historial
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
        ];
      case UserRole.scout:
        return [
          _NavItem(Icons.person_outline, 'Perfil', FishCardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.search, 'Mercado', ScoutMarketplaceScreen()),
          const _NavItem(Icons.account_balance_wallet_outlined, 'Wallet', WalletScreen()),
        ];
      case UserRole.journalist:
        return [
          const _NavItem(Icons.mic_outlined, 'Studio', JournalistScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.dynamic_feed_outlined, 'Noticias', StadiumFeedScreen()),
        ];
      case UserRole.brand:
        return [
          const _NavItem(Icons.campaign_outlined, 'Campañas', BrandDashboardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.dynamic_feed_outlined, 'Tendencias', StadiumFeedScreen()),
        ];
      case UserRole.fan:
        return [
          const _NavItem(Icons.emoji_events_outlined, 'Predecir', PredictScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
          const _NavItem(Icons.account_balance_wallet_outlined, 'Wallet', WalletScreen()),
        ];
      case UserRole.staff:
        return [
          const _NavItem(Icons.admin_panel_settings_outlined, 'Admin', StaffDashboardScreen()),
          const _NavItem(Icons.explore_outlined, 'Explorar', ExploreHubScreen()),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final items = _items;

    // Clamp index if role changed
    if (_index >= items.length) _index = 0;

    return Scaffold(
      backgroundColor: bg,
      // Cajón lateral (Drawer) para configuraciones (Tema y Salir) y no recargar el Bottom Nav
      endDrawer: Drawer(
        backgroundColor: AppColors.surface(isDark),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Configuración',
                  style: TextStyle(
                    color: AppColors.text(isDark),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(
                  isDark
                      ? Icons.wb_sunny_outlined
                      : Icons.nightlight_round_outlined,
                  color: AppColors.text(isDark),
                ),
                title: Text(
                  isDark ? 'Modo Claro' : 'Modo Oscuro',
                  style: TextStyle(color: AppColors.text(isDark)),
                ),
                onTap: () {
                  ref.read(themeProvider.notifier).toggle();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout_outlined, color: Colors.red),
                title: Text(
                  'Cerrar Sesión',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await UserStorageService.clearSession();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      // Mantenemos el estado usando IndexedStack
      body: Stack(
        children: [
          IndexedStack(
            index: _index,
            children: items.map((e) => e.screen).toList(),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, right: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // El botón QR fue movido a Fish Card Screen
                    if (widget.role != UserRole.player) ...[
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface(isDark).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.settings_outlined, color: AppColors.text(isDark)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: bg,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 12,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final sel = _index == i;
            return GestureDetector(
              onTap: () => setState(() => _index = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      items[i].icon,
                      color: sel
                          ? AppColors.text(isDark)
                          : AppColors.textMuted(isDark),
                      size: sel ? 24 : 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        color: sel
                            ? AppColors.text(isDark)
                            : AppColors.textMuted(isDark),
                        fontSize: 10,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;
  const _NavItem(this.icon, this.label, this.screen);
}


