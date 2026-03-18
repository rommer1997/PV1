import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../providers/match_evaluations_provider.dart';
import '../models/app_user.dart';
import '../widgets/help_button.dart';

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

  late final String _matchName = widget.matchName ?? 'Madrid U19 Summer Cup · 03 Mar';
  late final String _playerId = widget.playerId ?? 'SLP-0982';
  late final String _playerName = widget.playerName ?? 'Marco Silva';
  final String _playerPos = 'ND';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    final evals = ref
        .watch(matchEvaluationsProvider)
        .where((e) => e.playerId == _playerId)
        .toList();
    final weighted = calcWeightedAverages(evals);
    final refAvg = weighted.isEmpty
        ? null
        : weighted.values.reduce((a, b) => a + b) / weighted.length;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 12),
              Text(
                'Verificar\nPartido',
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
              const SizedBox(height: 4),
              Consumer(
                builder: (_, ref2, _) {
                  final referee = ref2.watch(sessionProvider);
                  return Text(
                    '${referee?.followersCount ?? 0} seguidores te observan',
                    style: TextStyle(color: muted, fontSize: 11),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Historial de partidos del jugador
              if (evals.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTORIAL DE EVALUACIONES',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (refAvg != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _ratingColor(refAvg).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Prom. árbitro: ${refAvg.toStringAsFixed(1)}',
                          style: TextStyle(
                            color: _ratingColor(refAvg),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                ...evals.map((e) => _MatchHistoryCard(eval: e, isDark: isDark)),
                const SizedBox(height: 24),
              ],

              // Tarjeta del jugador a evaluar
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Row(
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
                    Column(
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
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Sliders de evaluación
              Text(
                'EVALUACIÓN — ESTE PARTIDO',
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

              // Rating calculado en tiempo real
              Center(
                child: Column(
                  children: [
                    Text(
                      'RATING ESTE PARTIDO',
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
                    if (evals.isNotEmpty && refAvg != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Nuevo promedio estimado: ${_newAvgPreview(evals, refAvg).toStringAsFixed(1)}',
                        style: TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
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
                              Text(
                                'EVALUACIÓN INMUTABLE',
                                style: TextStyle(
                                  color: muted,
                                  fontSize: 13,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'SELLAR Y REGISTRAR',
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
                      ? 'Evaluación registrada · Afecta al Athletic-CV del jugador'
                      : '1 SC = €0.0092 · Rating afectará al Athletic-CV',
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
            Text(
              label,
              style: TextStyle(
                color: muted,
                fontSize: 13,
                letterSpacing: 1,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: _ratingColor(value),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _ratingColor(value),
            inactiveTrackColor: border,
            thumbColor: _ratingColor(value),
            overlayColor: _ratingColor(value).withValues(alpha: 0.1),
            trackHeight: 2.5,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 10,
            divisions: 20,
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

  double _newAvgPreview(List<MatchEvaluation> evals, double currentAvg) {
    // Simula cómo quedaría el promedio si se añade esta evaluación
    final thisRating = (_tecnica + _resistencia + _fairPlay) / 3;
    final n = evals.length + 1;
    // Peso del nuevo partido = n (el más reciente), los anteriores bajan un peso
    double total = 0, sumW = 0;
    for (int i = 0; i < evals.length; i++) {
      final w = (n - 1 - i).toDouble();
      sumW += w;
      total += evals[i].matchRating * w;
    }
    sumW += n.toDouble();
    total += thisRating * n;
    return total / sumW;
  }

  void _seal(BuildContext context) {
    setState(() => _isSealed = true);

    final mId = widget.matchId ?? 'M${DateTime.now().millisecondsSinceEpoch}';
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
      signature: MatchEvaluation.generateSeal(
        mId,
        _playerId,
        _tecnica,
        _resistencia,
        _fairPlay,
        EvaluationSource.referee,
      ),
    );
    ref.read(matchEvaluationsProvider.notifier).addEvaluation(eval);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✓ Evaluación sellada · Rating: ${eval.matchRating.toStringAsFixed(1)} · Athletic-CV actualizado',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Tarjeta de historial de partidos ─────────────────────────────────────────
class _MatchHistoryCard extends StatelessWidget {
  final MatchEvaluation eval;
  final bool isDark;
  const _MatchHistoryCard({required this.eval, required this.isDark});

  Color _c(double v) {
    if (v >= 8.5) return const Color(0xFF34C759);
    if (v >= 7.0) return const Color(0xFFFF9F0A);
    return const Color(0xFFFF3B30);
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final rating = eval.matchRating;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eval.matchName,
                  style: TextStyle(
                    color: text,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'TEC ${eval.tecnica} · RES ${eval.resistencia} · FPL ${eval.fairPlay}',
                  style: TextStyle(
                    color: muted,
                    fontSize: 10,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _c(rating).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              rating.toStringAsFixed(1),
              style: TextStyle(
                color: _c(rating),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
