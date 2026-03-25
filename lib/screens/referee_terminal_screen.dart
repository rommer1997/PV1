import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/match_evaluations_provider.dart';
import '../providers/players_provider.dart';
import '../widgets/help_button.dart';
import 'dart:async';

// ── Mock Offline Mode Providers ────────────────────────────────────────────────
class ConnectivityNotifier extends Notifier<bool> {
  @override
  bool build() => true;
  void toggle() {
    state = !state;
  }
}
final connectivityProvider = NotifierProvider<ConnectivityNotifier, bool>(() => ConnectivityNotifier());

class OfflineQueueNotifier extends Notifier<List<MatchEvaluation>> {
  @override
  List<MatchEvaluation> build() => [];
  void queue(MatchEvaluation eval) => state = [...state, eval];
  void clear() => state = [];
}
final offlineQueueProvider = NotifierProvider<OfflineQueueNotifier, List<MatchEvaluation>>(() => OfflineQueueNotifier());

class RefereeTerminalScreen extends ConsumerStatefulWidget {
  final String? matchId;
  final String? matchName;
  final String? playerId;
  final String? playerName;

  const RefereeTerminalScreen({
    super.key,
    this.matchId,
    this.matchName,
    this.playerId,
    this.playerName,
  });

  @override
  ConsumerState<RefereeTerminalScreen> createState() =>
      _RefereeTerminalScreenState();
}

class _RefereeTerminalScreenState extends ConsumerState<RefereeTerminalScreen> {
  double _tecnica = 5.0;
  double _resistencia = 5.0;
  double _fairPlay = 5.0;
  bool _isSealed = false;

  late String _matchName = widget.matchName ?? 'Madrid U19 Summer Cup';
  late String _playerId = widget.playerId ?? 'SLP-0982';
  late String _playerName = widget.playerName ?? 'Marco Silva';
  String _playerPos = 'ND';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    // Buscamos el jugador en el provider global para tener datos frescos (como la posición)
    final allPlayers = ref.watch(playersProvider);
    final pd = allPlayers.any((p) => p.user.uniqueId == _playerId || p.user.id == _playerId)
        ? allPlayers.firstWhere((p) => p.user.uniqueId == _playerId || p.user.id == _playerId)
        : null;
    
    if (pd != null) {
      _playerName = pd.user.name;
      _playerPos = pd.user.position ?? 'ND';
    }

    final evals = ref
        .watch(matchEvaluationsProvider)
        .where((e) => e.playerId == _playerId || (pd != null && e.playerId == pd.user.id))
        .toList();

    final weighted = calcWeightedAverages(evals);
    final refAvg = weighted.isEmpty
        ? null
        : weighted.values.reduce((a, b) => a + b) / weighted.length;
        
