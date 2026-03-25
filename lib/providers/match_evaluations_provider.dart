import 'package:flutter_riverpod/flutter_riverpod.dart';

enum EvaluationSource { referee, coach, community }

// ── Modelo de evaluación de un partido ───────────────────────────────────────
class MatchEvaluation {
  final String matchId;
  final String matchName; // ej: "Madrid U19 Summer Cup · 03 Mar"
  final String playerId;
  final String playerName;
  final DateTime date;
  final double tecnica;
  final double resistencia;
  final double fairPlay;
  final EvaluationSource source;
  final String signature;

  const MatchEvaluation({
    required this.matchId,
    required this.matchName,
    required this.playerId,
    required this.playerName,
    required this.date,
    required this.tecnica,
    required this.resistencia,
    required this.fairPlay,
    required this.source,
    required this.signature,
  });

  /// Rating del árbitro para este partido (promedio de las 3 dimensiones)
  double get matchRating => (tecnica + resistencia + fairPlay) / 3;

  /// Hacker Feedback: Genera un sello criptográfico simulado basado en los datos
  static String generateSeal(
    String mId,
    String pId,
    double t,
    double r,
    double f,
    EvaluationSource s,
  ) {
    final payload = '$mId|$pId|$t|$r|$f|${s.name}';
    return '0x${payload.hashCode.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }

  /// Verifica si la evaluación ha sido adulterada
  bool get isValid =>
      signature ==
      generateSeal(matchId, playerId, tecnica, resistencia, fairPlay, source);
}

// ── Estado: lista de evaluaciones guardadas ───────────────────────────────────
class MatchEvaluationsNotifier extends Notifier<List<MatchEvaluation>> {
  @override
  List<MatchEvaluation> build() => [
    // Evaluaciones de ejemplo previas (historial mock)
    MatchEvaluation(
      matchId: 'M001',
      matchName: 'Copa Sub-19 · 15 Feb',
      playerId: '1',
      playerName: 'Marco Silva',
      date: DateTime(2026, 2, 15),
      tecnica: 8.5,
      resistencia: 8.0,
      fairPlay: 9.0,
      source: EvaluationSource.referee,
      signature: MatchEvaluation.generateSeal(
        'M001',
        '1',
        8.5,
        8.0,
        9.0,
        EvaluationSource.referee,
      ),
    ),
    MatchEvaluation(
      matchId: 'M002',
      matchName: 'Liga Juvenil · 22 Feb',
      playerId: '1',
      playerName: 'Marco Silva',
      date: DateTime(2026, 2, 22),
      tecnica: 9.5,
      resistencia: 8.5,
      fairPlay: 9.5,
      source: EvaluationSource.referee,
      signature: MatchEvaluation.generateSeal(
        'M002',
        '1',
        9.5,
        8.5,
        9.5,
        EvaluationSource.referee,
      ),
    ),
    MatchEvaluation(
      matchId: 'M003',
      matchName: 'Amistoso Atletico · 28 Feb',
      playerId: '1',
      playerName: 'Marco Silva',
      date: DateTime(2026, 2, 28),
      tecnica: 7.5,
      resistencia: 9.0,
      fairPlay: 8.0,
      source: EvaluationSource.referee,
      signature: MatchEvaluation.generateSeal(
        'M003',
        '1',
        7.5,
        9.0,
        10.0,
        EvaluationSource.referee,
      ),
    ),
  ];

  void addEvaluation(MatchEvaluation eval) {
    state = [eval, ...state]; // más reciente primero
  }
}

final matchEvaluationsProvider =
    NotifierProvider<MatchEvaluationsNotifier, List<MatchEvaluation>>(
      () => MatchEvaluationsNotifier(),
    );

// ── Provider: promedios ponderados por jugador ────────────────────────────────
/// Calcula el promedio ponderado de las evaluaciones de un jugador.
/// Peso decreciente: partido más reciente = mayor peso.
Map<String, double> calcWeightedAverages(List<MatchEvaluation> evals) {
  if (evals.isEmpty) return {};

  final refs = evals
      .where((e) => e.source == EvaluationSource.referee)
      .toList();
  final coaches = evals
      .where((e) => e.source == EvaluationSource.coach)
      .toList();
  final community = evals
      .where((e) => e.source == EvaluationSource.community)
      .toList();

  final refStats = _calcSourceAvg(refs);
  final coachStats = _calcSourceAvg(coaches);
  final commStats = _calcSourceAvg(community);

  // PESOS: Árbitro 60%, Entrenador 20%, Comunidad 20%
  // Si una fuente no tiene datos, su peso se reparte o simplemente se ignora?
  // El usuario dice: "el ponderado contempla Arbitro 60% Entrenador 20% Comunidad 20%"
  // Interpretación: Si falta una fuente, su contribución es 0.0 (jugador empieza en 0).

  return {
    'TEC':
        (refStats['TEC'] ?? 0) * 0.6 +
        (coachStats['TEC'] ?? 0) * 0.2 +
        (commStats['TEC'] ?? 0) * 0.2,
    'RES':
        (refStats['RES'] ?? 0) * 0.6 +
        (coachStats['RES'] ?? 0) * 0.2 +
        (commStats['RES'] ?? 0) * 0.2,
    'FPL':
        (refStats['FPL'] ?? 0) * 0.6 +
        (coachStats['FPL'] ?? 0) * 0.2 +
        (commStats['FPL'] ?? 0) * 0.2,
  };
}

Map<String, double> _calcSourceAvg(List<MatchEvaluation> evals) {
  if (evals.isEmpty) return {};
  final n = evals.length;
  double totalWeight = 0;
  double sumTec = 0, sumRes = 0, sumFP = 0;

  for (int i = 0; i < n; i++) {
    final weight = (n - i).toDouble();
    totalWeight += weight;
    sumTec += evals[i].tecnica * weight;
    sumRes += evals[i].resistencia * weight;
    sumFP += evals[i].fairPlay * weight;
  }
  return {
    'TEC': sumTec / totalWeight,
    'RES': sumRes / totalWeight,
    'FPL': sumFP / totalWeight,
  };
}

final playerWeightedRatingsProvider =
    Provider.family<Map<String, double>, String>((ref, playerId) {
      final evals = ref
          .watch(matchEvaluationsProvider)
          .where((e) => e.playerId == playerId)
          .toList(); // ya ordenado más reciente primero
      return calcWeightedAverages(evals);
    });

// ── Provider: Historial de OVR para Gráficos ──────────────────────────────────
final playerOvrHistoryProvider =
    Provider.family<List<MapEntry<DateTime, double>>, String>((ref, playerId) {
      final evals = ref
          .watch(matchEvaluationsProvider)
          .where((e) => e.playerId == playerId)
          .toList(); // más reciente primero

      if (evals.isEmpty) return [];

      // Revertimos para tener orden cronológico en el gráfico
      final chronological = evals.reversed.toList();
      final history = <MapEntry<DateTime, double>>[];

      // Para cada partido, calculamos el OVR acumulado hasta ese momento (simplificado)
      for (int i = 0; i < chronological.length; i++) {
        final subset = chronological.sublist(0, i + 1);
        // Invertimos el subset para que calcWeightedAverages funcione (espera más reciente primero)
        final stats = calcWeightedAverages(subset.reversed.toList());
        final ovr = ((stats['TEC'] ?? 0) + (stats['RES'] ?? 0) + (stats['FPL'] ?? 0)) / 3;
        
        // Evitamos duplicados de fecha en el mismo día para el gráfico (o tomamos la última)
        history.add(MapEntry(chronological[i].date, ovr));
      }

      return history;
    });
