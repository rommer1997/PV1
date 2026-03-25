import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/match_evaluations_provider.dart';
import '../../providers/players_provider.dart';
import '../../models/app_user.dart';
import '../../widgets/convocatorias_feed.dart';
import '../../widgets/glow_button.dart';
import 'create_convocatoria_screen.dart';

// Eliminado el WatchlistNotifier local, ahora usamos playersProvider

// ── Eliminamos el hardcodeo previo ───────────────────────────────────────────
// allPlayersProvider era una List<Map> fija. Ahora usamos playersProvider.

class ScoutMarketplaceScreen extends ConsumerStatefulWidget {
  const ScoutMarketplaceScreen({super.key});
  @override
  ConsumerState<ScoutMarketplaceScreen> createState() =>
      _ScoutMarketplaceScreenState();
}

enum _ScoutTab { search, watchlist, convocatorias }

class _ScoutMarketplaceScreenState
    extends ConsumerState<ScoutMarketplaceScreen> {
  String _search = '';
  String _posFilter = 'Todos';
  _ScoutTab _tab = _ScoutTab.search;
  double _minRating = 7.0;

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final rawUser = ref.watch(sessionProvider);
    
    // 🔗 SECCIÓN CLAVE: Consumimos la fuente de verdad unificada
    final players = ref.watch(playersProvider);
    final scoutId = rawUser?.id ?? '3'; // Mock si no hay sesión

    if (!(rawUser?.isVerified ?? false)) {
      return _PendingVerificationView(isDark: isDark);
    }

    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    // Filtrado dinámico basado en PlayerData
    final filtered = players.where((p) {
      // 🧮 Obtenemos el rating real del provider de pesajes (Árbitro 60%, etc)
      final ratings = ref.watch(playerWeightedRatingsProvider(p.user.uniqueId));
      final tec = ratings['TEC'] ?? 0.0;
      final res = ratings['RES'] ?? 0.0;
      final fpl = ratings['FPL'] ?? 0.0;
      final avg = (tec + res + fpl) / 3;

      final matchSearch = _search.isEmpty ||
          p.user.name.toLowerCase().contains(_search.toLowerCase());
      final matchPos = _posFilter == 'Todos' || 
          (p.user.position ?? 'ND') == _posFilter ||
          (_posFilter == 'Delantero' && p.user.position == 'DEL') ||
          (_posFilter == 'Centrocampista' && p.user.position == 'MC') ||
          (_posFilter == 'Defensa' && p.user.position == 'DF') ||
          (_posFilter == 'Portero' && p.user.position == 'POR');
      
      final matchRating = avg >= _minRating || avg == 0; // Si es 0 (nuevo), lo mostramos por defecto?
      final onlyValidated = p.user.isVerified;

      return matchSearch && matchPos && matchRating && onlyValidated;
    }).toList();

    final watchlistPlayers = players
        .where((p) => p.scoutWatchlistIds.contains(scoutId))
        .toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCOUT',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Mercado\nde Talentos',
                    style: TextStyle(
                      color: text,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solo estadísticas validadas · Datos de contacto de menores protegidos',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),

            // Tabs: Búsqueda / Watchlist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  _ScoutTabBtn(
                    label: '🔍 Buscar',
                    sel: _tab == _ScoutTab.search,
                    isDark: isDark,
                    onTap: () => setState(() => _tab = _ScoutTab.search),
                  ),
                  const SizedBox(width: 10),
                  _ScoutTabBtn(
                    label: '⭐ Seguimiento (${watchlistPlayers.length})',
                    sel: _tab == _ScoutTab.watchlist,
                    isDark: isDark,
                    onTap: () => setState(() => _tab = _ScoutTab.watchlist),
                  ),
                  const SizedBox(width: 10),
                  _ScoutTabBtn(
                    label: '📢 Convocatorias',
                    sel: _tab == _ScoutTab.convocatorias,
                    isDark: isDark,
                    onTap: () => setState(() => _tab = _ScoutTab.convocatorias),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_tab == _ScoutTab.search) ...[
              // Buscador
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: muted, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: TextStyle(color: text),
                          decoration: InputDecoration.collapsed(
                            hintText: 'Buscar...',
                            hintStyle: TextStyle(color: muted),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children:
                      [
                        'Todos',
                        'Delantero',
                        'Centrocampista',
                        'Defensa',
                        'Portero',
                      ].map((f) {
                        final sel = _posFilter == f;
                        return GestureDetector(
                          onTap: () => setState(() => _posFilter = f),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: sel
                                  ? AppColors.buttonBg(isDark)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: sel
                                    ? AppColors.buttonBg(isDark)
                                    : border,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: sel ? AppColors.buttonFg(isDark) : muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              const SizedBox(height: 8),

              // Rating mínimo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Row(
                  children: [
                    Text(
                      'Rating mín: ${_minRating.toStringAsFixed(1)}',
                      style: TextStyle(color: muted, fontSize: 12),
                    ),
                    Expanded(
                      child: Slider(
                        value: _minRating,
                        min: 6,
                        max: 10,
                        divisions: 8,
                        activeColor: text,
                        inactiveColor: border,
                        onChanged: (v) => setState(() => _minRating = v),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'Sin jugadores validados que coincidan',
                          style: TextStyle(color: muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (ctx, i) => _ScoutPlayerCard(
                          player: filtered[i],
                          isDark: isDark,
                        ),
                      ),
              ),
            ] else if (_tab == _ScoutTab.watchlist) ...[
              // Watchlist
              Expanded(
                child: watchlistPlayers.isEmpty
                    ? Center(
                        child: Text(
                          'Tu watchlist está vacía',
                          style: TextStyle(color: muted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        itemCount: watchlistPlayers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (ctx, i) => _ScoutPlayerCard(
                          player: watchlistPlayers[i],
                          isDark: isDark,
                        ),
                      ),
              ),
            ] else ...[
              // Convocatorias
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                color: muted, size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Como scout verificado puedes publicar convocatorias y retos a jugadores. En desarrollo.',
                                style: TextStyle(
                                    color: muted,
                                    fontSize: 11,
                                    height: 1.4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GlowButton(
                              label: '+ Publicar',
                              selected: true,
                              isDark: isDark,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreateConvocatoriaScreen(),
                                  ),
                                );
                              },
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const ConvocatoriasFeed(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScoutTabBtn extends StatelessWidget {
  final String label;
  final bool sel, isDark;
  final VoidCallback onTap;
  const _ScoutTabBtn({
    required this.label,
    required this.sel,
    required this.isDark,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: sel ? AppColors.buttonBg(isDark) : AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: sel ? AppColors.buttonBg(isDark) : AppColors.border(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel
                ? AppColors.buttonFg(isDark)
                : AppColors.textMuted(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ScoutPlayerCard extends ConsumerStatefulWidget {
  final PlayerData player;
  final bool isDark;
  const _ScoutPlayerCard({required this.player, required this.isDark});
  @override
  ConsumerState<_ScoutPlayerCard> createState() => _ScoutPlayerCardState();
}

class _ScoutPlayerCardState extends ConsumerState<_ScoutPlayerCard> {
  bool _requestSent = false;

  @override
  Widget build(BuildContext context) {
    final pd = widget.player;
    final u = pd.user;
    final isDark = widget.isDark;
    
    final rawUser = ref.watch(sessionProvider);
    final scoutId = rawUser?.id ?? '3';
    final isFav = pd.scoutWatchlistIds.contains(scoutId);

    // 🧮 Rating reactivo del provider global
    final ratings = ref.watch(playerWeightedRatingsProvider(u.uniqueId));
    final tec = ratings['TEC'] ?? 0.0;
    final res = ratings['RES'] ?? 0.0;
    final fpl = ratings['FPL'] ?? 0.0;
    final rtg = (tec + res + fpl) / 3;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isFav
              ? AppColors.text(isDark).withValues(alpha: 0.3)
              : AppColors.border(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg(isDark),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.textMuted(isDark),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          u.name,
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (u.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '${u.position ?? 'ND'} · ${u.ageGroup ?? '18+'} · ${u.location ?? 'España'}',
                          style: TextStyle(
                            color: AppColors.textMuted(isDark),
                            fontSize: 12,
                          ),
                        ),
                        if (u.ovrHistory.length >= 2) ...[
                          const SizedBox(width: 8),
                          _OvrTrendBadge(history: u.ovrHistory),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Watchlist star — Conectada al PlayersProvider
              GestureDetector(
                onTap: () => ref
                    .read(playersProvider.notifier)
                    .toggleWatchlist(u.id, scoutId),
                child: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? Colors.amber : AppColors.textMuted(isDark),
                  size: 24,
                ),
              ),
            ],
          ),

          if (u.isMinor) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.orange,
                    size: 13,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Perfil protegido — menor de edad. Contacto vía Tutor.',
                    style: TextStyle(
                      color: Colors.orange.withValues(alpha: 0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Stats — solo validadas, inmutables
          Row(
            children: [
              _StatChip(
                label: 'TEC',
                value: tec.toStringAsFixed(1),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'RES',
                value: res.toStringAsFixed(1),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'RTG',
                value: rtg.toStringAsFixed(1),
                isDark: isDark,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(isDark)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 10,
                      color: AppColors.textMuted(isDark),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      u.uniqueId,
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 10,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Acciones — scout NO tiene chat directo
          Row(
            children: [
              Expanded(
                child: GlowButton(
                  label: 'Generar Informe Técnico',
                  selected: false,
                  isDark: isDark,
                  onTap: () => _showScoutingReportDialog(context, ref, isDark),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: _requestSent
                      ? null
                      : () {
                          setState(() => _requestSent = true);
                          ref.read(playersProvider.notifier).addOffer(u.id, {
                            'type': 'Interest',
                            'scoutId': scoutId,
                            'date': DateTime.now().toIso8601String(),
                          });
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 42,
                    decoration: BoxDecoration(
                      color: _requestSent
                          ? AppColors.surface(isDark)
                          : AppColors.buttonBg(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: _requestSent
                          ? Border.all(color: AppColors.border(isDark))
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _requestSent
                          ? 'Enviada ✓'
                          : 'Solicitud Interés',
                      style: TextStyle(
                        color: _requestSent
                            ? AppColors.textMuted(isDark)
                            : AppColors.buttonFg(isDark),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScoutingReportDialog(BuildContext context, WidgetRef ref, bool isDark) {
    final pd = widget.player;
    double tec = 8.0, pot = 8.0;
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface(isDark),
          title: Text('Informe: ${pd.user.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ReportSlider(
                  label: 'Técnica Observada',
                  value: tec,
                  onChanged: (v) => setState(() => tec = v),
                  isDark: isDark,
                ),
                _ReportSlider(
                  label: 'Potencial Proyectado',
                  value: pot,
                  onChanged: (v) => setState(() => pot = v),
                  isDark: isDark,
                ),
                TextField(
                  controller: ctrl,
                  maxLines: 3,
                  style: TextStyle(color: AppColors.text(isDark)),
                  decoration: InputDecoration(
                    hintText: 'Observaciones tácticas...',
                    hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: AppColors.textMuted(isDark))),
            ),
            ElevatedButton(
              onPressed: () {
                final report = {
                  'scoutId': '3',
                  'date': DateTime.now().toIso8601String(),
                  'tecnica': tec,
                  'potencial': pot,
                  'observaciones': ctrl.text,
                };
                ref.read(playersProvider.notifier).addScoutingReport(pd.user.id, report);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Informe técnico guardado en el CV del jugador')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg(isDark),
                foregroundColor: AppColors.buttonFg(isDark),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const _ReportSlider({required this.label, required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.text(isDark), fontSize: 13)),
            Text(value.toStringAsFixed(1), style: const TextStyle(color: Color(0xFFE2F163), fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 100,
          activeColor: const Color(0xFFE2F163),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _StatChip({
    required this.label,
    required this.value,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 3),
            Icon(
              Icons.lock_outline,
              size: 9,
              color: AppColors.textMuted(isDark),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PendingVerificationView extends StatelessWidget {
  final bool isDark;
  const _PendingVerificationView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 80, color: text.withValues(alpha: 0.2)),
                const SizedBox(height: 24),
                Text(
                  'Verificación\nEn Proceso',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: text,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tu cuenta está en revisión por el departamento legal para acreditar tu afiliación institucional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'M-Search estará disponible en cuanto el Staff valide tus credenciales KYC.',
                          style: TextStyle(color: text, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OvrTrendBadge extends StatelessWidget {
  final Map<String, double> history;
  const _OvrTrendBadge({required this.history});

  @override
  Widget build(BuildContext context) {
    // Clasificar por fecha y ver si el último es mayor al anterior
    final sortedKeys = history.keys.toList()..sort();
    if (sortedKeys.length < 2) return const SizedBox.shrink();
    
    final last = history[sortedKeys.last]!;
    final prev = history[sortedKeys[sortedKeys.length - 2]]!;
    
    if (last > prev) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.trending_up, color: Colors.green, size: 10),
            SizedBox(width: 2),
            Text(
              'UP',
              style: TextStyle(color: Colors.green, fontSize: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
