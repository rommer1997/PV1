class MatchParticipant {
  final String userId;
  final bool hasPaid;
  final bool hasCheckedIn;
  final String? assignedTeam; // Ej. "Team A" o "Team B" (PETOS vs SIN PETOS)
  final bool isMinorApprovedByTutor;

  const MatchParticipant({
    required this.userId,
    this.hasPaid = true,
    this.hasCheckedIn = false,
    this.assignedTeam,
    this.isMinorApprovedByTutor = false,
  });

  MatchParticipant copyWith({
    String? userId,
    bool? hasPaid,
    bool? hasCheckedIn,
    String? assignedTeam,
    bool? isMinorApprovedByTutor,
  }) {
    return MatchParticipant(
      userId: userId ?? this.userId,
      hasPaid: hasPaid ?? this.hasPaid,
      hasCheckedIn: hasCheckedIn ?? this.hasCheckedIn,
      assignedTeam: assignedTeam ?? this.assignedTeam,
      isMinorApprovedByTutor: isMinorApprovedByTutor ?? this.isMinorApprovedByTutor,
    );
  }
}
