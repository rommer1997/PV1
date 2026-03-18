import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class _MvpCandidate {
  final String name, id, position;
  final double rating;
  int votes;
  bool picked = false;
  _MvpCandidate({
    required this.name,
    required this.id,
    required this.position,
    required this.rating,
    this.votes = 0,
  });
}

class PredictScreen extends ConsumerStatefulWidget {
  const PredictScreen({super.key});
  @override
  ConsumerState<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends ConsumerState<PredictScreen>
    with TickerProviderStateMixin {
  late TabController _tab;

  final _candidates = [
    _MvpCandidate(
      name: 'Marco Silva',
      id: 'SLP-0982',
      position: 'Delantero',
      rating: 9.2,
      votes: 142,
    ),
    _MvpCandidate(
      name: 'Luis Peña',
      id: 'SLP-1102',
      position: 'Centrocampista',
      rating: 8.6,
      votes: 87,
    ),
    _MvpCandidate(
      name: 'Adrián Torres',
      id: 'SLP-1341',
      position: 'Defensa',
      rating: 8.1,
      votes: 53,
    ),
  ];
  String? _mvpVote;
  int _sc = 50;
  bool _predictLocked = false;
  double _predictedRating = 8.0;
  double? _predictResult;
  bool _resultRevealed = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  int get _totalVotes => _candidates.fold(0, (sum, c) => sum + c.votes);

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FAN',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Comunidad &\nRecompensas',
                    style: TextStyle(
                      color: text,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // SportCoins del fan
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.monetization_on_outlined,
                          color: text,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$_sc SC',
                          style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SportCoins',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 28),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                  color: AppColors.buttonBg(isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: AppColors.buttonFg(isDark),
                unselectedLabelColor: muted,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: '🏆 Votar MVP'),
                  Tab(text: '🎯 Predecir'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  // ── MVP VOTE (validación social 20%) ──────────────────────
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Text(
                          'Tu voto forma parte del 20% de Validación Social del Algoritmo Triple. ¡Tu opinión tiene peso real en el Athletic-CV del jugador!',
                          style: TextStyle(
                            color: muted,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._candidates.map((c) {
                        final pct = _totalVotes > 0
                            ? (c.votes / _totalVotes)
                            : 0.0;
                        final picked = _mvpVote == c.id;
                        return GestureDetector(
                          onTap: _mvpVote != null
                              ? null
                              : () {
                                  setState(() {
                                    _mvpVote = c.id;
                                    c.votes += 1;
                                    c.picked = true;
                                    _sc += 10; // +10 SC por participar
                                  });
                                },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: picked ? text.withValues(alpha: 0.5) : border,
                                width: picked ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            c.name,
                                            style: TextStyle(
                                              color: text,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${c.position} · ${c.rating} rating cert.',
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (_mvpVote != null)
                                      Text(
                                        '${(pct * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(
                                          color: text,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    if (picked) ...[
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.check_circle,
                                        color: text,
                                        size: 22,
                                      ),
                                    ],
                                  ],
                                ),
                                if (_mvpVote != null) ...[
                                  const SizedBox(height: 10),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: pct,
                                      minHeight: 6,
                                      backgroundColor: border,
                                      valueColor: AlwaysStoppedAnimation(text),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                      if (_mvpVote != null) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: Text(
                            '+10 SC recibidos por votar 🎉',
                            style: TextStyle(color: muted, fontSize: 13),
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),

                  // ── PREDICT TO EARN ───────────────────────────────────────
                  ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SIGUIENTE PARTIDO',
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Atletico Juvenil A vs Madrid B · Semifinal',
                              style: TextStyle(
                                color: text,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '6 Mar 2026 · 18:00 · Campo Norte',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '¿A qué puntuación llegará Marco Silva?',
                        style: TextStyle(
                          color: text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Predice el rating que certificará el árbitro (0–10)',
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                      const SizedBox(height: 24),
                      // Slider de predicción
                      if (!_predictLocked) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tu predicción:',
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                            Text(
                              _predictedRating.toStringAsFixed(1),
                              style: TextStyle(
                                color: text,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: _predictedRating,
                          min: 5,
                          max: 10,
                          divisions: 20,
                          activeColor: text,
                          inactiveColor: border,
                          onChanged: (v) =>
                              setState(() => _predictedRating = v),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Apuesta',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '20 SC',
                                    style: TextStyle(
                                      color: text,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Premio si aciertas',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    '60 SC',
                                    style: TextStyle(
                                      color: text,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        GestureDetector(
                          onTap: () => setState(() {
                            _predictLocked = true;
                            _sc -= 20;
                          }),
                          child: Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.buttonBg(isDark),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'BLOQUEAR PREDICCIÓN · -20 SC',
                              style: TextStyle(
                                color: AppColors.buttonFg(isDark),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: border),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'TU PREDICCIÓN',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 10,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _predictedRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: text,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Bloqueada · esperando acta del árbitro',
                                style: TextStyle(color: muted, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (!_resultRevealed)
                          GestureDetector(
                            onTap: () => setState(() {
                              _resultRevealed = true;
                              _predictResult = 8.8;
                              final diff = (_predictedRating - _predictResult!)
                                  .abs();
                              if (diff <= 0.5) _sc += 60;
                            }),
                            child: Container(
                              height: 56,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppColors.border(isDark),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'VER RESULTADO (DEMO)',
                                style: TextStyle(color: muted, fontSize: 13),
                              ),
                            ),
                          ),
                        if (_resultRevealed) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: border),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'ACTA DEL ÁRBITRO',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 10,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _predictResult!.toStringAsFixed(1),
                                  style: TextStyle(
                                    color: text,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  (_predictedRating - _predictResult!).abs() <=
                                          0.5
                                      ? '¡Predicción acertada! +60 SC 🎉'
                                      : 'Tu predicción: ${_predictedRating.toStringAsFixed(1)} — Diferencia: ${(_predictedRating - _predictResult!).abs().toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color:
                                        (_predictedRating - _predictResult!)
                                                .abs() <=
                                            0.5
                                        ? Colors.green
                                        : muted,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 48),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
