import 'match_participant.dart';

class MatchEvent {
  final String id;
  final String title;
  final String locationName;
  final DateTime date;
  final String matchFormat; // Ej. "5v5", "7v7", "11v11"
  final String skillLevel; // Ej. "Amateur", "Competitivo", "Principiante"
  final String genderCategory; // Ej. "Masculino", "Femenino", "Mixto"
  final double priceInSportCoins;
  final int maxPlayers;
  
  // Organizador (Staff o Brand)
  final String creatorId; 
  
  // Inscritos
  final List<MatchParticipant> participants;
  
  // Roles Complementarios (Slots V.I.P)
  final String? refereeId;
  final List<String> scoutIds;
  final String? reporterId;
  
  const MatchEvent({
    required this.id,
    required this.title,
    required this.locationName,
    required this.date,
    required this.matchFormat,
    required this.skillLevel,
    required this.genderCategory,
    required this.priceInSportCoins,
    required this.maxPlayers,
    required this.creatorId,
    this.participants = const [],
    this.refereeId,
    this.scoutIds = const [],
    this.reporterId,
  });

  // Calculo derivado rápido
  int get availableSlots => maxPlayers - participants.length;
  bool get isFull => availableSlots <= 0;
  
  MatchEvent copyWith({
    String? id,
    String? title,
    String? locationName,
    DateTime? date,
    String? matchFormat,
    String? skillLevel,
    String? genderCategory,
    double? priceInSportCoins,
    int? maxPlayers,
    String? creatorId,
    List<MatchParticipant>? participants,
    String? refereeId,
    List<String>? scoutIds,
    String? reporterId,
  }) {
    return MatchEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      locationName: locationName ?? this.locationName,
      date: date ?? this.date,
      matchFormat: matchFormat ?? this.matchFormat,
      skillLevel: skillLevel ?? this.skillLevel,
      genderCategory: genderCategory ?? this.genderCategory,
      priceInSportCoins: priceInSportCoins ?? this.priceInSportCoins,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      creatorId: creatorId ?? this.creatorId,
      participants: participants ?? this.participants,
      refereeId: refereeId ?? this.refereeId,
      scoutIds: scoutIds ?? this.scoutIds,
      reporterId: reporterId ?? this.reporterId,
    );
  }
}
