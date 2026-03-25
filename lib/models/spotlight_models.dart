// ──────────────────────────────────────────────────────────────────────────────
// spotlight_models.dart
// Modelos originales de SportLink Pro para las nuevas funcionalidades
// sociales/profesionales: Endorsements, Convocatorias, Once de la Semana.
// ──────────────────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Habilidades endorsables ───────────────────────────────────────────────────
enum SkillTag {
  regate,
  velocidad,
  finalizacion,
  defensa,
  liderazgo,
  vision,
  remate,
  pase,
}

extension SkillTagLabel on SkillTag {
  String get label {
    switch (this) {
      case SkillTag.regate:     return 'Regate';
      case SkillTag.velocidad:  return 'Velocidad';
      case SkillTag.finalizacion: return 'Finalización';
      case SkillTag.defensa:    return 'Defensa';
      case SkillTag.liderazgo:  return 'Liderazgo';
      case SkillTag.vision:     return 'Visión';
      case SkillTag.remate:     return 'Remate';
      case SkillTag.pase:       return 'Pase';
    }
  }

  String get emoji {
    switch (this) {
      case SkillTag.regate:     return '⚡';
      case SkillTag.velocidad:  return '💨';
      case SkillTag.finalizacion: return '🎯';
      case SkillTag.defensa:    return '🛡';
      case SkillTag.liderazgo:  return '👑';
      case SkillTag.vision:     return '👁';
      case SkillTag.remate:     return '💥';
      case SkillTag.pase:       return '🎶';
    }
  }
}

// ── Endorsement recibido por un jugador ─────────────────────────────────────
class Endorsement {
  final String fromUserId;
  final String fromUserName;
  final SkillTag skill;
  final DateTime createdAt;

  const Endorsement({
    required this.fromUserId,
    required this.fromUserName,
    required this.skill,
    required this.createdAt,
  });
}

// ── Convocatoria publicada por scout/entrenador ────────────────────────────
enum ConvocatoriaType { abierta, reto }

class Convocatoria {
  final String id;
  final String scoutId;
  final String scoutName;
  final String organizacion;
  final String titulo;
  final String descripcion;
  final ConvocatoriaType tipo;
  final String posicion;
  final String region;
  final int edadMax;
  final DateTime fechaLimite;
  final bool requiereVideo;
  int candidatos;

  Convocatoria({
    required this.id,
    required this.scoutId,
    required this.scoutName,
    required this.organizacion,
    required this.titulo,
    required this.descripcion,
    required this.tipo,
    required this.posicion,
    required this.region,
    required this.edadMax,
    required this.fechaLimite,
    required this.requiereVideo,
    this.candidatos = 0,
  });
}

// ── Once de la Semana ─────────────────────────────────────────────────────
class OnceSemanEntry {
  final String playerId;
  final String playerName;
  final String posicion;
  final String region;
  final double rating;
  final int totalEndorsements;
  final int mvpVotes;
  final int weekNumber;

  const OnceSemanEntry({
    required this.playerId,
    required this.playerName,
    required this.posicion,
    required this.region,
    required this.rating,
    required this.totalEndorsements,
    required this.mvpVotes,
    required this.weekNumber,
  });
}

// ── Visita de perfil ────────────────────────────────────────────────────────
class ProfileVisit {
  final String visitorId;
  final String visitorName;
  final String visitorRole;   // "Scout", "Entrenador", "Periodista"
  final String? organizacion;
  final DateTime visitedAt;

  const ProfileVisit({
    required this.visitorId,
    required this.visitorName,
    required this.visitorRole,
    this.organizacion,
    required this.visitedAt,
  });
}

// ── Providers de estado (mock sincrónico, sin backend) ──────────────────────

// Endorsements del jugador actual
class EndorsementsNotifier extends Notifier<Map<SkillTag, List<Endorsement>>> {
  @override
  Map<SkillTag, List<Endorsement>> build() {
    // Mock: Marco Silva ya tiene algunos endorsements de compañeros
    return {
      SkillTag.regate: [
        Endorsement(fromUserId: 'u2', fromUserName: 'Javi R.', skill: SkillTag.regate, createdAt: DateTime.now().subtract(const Duration(days: 1))),
        Endorsement(fromUserId: 'u3', fromUserName: 'Carlos M.', skill: SkillTag.regate, createdAt: DateTime.now().subtract(const Duration(days: 3))),
      ],
      SkillTag.velocidad: [
        Endorsement(fromUserId: 'u4', fromUserName: 'Lucas P.', skill: SkillTag.velocidad, createdAt: DateTime.now().subtract(const Duration(days: 2))),
      ],
      SkillTag.finalizacion: [
        Endorsement(fromUserId: 'u2', fromUserName: 'Javi R.', skill: SkillTag.finalizacion, createdAt: DateTime.now().subtract(const Duration(days: 5))),
        Endorsement(fromUserId: 'u5', fromUserName: 'Diego R.', skill: SkillTag.finalizacion, createdAt: DateTime.now().subtract(const Duration(days: 7))),
        Endorsement(fromUserId: 'u6', fromUserName: 'Toni F.', skill: SkillTag.finalizacion, createdAt: DateTime.now().subtract(const Duration(days: 10))),
      ],
      SkillTag.liderazgo: [
        Endorsement(fromUserId: 'u7', fromUserName: 'Pedro S.', skill: SkillTag.liderazgo, createdAt: DateTime.now().subtract(const Duration(days: 4))),
      ],
    };
  }

