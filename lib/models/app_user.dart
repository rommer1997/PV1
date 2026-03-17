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
    );
  }
}

final mockUsers = <UserRole, AppUser>{
  UserRole.player: const AppUser(
    id: '1',
    uniqueId: 'SLP-PLY-2026-1029',
    role: UserRole.player,
    name: 'Marco Silva',
    teamName: 'Madrid U19',
    isMinor: true,
    followersCount: 1204,
    followingCount: 45,
    isVerified: true,
  ),
  UserRole.scout: const AppUser(
    id: '3',
    uniqueId: 'SLP-SCO-2026-9921',
    role: UserRole.scout,
    name: 'David Torres',
    teamName: 'Real Madrid Academy',
    followersCount: 340,
    followingCount: 890,
  ),
  UserRole.coach: const AppUser(
    id: '4',
    uniqueId: 'SLP-COA-2026-1122',
    role: UserRole.coach,
    name: 'Carlos Ruiz',
    teamName: 'Madrid U19',
    followersCount: 56,
  ),
  UserRole.fan: const AppUser(
    id: '5',
    uniqueId: 'SLP-FAN-2026-5544',
    role: UserRole.fan,
    name: 'Laura M.',
    followersCount: 23,
    followingCount: 154,
  ),
  UserRole.tutor: const AppUser(
    id: '6',
    uniqueId: 'SLP-TUT-2026-7788',
    role: UserRole.tutor,
    name: 'Roberto Silva',
  ),
  UserRole.journalist: const AppUser(
    id: '7',
    uniqueId: 'SLP-JOU-2026-8899',
    role: UserRole.journalist,
    name: 'Mario Kempes',
    followersCount: 15200,
  ),
  UserRole.brand: const AppUser(
    id: '8',
    uniqueId: 'SLP-BRN-2026-1234',
    role: UserRole.brand,
    name: 'Nike Football',
    followersCount: 89000,
  ),
  UserRole.staff: const AppUser(
    id: '9',
    uniqueId: 'SLP-STF-2026-4321',
    role: UserRole.staff,
    name: 'Admin Staff',
  ),
  UserRole.referee: const AppUser(
    id: '10',
    uniqueId: 'SLP-REF-2026-9999',
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
