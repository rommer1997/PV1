import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/match_evaluations_provider.dart';
import '../../models/app_user.dart';

// Watchlist notification (mock)
class WatchlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void toggle(String id) => state.contains(id)
      ? state = state.where((x) => x != id).toList()
      : state = [...state, id];
}

final watchlistProvider = NotifierProvider<WatchlistNotifier, List<String>>(
  () => WatchlistNotifier(),
);

final allPlayersProvider = Provider<List<Map<String, dynamic>>>((ref) {
  // Obtenemos las verdaderas evaluaciones de Marco Silva ('p1')
  final marcoRatings = ref.watch(playerWeightedRatingsProvider('SLP-0982'));
  final marcoTec = marcoRatings['TEC'] ?? 8.5;
  final marcoSpeed = 9.0; // Simulada (viene de entrenador)
  final marcoOverall =
      (marcoTec + marcoRatings['RES']! + marcoRatings['FPL']! + marcoSpeed) / 4;

  return [
    {
      'name': 'Marco Silva',
      'id': 'SLP-0982',
      'pos': 'Delantero',
      'age': 17,
      'city': 'Madrid',
      'speed': double.parse(marcoSpeed.toStringAsFixed(1)),
      'tech': double.parse(marcoTec.toStringAsFixed(1)),
      'rating': double.parse(marcoOverall.toStringAsFixed(1)),
      'isMinor': true,
      'validated': true,
    },
    {
      'name': 'Luis Peña',
      'id': 'SLP-1102',
      'pos': 'Centrocampista',
      'age': 19,
      'city': 'Madrid',
      'speed': 8.2,
      'tech': 9.1,
      'rating': 8.6,
      'isMinor': false,
      'validated': true,
    },
    {
      'name': 'Adrián Torres',
      'id': 'SLP-1341',
      'pos': 'Defensa',
      'age': 18,
      'city': 'Barcelona',
      'speed': 7.8,
      'tech': 8.0,
      'rating': 7.9,
      'isMinor': false,
      'validated': true,
    },
    {
      'name': 'Jorge Ruiz',
      'id': 'SLP-1218',
      'pos': 'Delantero',
      'age': 20,
      'city': 'Sevilla',
      'speed': 8.9,
      'tech': 8.3,
      'rating': 8.5,
      'isMinor': false,
      'validated': false,
    },
  ];
});

class ScoutMarketplaceScreen extends ConsumerStatefulWidget {
  const ScoutMarketplaceScreen({super.key});
  @override
  ConsumerState<ScoutMarketplaceScreen> createState() =>
      _ScoutMarketplaceScreenState();
}

enum _ScoutTab { search, watchlist }

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
    final all = ref.watch(allPlayersProvider);
    final watchlist = ref.watch(watchlistProvider);

    if (!(rawUser?.isVerified ?? false)) {
      return _PendingVerificationView(isDark: isDark);
    }

    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    final filtered = all.where((p) {
      final matchSearch =
          _search.isEmpty ||
          (p['name'] as String).toLowerCase().contains(_search.toLowerCase());
      final matchPos = _posFilter == 'Todos' || p['pos'] == _posFilter;
      final matchRating = (p['rating'] as double) >= _minRating;
      final onlyValidated = (p['validated'] as bool);
      return matchSearch && matchPos && matchRating && onlyValidated;
    }).toList();

    final watchlistPlayers = all
        .where((p) => watchlist.contains(p['id']))
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
                    label: '⭐ Watchlist (${watchlist.length})',
                    sel: _tab == _ScoutTab.watchlist,
                    isDark: isDark,
                    onTap: () => setState(() => _tab = _ScoutTab.watchlist),
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
            ] else ...[
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
  final Map<String, dynamic> player;
  final bool isDark;
  const _ScoutPlayerCard({required this.player, required this.isDark});
  @override
  ConsumerState<_ScoutPlayerCard> createState() => _ScoutPlayerCardState();
}

class _ScoutPlayerCardState extends ConsumerState<_ScoutPlayerCard> {
  bool _requestSent = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.player;
    final isDark = widget.isDark;
    final isMinor = p['isMinor'] as bool;
    final watchlist = ref.watch(watchlistProvider);
    final isFav = watchlist.contains(p['id']);

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
                          p['name'],
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (p['validated'] == true) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified,
                            color: Colors.blue,
                            size: 14,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${p['pos']} · ${p['age']} años · ${p['city']}',
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Watchlist star
              GestureDetector(
                onTap: () => ref
                    .read(watchlistProvider.notifier)
                    .toggle(p['id'] as String),
                child: Icon(
                  isFav ? Icons.star : Icons.star_border,
                  color: isFav ? Colors.amber : AppColors.textMuted(isDark),
                  size: 24,
                ),
              ),
            ],
          ),

          // PRIVACY: menores ocultan datos de contacto para scouts
          if (isMinor) ...[
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
                label: 'VEL',
                value: p['speed'].toString(),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'TEC',
                value: p['tech'].toString(),
                isDark: isDark,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: 'RTG',
                value: p['rating'].toString(),
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
                      p['id'],
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
              // Solicitud de interés (pasa por tutor/entrenador)
              Expanded(
                child: GestureDetector(
                  onTap: _requestSent
                      ? null
                      : () => setState(() => _requestSent = true),
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
                          ? 'Solicitud Enviada al Tutor ✓'
                          : 'Solicitud de Interés',
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
