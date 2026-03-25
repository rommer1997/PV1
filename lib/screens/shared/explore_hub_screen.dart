import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/once_semana_widget.dart';
import '../../widgets/convocatorias_feed.dart';
import 'global_search_screen.dart';
import 'agenda_screen.dart';
import '../matches/match_discovery_screen.dart';
import 'sportlink_ai_screen.dart';
import '../scout/scout_dashboard_screen.dart';

class ExploreHubScreen extends ConsumerWidget {
  const ExploreHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final primary = AppColors.buttonBg(isDark);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: surface,
          elevation: 0,
          title: Text(
            'Explorar',
            style: TextStyle(
              color: text,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: primary,
            labelColor: text,
            unselectedLabelColor: muted,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.search), text: 'Descubrir'),
              Tab(icon: Icon(Icons.sports_soccer), text: 'Partidos'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Agenda'),
              Tab(icon: Icon(Icons.star_outline), text: 'Favoritos'),
              Tab(icon: Icon(Icons.emoji_events_rounded), text: 'Once'),
              Tab(icon: Icon(Icons.campaign_rounded), text: 'Oportunidades'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            const GlobalSearchScreen(),
            const MatchDiscoveryScreen(),
            const AgendaScreen(),
            const ScoutDashboardScreen(),
            // ── Once de la Semana ────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: const OnceSemanaWidget(),
            ),
            // ── Convocatorias y Oportunidades ────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: const ConvocatoriasFeed(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SportLinkAIScreen()),
            );
          },
          backgroundColor: const Color(0xFFE2F163),
          icon: const Icon(Icons.smart_toy_outlined, color: Colors.black),
          label: const Text(
            'Scout AI',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
