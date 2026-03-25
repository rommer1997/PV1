import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_user.dart';
import '../models/user_role.dart';

/// Datos extendidos de un jugador para el ecosistema coordinado
class PlayerData {
  final AppUser user;
  final List<String> scoutWatchlistIds; // IDs de scouts interesados
  final List<Map<String, dynamic>> pendingOffers; // Ofertas de scouts/clubes
  final String? currentCoachId;
  final bool isAvailable;

  const PlayerData({
    required this.user,
    this.scoutWatchlistIds = const [],
    this.pendingOffers = const [],
    this.currentCoachId,
    this.isAvailable = true,
  });

  PlayerData copyWith({
    AppUser? user,
    List<String>? scoutWatchlistIds,
    List<Map<String, dynamic>>? pendingOffers,
    String? currentCoachId,
    bool? isAvailable,
  }) {
    return PlayerData(
      user: user ?? this.user,
      scoutWatchlistIds: scoutWatchlistIds ?? this.scoutWatchlistIds,
      pendingOffers: pendingOffers ?? this.pendingOffers,
      currentCoachId: currentCoachId ?? this.currentCoachId,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

class PlayersNotifier extends Notifier<List<PlayerData>> {
  @override
  List<PlayerData> build() {
    // Inicializar con los usuarios que son jugadores del sistema
    return [
      PlayerData(
        user: mockUsers[UserRole.player]!.copyWith(
          achievements: ['Fiel a Cantera', 'Fair Play Bronce', 'Elite MVP'],
          ovrHistory: {
            '2026-01-15': 71.0,
            '2026-01-30': 72.5,
            '2026-02-15': 75.0,
            '2026-02-28': 74.0,
            '2026-03-15': 78.5,
          },
        ),
        scoutWatchlistIds: ['3', '105', '201'], // Más scouts interesados
      ),
      const PlayerData(
        user: AppUser(
          id: '101',
          uniqueId: 'Cantera-8832',
          role: UserRole.player,
          name: 'Luis Peña',
          teamName: 'Rayo Vallecano U19',
          isVerified: true,
          position: 'MC',
          followersCount: 890,
        ),
      ),
      const PlayerData(
        user: AppUser(
          id: '102',
          uniqueId: 'Cantera-5541',
          role: UserRole.player,
          name: 'Adrián Torres',
          teamName: 'Getafe CF U19',
          isVerified: true,
          position: 'DF',
          followersCount: 430,
        ),
      ),
      const PlayerData(
        user: AppUser(
          id: '103',
          uniqueId: 'Cantera-2210',
          role: UserRole.player,
          name: 'Jorge Ruiz',
          teamName: 'CD Leganés U19',
          isVerified: false,
          position: 'POR',
          followersCount: 210,
        ),
      ),
    ];
  }

  void toggleWatchlist(String playerId, String scoutId) {
    state = [
      for (final p in state)
        if (p.user.id == playerId)
          p.copyWith(
            scoutWatchlistIds: p.scoutWatchlistIds.contains(scoutId)
                ? p.scoutWatchlistIds.where((id) => id != scoutId).toList()
                : [...p.scoutWatchlistIds, scoutId],
          )
        else
          p,
    ];
  }

  void addOffer(String playerId, Map<String, dynamic> offer) {
    state = [
      for (final p in state)
        if (p.user.id == playerId)
          p.copyWith(pendingOffers: [...p.pendingOffers, offer])
        else
          p,
    ];
  }

  void updatePrivateNote(String playerId, String coachId, String note) {
    state = [
      for (final p in state)
        if (p.user.id == playerId)
          p.copyWith(
            user: p.user.copyWith(
              privateNotes: {...p.user.privateNotes, coachId: note},
            ),
          )
        else
          p,
    ];
  }

  void addScoutingReport(String playerId, Map<String, dynamic> report) {
    state = [
      for (final p in state)
        if (p.user.id == playerId)
          p.copyWith(
            user: p.user.copyWith(
              scoutingReports: [...p.user.scoutingReports, report],
            ),
          )
        else
          p,
    ];
  }
}

final playersProvider = NotifierProvider<PlayersNotifier, List<PlayerData>>(
  () => PlayersNotifier(),
);
