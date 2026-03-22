import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match_event.dart';
import '../models/match_participant.dart';

final mockMatches = [
  MatchEvent(
    id: 'm1',
    title: 'Pachanga 7v7 Nocturna',
    locationName: 'Polideportivo Centro',
    date: DateTime.now().add(const Duration(days: 1, hours: 2)),
    matchFormat: '7v7',
    skillLevel: 'Amateur',
    genderCategory: 'Mixto',
    priceInSportCoins: 50.0,
    maxPlayers: 14,
    creatorId: '9', // Admin Staff
    participants: const [
      MatchParticipant(userId: '1', hasPaid: true),
    ],
  ),
  MatchEvent(
    id: 'm2',
    title: 'Torneo Femenino Relámpago',
    locationName: 'Canchas del Sur',
    date: DateTime.now().add(const Duration(days: 3, hours: 4)),
    matchFormat: '5v5',
    skillLevel: 'Competitivo',
    genderCategory: 'Femenino',
    priceInSportCoins: 100.0,
    maxPlayers: 10,
    creatorId: '8', // Marca
  ),
  MatchEvent(
    id: 'm3',
    title: 'Entrenamiento Sub-15',
    locationName: 'Ciudad Deportiva',
    date: DateTime.now().add(const Duration(days: 2)),
    matchFormat: '11v11',
    skillLevel: 'Intermedio',
    genderCategory: 'Mixto',
    priceInSportCoins: 20.0,
    maxPlayers: 22,
    creatorId: '4', // Coach
  ),
];

class MatchesNotifier extends Notifier<List<MatchEvent>> {
  @override
  List<MatchEvent> build() {
    return mockMatches;
  }

  void addMatch(MatchEvent match) {
    state = [...state, match];
  }

  void joinMatch(String matchId, String userId) {
    state = [
      for (final match in state)
        if (match.id == matchId)
          match.copyWith(
            participants: [
              ...match.participants,
              MatchParticipant(userId: userId, hasPaid: true),
            ],
          )
        else
          match
    ];
  }

  void assignRefereeToMatch(String matchId, String refereeId) {
    state = [
      for (final match in state)
        if (match.id == matchId)
          match.copyWith(refereeId: refereeId)
        else
          match
    ];
  }
  
  void checkInParticipant(String matchId, String userId) {
    state = [
      for (final match in state)
        if (match.id == matchId)
          match.copyWith(
            participants: [
              for (final p in match.participants)
                if (p.userId == userId)
                  p.copyWith(hasCheckedIn: true)
                else
                  p
            ]
          )
        else
          match
    ];
  }
}

final matchesProvider = NotifierProvider<MatchesNotifier, List<MatchEvent>>(() {
  return MatchesNotifier();
});
