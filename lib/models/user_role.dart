enum UserRole {
  player,
  coach,
  tutor,
  scout,
  referee,
  journalist,
  brand,
  fan,
  staff, // Nuevo — administrador
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.player:
        return 'Jugador';
      case UserRole.coach:
        return 'Entrenador';
      case UserRole.tutor:
        return 'Tutor / Padre';
      case UserRole.scout:
        return 'Scout / Ojeador';
      case UserRole.referee:
        return 'Árbitro';
      case UserRole.journalist:
        return 'Periodista';
      case UserRole.brand:
        return 'Marca';
      case UserRole.fan:
        return 'Fan';
      case UserRole.staff:
        return 'Staff / Admin';
    }
  }

  String get description {
    switch (this) {
      case UserRole.player:
        return 'Perfil de jugador activo con CV deportivo';
      case UserRole.coach:
        return 'Gestión de equipo y nominaciones';
      case UserRole.tutor:
        return 'Representante legal de menores';
      case UserRole.scout:
        return 'Búsqueda de talentos certificados';
      case UserRole.referee:
        return 'Validación oficial y acta inmutable';
      case UserRole.journalist:
        return 'Crónicas y análisis del deporte';
      case UserRole.brand:
        return 'Patrocinios y publicidad';
      case UserRole.fan:
        return 'Comunidad, predicciones y votaciones';
      case UserRole.staff:
        return 'Administración, KYC y torneos';
    }
  }

  String get emoji {
    switch (this) {
      case UserRole.player:
        return '⚽';
      case UserRole.coach:
        return '📋';
      case UserRole.tutor:
        return '🛡️';
      case UserRole.scout:
        return '🕵️';
      case UserRole.referee:
        return '⚖️';
      case UserRole.journalist:
        return '🎙️';
      case UserRole.brand:
        return '📢';
      case UserRole.fan:
        return '🙌';
      case UserRole.staff:
        return '⚙️';
    }
  }

  bool get isPlayerLike => this == UserRole.player;
  bool get canManageTeam => this == UserRole.coach;
  bool get hasWallet => [
    UserRole.player,
    UserRole.coach,
    UserRole.journalist,
    UserRole.fan,
  ].contains(this);
}
