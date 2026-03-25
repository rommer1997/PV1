import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user_role.dart';

class AppUser {
  final String id;
  final String uniqueId;
  final UserRole role;
  final String name;
  final String? teamName;
  final double sportcoins;
  final bool isMinor;
  final int dailyLoginStreak;
  final bool isPubliclyVisible;
  final int followersCount;
  final int followingCount;
  final bool isVerified;
  final String? location;
  final String? bio;
  final String? ageGroup;
  final String? position;
  final List<String> achievements;
  final Map<String, double> ovrHistory; // ISO Date -> OVR
  final Map<String, String> privateNotes; // PlayerID -> Note (Coach only)
  final List<Map<String, dynamic>> scoutingReports; // Professional reports
  final Map<String, bool> privacySettings; // Feature -> Enabled

  const AppUser({
    required this.id,
    required this.uniqueId,
    required this.role,
    required this.name,
    this.teamName,
    this.sportcoins = 0,
    this.isMinor = false,
    this.dailyLoginStreak = 1,
    this.isPubliclyVisible = true,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isVerified = false,
    this.location,
    this.bio,
    this.ageGroup,
    this.position,
    this.achievements = const [],
    this.ovrHistory = const {},
    this.privateNotes = const {},
    this.scoutingReports = const [],
    this.privacySettings = const {
      'showRealName': true,
      'showExactOVR': true,
      'showTeamName': true,
      'allowMessages': true,
    },
  });

  /// Sanitiza los datos sensibles según la relación con el visor.
  /// Si el usuario es menor y el visor no tiene permiso explícito, elimina datos.
  AppUser sanitize({required bool isAuthorized}) {
    // Si el padre ha ocultado el perfil completamente
    if (!isPubliclyVisible && !isAuthorized) return this;

    if (!isMinor || isAuthorized) return this;

    return AppUser(
      id: id,
      uniqueId: uniqueId,
      role: role,
      name: name, // Mantenemos el nombre pero ocultamos el resto
      teamName: 'Recinto Protegido', // Ocultamos el club real por seguridad
      sportcoins: 0,
      isMinor: true,
      followersCount: followersCount,
      followingCount: followingCount,
      isVerified: isVerified,
      location: null,
      bio: null,
      ageGroup: ageGroup,
      position: null,
      achievements: achievements,
      ovrHistory: ovrHistory,
      privateNotes: const {}, // Nunca compartir notas privadas
      scoutingReports: const [], // Informes profesionales son privados
      privacySettings: privacySettings,
    );
  }