    final isOnline = ref.watch(connectivityProvider);
    final offlineQueue = ref.watch(offlineQueueProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Banner Offline / Toggle Network ──
              GestureDetector(
                onTap: () {
                  final notifier = ref.read(connectivityProvider.notifier);
                  notifier.toggle();
                  if (!isOnline && offlineQueue.isNotEmpty) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Sincronizando Evaluaciones Offline... ⏳')),
                     );
                     Future.delayed(const Duration(seconds: 2), () {
                        for (var e in offlineQueue) {
                          ref.read(matchEvaluationsProvider.notifier).addEvaluation(e);
                        }
                        ref.read(offlineQueueProvider.notifier).clear();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('✓ Sincronización Completada!')),
                          );
                        }
                     });
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isOnline ? Colors.green.withValues(alpha: 0.3) : Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isOnline ? Icons.wifi : Icons.wifi_off, size: 16, color: isOnline ? Colors.green : Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        isOnline ? 'Online' : 'Modo Offline',
                        style: TextStyle(color: isOnline ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ÁRBITRO',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const HelpButton(screenKey: 'referee_terminal'),
                ],
              ),
              const SizedBox(height: 24),

              // 🪪 Credencial Digital
              _RefereeCredentialCard(
                name: 'Carlos Rodríguez',
                id: 'COLEGIADO REF-28-0912',
                isDark: isDark,
              ),

              const SizedBox(height: 32),
              const SizedBox(height: 12),
              Text(
                'Evaluar\nJugador',
                style: TextStyle(
                  color: text,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(_matchName, style: TextStyle(color: muted, fontSize: 13)),

              const SizedBox(height: 24),

              // Historial de evaluaciones
              if (evals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTORIAL RECIENTE',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (refAvg != null)
                      Text(
                        'Promedio: ${refAvg.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: _ratingColor(refAvg),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: evals.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) => _MatchHistoryMiniCard(eval: evals[i], isDark: isDark),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Tarjeta del jugador a evaluar con selector
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bg,
                            border: Border.all(color: border),
                          ),
                          child: Icon(Icons.sports_soccer, color: muted, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _playerName,
                                style: TextStyle(
                                  color: text,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: $_playerId · $_playerPos',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showSearchDialog(context, allPlayers, isDark),
                          icon: Icon(Icons.search, color: AppColors.accent),
                          tooltip: 'Cambiar Jugador',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Sliders de evaluación
              Text(
                'EVALUACIÓN DE CAMPO',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildSlider(
                'Técnica',
                _tecnica,
                muted,
                text,
                border,
                (v) => setState(() => _tecnica = v),
              ),
              const SizedBox(height: 28),
              _buildSlider(
                'Resistencia',
                _resistencia,
                muted,
                text,
                border,
                (v) => setState(() => _resistencia = v),
              ),
              const SizedBox(height: 28),
              _buildSlider(
                'Fair Play',
                _fairPlay,
                muted,
                text,
                border,
                (v) => setState(() => _fairPlay = v),
              ),

              const SizedBox(height: 24),

              // Rating calculado
              Center(
                child: Column(
                  children: [
                    Text(
                      'RATING PARTIDO',
                      style: TextStyle(
                        color: muted,
                        fontSize: 9,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ((_tecnica + _resistencia + _fairPlay) / 3)
                          .toStringAsFixed(1),
                      style: TextStyle(
                        color: _ratingColor(
                          (_tecnica + _resistencia + _fairPlay) / 3,
                        ),
                        fontSize: 52,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Botón sellar
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _isSealed ? null : () => _seal(context),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    height: 60,
                    decoration: BoxDecoration(
                      color: _isSealed ? surface : AppColors.buttonBg(isDark),
                      borderRadius: BorderRadius.circular(30),
                      border: _isSealed ? Border.all(color: border) : null,
                    ),
                    alignment: Alignment.center,
                    child: _isSealed
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_outline, size: 16, color: muted),
                              const SizedBox(width: 8),
                              const Text(
                                'EVALUACIÓN SELLADA',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'SELLAR EVALUACIÓN',
                            style: TextStyle(
                              color: AppColors.buttonFg(isDark),
                              fontSize: 15,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  _isSealed
                      ? 'Inmutable · Sincronizado con SportLink Core'
                      : 'El rating afectará permanentemente al Athletic-CV',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, List<PlayerData> players, bool isDark) {
    final ctrl = TextEditingController();
    List<PlayerData> filtered = players;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface(isDark),
          title: const Text('Buscar Jugador', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: ctrl,
                style: TextStyle(color: AppColors.text(isDark)),
                decoration: InputDecoration(
                  hintText: 'Nombre o ID...',
                  prefixIcon: Icon(Icons.search, color: AppColors.textMuted(isDark)),
                ),
                onChanged: (v) {
                  setState(() {
                    filtered = players.where((p) => 
                      p.user.name.toLowerCase().contains(v.toLowerCase()) || 
                      p.user.uniqueId.toLowerCase().contains(v.toLowerCase())
                    ).toList();
                  });
                },
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final p = filtered[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.bg(isDark),
                        child: Text(p.user.name[0]),
                      ),
                      title: Text(p.user.name, style: TextStyle(color: AppColors.text(isDark))),
                      subtitle: Text(p.user.uniqueId, style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11)),
                      onTap: () {
                        this.setState(() {
                          _playerId = p.user.uniqueId;
                          _playerName = p.user.name;
                          _playerPos = p.user.position ?? 'ND';
                          _isSealed = false; // Reset seal for new player
                        });
                        Navigator.pop(ctx);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Color muted,
    Color text,
    Color border,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(color: _ratingColor(value), fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _ratingColor(value),
            inactiveTrackColor: border,
            thumbColor: _ratingColor(value),
            trackHeight: 2.5,
          ),
          child: Slider(
            value: value,
            min: 0, max: 10, divisions: 20,
            onChanged: _isSealed ? null : onChanged,
          ),
        ),
      ],
    );
  }

  Color _ratingColor(double v) {
    if (v >= 8.5) return const Color(0xFF34C759);
    if (v >= 7.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF3B30);
  }

  void _seal(BuildContext context) {
    setState(() => _isSealed = true);
    final mId = 'M${DateTime.now().millisecondsSinceEpoch}';
    final eval = MatchEvaluation(
      matchId: mId,
      matchName: _matchName,
      playerId: _playerId,
      playerName: _playerName,
      date: DateTime.now(),
      tecnica: _tecnica,
      resistencia: _resistencia,
      fairPlay: _fairPlay,
      source: EvaluationSource.referee,
      signature: MatchEvaluation.generateSeal(mId, _playerId, _tecnica, _resistencia, _fairPlay, EvaluationSource.referee),
    );
    
    if (ref.read(connectivityProvider)) {
      ref.read(matchEvaluationsProvider.notifier).addEvaluation(eval);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✓ Evaluación sincronizada con SportLink Core')));
    } else {
      ref.read(offlineQueueProvider.notifier).queue(eval);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Guardado localmente (Sin conexión)')));
    }
  }
}

class _MatchHistoryMiniCard extends StatelessWidget {
  final MatchEvaluation eval;
  final bool isDark;
  const _MatchHistoryMiniCard({required this.eval, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final rating = eval.matchRating;

    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(eval.matchName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: rating >= 8.5 ? const Color(0xFF34C759) : (rating >= 7 ? const Color(0xFFFF9F0A) : const Color(0xFFFF3B30)),
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              '${eval.date.day}/${eval.date.month}',
              style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 9),
            ),
          ),
        ],
      ),
    );
  }
}
class _RefereeCredentialCard extends StatelessWidget {
  final String name, id;
  final bool isDark;

  const _RefereeCredentialCard({required this.name, required this.id, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [surface, surface.withValues(alpha: 0.8)] 
            : [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name.toUpperCase(),
                        style: TextStyle(
                          color: text,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.verified, color: Colors.blue, size: 16),
                    ],
                  ),
                  Text(
                    id,
                    style: TextStyle(
                      color: AppColors.buttonBg(isDark),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Icon(Icons.sports, color: text.withValues(alpha: 0.2), size: 40),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RefStat(label: 'PARTIDOS', value: '142', isDark: isDark),
              _RefStat(label: 'RATING DADO', value: '7.8', isDark: isDark),
              _RefStat(label: 'COLEGIADO', value: 'MAD', isDark: isDark),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: text.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code, size: 14, color: muted),
                const SizedBox(width: 8),
                Text(
                  'ID DIGITAL VERIFICADO',
                  style: TextStyle(color: muted, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RefStat extends StatelessWidget {
  final String label, value;
  final bool isDark;
  const _RefStat({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted(isDark),
            fontSize: 9,
            letterSpacing: 1,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