  void addEndorsement(SkillTag skill, String fromId, String fromName) {
    final current = Map<SkillTag, List<Endorsement>>.from(state);
    final alreadyEndorsed = (current[skill] ?? []).any((e) => e.fromUserId == fromId);
    if (alreadyEndorsed) return;
    current[skill] = [
      ...(current[skill] ?? []),
      Endorsement(fromUserId: fromId, fromUserName: fromName, skill: skill, createdAt: DateTime.now()),
    ];
    state = current;
  }

  int countFor(SkillTag skill) => (state[skill] ?? []).length;

  List<MapEntry<SkillTag, int>> get topSkills {
    final counts = state.entries.map((e) => MapEntry(e.key, e.value.length)).toList();
    counts.sort((a, b) => b.value.compareTo(a.value));
    return counts.where((e) => e.value > 0).toList();
  }
}

final endorsementsProvider = NotifierProvider<EndorsementsNotifier, Map<SkillTag, List<Endorsement>>>(
  () => EndorsementsNotifier(),
);

// MVP votes de la semana
class MvpVotesNotifier extends Notifier<int> {
  @override
  int build() => 3; // Marco tiene 3 votos MVP esta semana
  void addVote() => state = state + 1;
}

final mvpVotesProvider = NotifierProvider<MvpVotesNotifier, int>(
  () => MvpVotesNotifier(),
);

// Visitas al perfil (PRO feature — visible sin PRO pero borrosas)
class ProfileVisitsNotifier extends Notifier<List<ProfileVisit>> {
  @override
  List<ProfileVisit> build() => [
    ProfileVisit(visitorId: 'sc1', visitorName: 'David Torres', visitorRole: 'Scout', organizacion: 'Real Madrid Academy', visitedAt: DateTime.now().subtract(const Duration(hours: 4))),
    ProfileVisit(visitorId: 'sc2', visitorName: 'Ana Belén', visitorRole: 'Entrenadora', organizacion: 'Atlético de Madrid B', visitedAt: DateTime.now().subtract(const Duration(hours: 18))),
    ProfileVisit(visitorId: 'jo1', visitorName: '****** ***', visitorRole: 'Scout', organizacion: null, visitedAt: DateTime.now().subtract(const Duration(days: 2))),
  ];
}

final profileVisitsProvider = NotifierProvider<ProfileVisitsNotifier, List<ProfileVisit>>(
  () => ProfileVisitsNotifier(),
);

// Convocatorias abiertas en la región del jugador
final convocatoriasProvider = Provider<List<Convocatoria>>((ref) => [
  Convocatoria(
    id: 'c1',
    scoutId: 'sc1',
    scoutName: 'David Torres',
    organizacion: 'Real Madrid Academy',
    titulo: 'Prueba Porteros Sub-17',
    descripcion: 'Buscamos porteros con buena salida de balón para prueba de acceso a la academia Sub-17. Envía tu mejor clip de 60 segundos.',
    tipo: ConvocatoriaType.abierta,
    posicion: 'Portero',
    region: 'Madrid',
    edadMax: 17,
    fechaLimite: DateTime.now().add(const Duration(days: 5)),
    requiereVideo: true,
    candidatos: 12,
  ),
  Convocatoria(
    id: 'c2',
    scoutId: 'sc3',
    scoutName: 'María Jiménez',
    organizacion: 'Valencia CF Academy',
    titulo: 'Extremos con visión de juego Sub-20',
    descripcion: 'Proceso abierto para extremos Sub-20 libres de contrato. Valoramos velocidad y capacidad de 1vs1.',
    tipo: ConvocatoriaType.abierta,
    posicion: 'Extremo',
    region: 'Valencia',
    edadMax: 20,
    fechaLimite: DateTime.now().add(const Duration(days: 12)),
    requiereVideo: false,
    candidatos: 27,
  ),
  Convocatoria(
    id: 'c3',
    scoutId: 'sc4',
    scoutName: 'Roberto Pérez',
    organizacion: 'Getafe CF',
    titulo: 'Delanteros Sub-18',
    descripcion: 'Prueba para delanteros centro y falsos 9. Buscamos definición y movilidad en espacio reducido.',
    tipo: ConvocatoriaType.reto,
    posicion: 'Delantero',
    region: 'Madrid',
    edadMax: 18,
    fechaLimite: DateTime.now().add(const Duration(days: 3)),
    requiereVideo: true,
    candidatos: 8,
  ),
]);

// Once de la Semana — top 11 jugadores de la semana
final onceSemanProvider = Provider<List<OnceSemanEntry>>((ref) => [
  OnceSemanEntry(playerId: 'SLP-0982', playerName: 'Marco Silva', posicion: 'Delantero', region: 'Madrid', rating: 9.1, totalEndorsements: 6, mvpVotes: 3, weekNumber: 13),
  OnceSemanEntry(playerId: 'SLP-1102', playerName: 'Luis Peña', posicion: 'Centrocampista', region: 'Madrid', rating: 8.9, totalEndorsements: 11, mvpVotes: 1, weekNumber: 13),
  OnceSemanEntry(playerId: 'SLP-2201', playerName: 'Álvaro Mora', posicion: 'Portero', region: 'Barcelona', rating: 9.3, totalEndorsements: 8, mvpVotes: 4, weekNumber: 13),
  OnceSemanEntry(playerId: 'SLP-3311', playerName: 'Fermín Díaz', posicion: 'Defensa', region: 'Sevilla', rating: 8.7, totalEndorsements: 5, mvpVotes: 2, weekNumber: 13),
  OnceSemanEntry(playerId: 'SLP-4422', playerName: 'Iker Santos', posicion: 'Extremo', region: 'Bilbao', rating: 9.0, totalEndorsements: 9, mvpVotes: 3, weekNumber: 13),
]);