  AppUser copyWith({
    String? id,
    String? uniqueId,
    UserRole? role,
    String? name,
    String? teamName,
    double? sportcoins,
    bool? isMinor,
    int? dailyLoginStreak,
    bool? isPubliclyVisible,
    int? followersCount,
    int? followingCount,
    bool? isVerified,
    String? location,
    String? bio,
    String? ageGroup,
    String? position,
    List<String>? achievements,
    Map<String, double>? ovrHistory,
    Map<String, String>? privateNotes,
    List<Map<String, dynamic>>? scoutingReports,
    Map<String, bool>? privacySettings,
  }) {
    return AppUser(
      id: id ?? this.id,
      uniqueId: uniqueId ?? this.uniqueId,
      role: role ?? this.role,
      name: name ?? this.name,
      teamName: teamName ?? this.teamName,
      sportcoins: sportcoins ?? this.sportcoins,
      isMinor: isMinor ?? this.isMinor,
      dailyLoginStreak: dailyLoginStreak ?? this.dailyLoginStreak,
      isPubliclyVisible: isPubliclyVisible ?? this.isPubliclyVisible,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      ageGroup: ageGroup ?? this.ageGroup,
      position: position ?? this.position,
      achievements: achievements ?? this.achievements,
      ovrHistory: ovrHistory ?? this.ovrHistory,
      privateNotes: privateNotes ?? this.privateNotes,
      scoutingReports: scoutingReports ?? this.scoutingReports,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }
}

final mockUsers = <UserRole, AppUser>{
  UserRole.player: const AppUser(
    id: '1',
    uniqueId: 'Cantera-PLY-2026-1029',
    role: UserRole.player,
    name: 'Marco Silva',
    teamName: 'Madrid U19',
    isMinor: true,
    followersCount: 1204,
    followingCount: 45,
    isVerified: true,
    ageGroup: '15-17 años',
    position: 'DEL',
    bio: 'Falso 9 con excelente visión de juego y regate en espacios reducidos. Mi objetivo principal este año es conseguir una beca deportiva internacional.',
  ),
  UserRole.scout: const AppUser(
    id: '3',
    uniqueId: 'Cantera-SCO-2026-9921',
    role: UserRole.scout,
    name: 'David Torres',
    teamName: 'Real Madrid Academy',
    followersCount: 340,
    followingCount: 890,
  ),
  UserRole.coach: const AppUser(
    id: '4',
    uniqueId: 'Cantera-COA-2026-1122',
    role: UserRole.coach,
    name: 'Carlos Ruiz',
    teamName: 'Madrid U19',
    followersCount: 56,
  ),
  UserRole.fan: const AppUser(
    id: '5',
    uniqueId: 'Cantera-FAN-2026-5544',
    role: UserRole.fan,
    name: 'Laura M.',
    followersCount: 23,
    followingCount: 154,
    ageGroup: '+21 años',
  ),
  UserRole.tutor: const AppUser(
    id: '6',
    uniqueId: 'Cantera-TUT-2026-7788',
    role: UserRole.tutor,
    name: 'Roberto Silva',
  ),
  UserRole.journalist: const AppUser(
    id: '7',
    uniqueId: 'Cantera-JOU-2026-8899',
    role: UserRole.journalist,
    name: 'Mario Kempes',
    followersCount: 15200,
  ),
  UserRole.brand: const AppUser(
    id: '8',
    uniqueId: 'Cantera-BRN-2026-1234',
    role: UserRole.brand,
    name: 'Nike Football',
    followersCount: 89000,
  ),
  UserRole.staff: const AppUser(
    id: '9',
    uniqueId: 'Cantera-STF-2026-4321',
    role: UserRole.staff,
    name: 'Admin Staff',
  ),
  UserRole.referee: const AppUser(
    id: '10',
    uniqueId: 'Cantera-REF-2026-9999',
    role: UserRole.referee,
    name: 'Mateu Lahoz',
    followersCount: 120,
  ),
};

class SessionNotifier extends Notifier<AppUser?> {
  @override
  AppUser? build() => null;
  void login(AppUser user) => state = user;
  void logout() => state = null;
  void addSportCoins(double amount) {
    if (state != null) {
      state = AppUser(
        id: state!.id,
        uniqueId: state!.uniqueId,
        role: state!.role,
        name: state!.name,
        teamName: state!.teamName,
        sportcoins: state!.sportcoins + amount,
        isMinor: state!.isMinor,
        dailyLoginStreak: state!.dailyLoginStreak,
        isPubliclyVisible: state!.isPubliclyVisible,
        followersCount: state!.followersCount,
        followingCount: state!.followingCount,
        isVerified: state!.isVerified,
        location: state!.location,
        bio: state!.bio,
        ageGroup: state!.ageGroup,
        position: state!.position,
        achievements: state!.achievements,
        ovrHistory: state!.ovrHistory,
        privateNotes: state!.privateNotes,
        scoutingReports: state!.scoutingReports,
        privacySettings: state!.privacySettings,
      );
    }
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AppUser?>(
  () => SessionNotifier(),
);

// ── Global Safety Lock (Crisis Mode) ─────────────────────────────────────────
// Cuando está activo, todos los datos de menores se sanitizan automáticamente.
class SafetyLockNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final safetyLockProvider = NotifierProvider<SafetyLockNotifier, bool>(
  () => SafetyLockNotifier(),
);
