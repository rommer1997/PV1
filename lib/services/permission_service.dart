import '../models/user_role.dart';

/// Servicio de permisos — define RBAC completo para la UI.
/// Espeja las políticas RLS de Supabase que deben implementarse en backend.
class PermissionService {
  // ── Acceso al Feed social ─────────────────────────────────────────────────
  static bool canAccessFeed(UserRole role) {
    // Árbitros no tienen acceso al feed social
    return role != UserRole.referee;
  }

  // ── Editar bio propia ─────────────────────────────────────────────────────
  static bool canEditBio(UserRole role) {
    return [UserRole.player, UserRole.journalist].contains(role);
  }

  // ── Editar estadísticas oficiales ─────────────────────────────────────────
  /// Nadie excepto árbitros puede escribir stats validadas.
  /// Jugadores solo lectura.
  static bool canWriteOfficialStats(UserRole role) {
    return role == UserRole.referee;
  }

  // ── Ver datos de contacto de menores ─────────────────────────────────────
  /// Scouts NO ven contacto de menores. Tutor, Coach y Staff sí.
  static bool canSeeMinorContact(UserRole role) {
    return [UserRole.tutor, UserRole.coach, UserRole.staff].contains(role);
  }

  // ── Enviar solicitudes de contacto a jugadores ────────────────────────────
  /// Solo scouts. Chat directo está bloqueado hasta que tutor/entrenador acepta.
  static bool canSendInterestRequest(UserRole role) {
    return role == UserRole.scout;
  }

  // ── Gestión de equipo (crear, añadir, expulsar) ───────────────────────────
  static bool canManageTeam(UserRole role) {
    return role.canManageTeam;
  }

  // ── Nominar jugadores para evaluación ─────────────────────────────────────
  static bool canNominatePlayer(UserRole role) {
    return role == UserRole.coach;
  }

  // ── Evaluar y sellar acta como árbitro ────────────────────────────────────
  static bool canEvaluate(UserRole role) {
    return role == UserRole.referee;
  }

  // ── Publicar contenido editorial ──────────────────────────────────────────
  static bool canPublishArticle(UserRole role) {
    return role == UserRole.journalist;
  }

  // ── Subir media (posts, reels, fotos) ────────────────────────────────────
  static bool canUploadMedia(UserRole role) {
    return [UserRole.player].contains(role);
  }

  // ── Aprobar/rechazar solicitudes de scout para menores ────────────────────
  static bool canApproveScoutContact(UserRole role) {
    return role == UserRole.tutor;
  }

  // ── Validación social (20% del peso) ─────────────────────────────────────
  static bool canVoteSocial(UserRole role) {
    return role == UserRole.fan;
  }

  // ── Gestionar publicidad / patrocinios ────────────────────────────────────
  static bool canManageAds(UserRole role) {
    return role == UserRole.brand;
  }

  // ── Funciones de Staff (KYC, torneos, baneos) ─────────────────────────────
  static bool canAdminister(UserRole role) {
    return role == UserRole.staff;
  }

  // ── Watchlist / Favoritos ─────────────────────────────────────────────────
  static bool canUseWatchlist(UserRole role) {
    return role == UserRole.scout;
  }

  // ── Transferencias / Fichajes ─────────────────────────────────────────────
  static bool canSendTransferOffer(UserRole role) {
    return [UserRole.coach, UserRole.scout].contains(role);
  }

  // ── Predict-to-Earn ───────────────────────────────────────────────────────
  static bool canPredict(UserRole role) {
    return role == UserRole.fan;
  }

  // ── Inscribir equipo en torneo ────────────────────────────────────────────
  static bool canRegisterTournament(UserRole role) {
    return role == UserRole.coach;
  }
}
