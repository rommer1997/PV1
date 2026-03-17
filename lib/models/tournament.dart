import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TournamentStatus { registering, active, finished }

class Tournament {
  final String id;
  final String name;
  final double prizePoolSC;
  final List<String> teamIds;
  final TournamentStatus status;
  final String? winnerTeamId;

  const Tournament({
    required this.id,
    required this.name,
    this.prizePoolSC = 1000,
    this.teamIds = const [],
    this.status = TournamentStatus.registering,
    this.winnerTeamId,
  });

  Tournament copyWith({
    String? name,
    double? prizePoolSC,
    List<String>? teamIds,
    TournamentStatus? status,
    String? winnerTeamId,
  }) {
    return Tournament(
      id: id,
      name: name ?? this.name,
      prizePoolSC: prizePoolSC ?? this.prizePoolSC,
      teamIds: teamIds ?? this.teamIds,
      status: status ?? this.status,
      winnerTeamId: winnerTeamId ?? this.winnerTeamId,
    );
  }
}

class TournamentNotifier extends Notifier<List<Tournament>> {
  @override
  List<Tournament> build() {
    return [
      const Tournament(
        id: 'T001',
        name: 'Madrid U19 Summer Cup (Fase 0)',
        prizePoolSC: 5000, // 5,000 SC Escrow Vault
        teamIds: ['TM-01', 'TM-02', 'Madrid U19'], // Example mock teams
        status: TournamentStatus.active,
      ),
    ];
  }

  void finalizeTournament(String tournamentId, String winnerTeamId) {
    state = state.map((t) {
      if (t.id == tournamentId) {
        return t.copyWith(
          status: TournamentStatus.finished,
          winnerTeamId: winnerTeamId,
        );
      }
      return t;
    }).toList();
  }
}

final tournamentsProvider =
    NotifierProvider<TournamentNotifier, List<Tournament>>(
      () => TournamentNotifier(),
    );
