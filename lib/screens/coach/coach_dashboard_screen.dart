import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/match_evaluations_provider.dart';
import '../../providers/players_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/spotlight_models.dart';
import '../../widgets/glow_button.dart';
import 'dart:math' as math;

// ── Modelos Locales de Equipo ──────────────────────────────────────────────
class TeamMember {
  final String id, name, pos, status;
  final double rating;
  final bool isCaptain;

  const TeamMember({
    required this.id,
    required this.name,
    required this.pos,
    required this.status,
    required this.rating,
    this.isCaptain = false,
  });

  TeamMember copyWith({bool? isCaptain, String? status}) => TeamMember(
    id: id,
    name: name,
    pos: pos,
    status: status ?? this.status,
    rating: rating,
    isCaptain: isCaptain ?? this.isCaptain,
  );
}

class TeamData {
  final String id, name;
  final List<TeamMember> players;
  const TeamData({required this.id, required this.name, required this.players});
  TeamData copyWith({String? name, List<TeamMember>? players}) => TeamData(
    id: id,
    name: name ?? this.name,
    players: players ?? this.players,
  );
}

// ── Providers ─────────────────────────────────────────────────────────────────
class TeamsNotifier extends Notifier<List<TeamData>> {
  @override
  List<TeamData> build() => [
    TeamData(
      id: 'T1',
      name: 'Atletico Juvenil A',
      players: [
        const TeamMember(
          name: 'Marco Silva',
          id: '1',
          pos: 'Delantero',
          status: 'fit',
          rating: 8.5,
          isCaptain: true,
        ),
        const TeamMember(
          name: 'Luis Peña',
          id: '101',
          pos: 'Centrocampista',
          status: 'fit',
          rating: 7.9,
        ),
        const TeamMember(
          name: 'Carlos Vega',
          id: 'SLP-0871',
          pos: 'Portero',
          status: 'injured',
          rating: 7.2,
        ),
        const TeamMember(
          name: 'Adrián Torres',
          id: '102',
          pos: 'Defensa',
          status: 'fit',
          rating: 8.1,
        ),
        const TeamMember(
          name: 'Jorge Ruiz',
          id: '103',
          pos: 'Delantero',
          status: 'fit',
          rating: 7.6,
        ),
      ],
    ),
  ];

  void addTeam(String name) {
    final id = 'T${DateTime.now().millisecondsSinceEpoch}';
    state = [...state, TeamData(id: id, name: name, players: [])];
  }

  void setCaptain(String teamId, String playerId) {
    state = state.map((t) {
      if (t.id != teamId) return t;
      return t.copyWith(
        players: t.players
            .map((p) => p.copyWith(isCaptain: p.id == playerId))
            .toList(),
      );
    }).toList();
  }

  void removeCaptain(String teamId) {
    state = state.map((t) {
      if (t.id != teamId) return t;
      return t.copyWith(
        players: t.players.map((p) => p.copyWith(isCaptain: false)).toList(),
      );
    }).toList();
  }

  void addPlayerById(String teamId, String playerId, String name) {
    final p = TeamMember(
      name: name.isNotEmpty ? name : 'Jugador $playerId',
      id: playerId,
      pos: 'Por definir',
      status: 'fit',
      rating: 0.0,
    );
    state = state
        .map((t) => t.id == teamId ? t.copyWith(players: [...t.players, p]) : t)
        .toList();
  }

  void removePlayer(String teamId, String playerId) {
    state = state.map((t) {
      if (t.id != teamId) return t;
      return t.copyWith(
        players: t.players.where((p) => p.id != playerId).toList(),
      );
    }).toList();
  }
}

final teamsProvider = NotifierProvider<TeamsNotifier, List<TeamData>>(
  () => TeamsNotifier(),
);

final selectedTeamIndexProvider = NotifierProvider<_IndexNotifier, int>(
  () => _IndexNotifier(),
);

class _IndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  @override
  set state(int v) => super.state = v;
}

class NominationsNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void toggle(String id) {
    if (state.contains(id)) {
      state = state.where((x) => x != id).toList();
    } else if (state.length < 3)
      state = [...state, id];
  }

  void clear() => state = [];
}

final nominationsProvider = NotifierProvider<NominationsNotifier, List<String>>(
  () => NominationsNotifier(),
);

// ── Solicitudes Pendientes (Mock Handshake) ───────────────────────────────────
class PendingRequest {
  final String playerId, playerName, teamId;
  const PendingRequest(this.playerId, this.playerName, this.teamId);
}

class PendingRequestsNotifier extends Notifier<List<PendingRequest>> {
  @override
  List<PendingRequest> build() => [
    const PendingRequest('SLP-8832', 'Javier Gómez', 'T1'),
  ];

  void removeRequest(String playerId) {
    state = state.where((req) => req.playerId != playerId).toList();
  }
}

final pendingRequestsProvider =
    NotifierProvider<PendingRequestsNotifier, List<PendingRequest>>(
  () => PendingRequestsNotifier(),
);

// ── Pantalla ──────────────────────────────────────────────────────────────────
class CoachDashboardScreen extends ConsumerWidget {
  const CoachDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final teams = ref.watch(teamsProvider);
    final selIdx = ref.watch(selectedTeamIndexProvider);
    final nominations = ref.watch(nominationsProvider);
    final pendingRequests = ref.watch(pendingRequestsProvider);

    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    final selectedIdx = selIdx.clamp(0, (teams.length - 1).clamp(0, 999));
    final team = teams.isEmpty ? null : teams[selectedIdx];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          // BouncingScrollPhysics: todo el contenido — header + lista — baja junto
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // ── Header + Chips + Panel nominaciones (todo desplazable) ─────────
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 20, 28, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ENTRENADOR',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mis Equipos',
                              style: TextStyle(
                                color: text,
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                            ),
                            GlowButton(
                              label: '+ Equipo',
                              selected: true,
                              isDark: isDark,
                              onTap: () => _addTeamDialog(context, ref, isDark),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Chips de equipo
                        if (teams.isNotEmpty)
                          SizedBox(
                            height: 38,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: teams.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) => GlowButton(
                                label: teams[i].name,
                                selected: i == selectedIdx,
                                isDark: isDark,
                                onTap: () =>
                                    ref
                                            .read(
                                              selectedTeamIndexProvider
                                                  .notifier,
                                            )
                                            .state =
                                        i,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Panel nominaciones
                  if (team != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nominaciones para árbitro',
                                    style: TextStyle(
                                      color: muted,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${nominations.length} / 3',
                                    style: TextStyle(
                                      color: text,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                GlowButton(
                                  label: '+ ID',
                                  selected: false,
                                  isDark: isDark,
                                  onTap: () => _addPlayerDialog(
                                    context,
                                    ref,
                                    isDark,
                                    team.id,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 7,
                                  ),
                                ),
                                if (nominations.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  GlowButton(
                                    label: 'Enviar al Árbitro',
                                    selected: true,
                                    isDark: isDark,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    onTap: () {
                                      ref
                                          .read(nominationsProvider.notifier)
                                          .clear();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            '✓ Nominaciones enviadas al árbitro',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Votación Once de la Semana (Voto Coach x5) ────────────────────
            if (team != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark 
                          ? [const Color(0xFF1A1A1A), const Color(0xFF0D0D0D)]
                          : [const Color(0xFFF9F9F9), Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.buttonBg(isDark).withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              'RANKING SEMANAL',
                              style: TextStyle(
                                color: AppColors.buttonBg(isDark),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu voto vale x5',
                          style: TextStyle(
                            color: text,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Elige al jugador que merece estar en el Once de la Semana de SportLink.',
                          style: TextStyle(color: muted, fontSize: 11, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: team.players.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (ctx, i) {
                              final p = team.players[i];
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  ref.read(mvpVotesProvider.notifier).addVote(weight: 5);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('✓ Has votado por ${p.name} (+5 puntos MVP)'),
                                      backgroundColor: AppColors.buttonBg(isDark),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.bg(isDark),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: border),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p.name.split(' ').first,
                                    style: TextStyle(
                                      color: text,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Radar de Equipo (Stickiness Entrenador) ──────────────────────
            if (team != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                  child: _TeamRadarSection(team: team, isDark: isDark),
                ),
              ),

            // ── Solicitudes Pendientes ─────────
            if (team != null) ...[
              Builder(
                builder: (context) {
                  final teamRequests = pendingRequests.where((r) => r.teamId == team.id).toList();
                  if (teamRequests.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
                  
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(28, 0, 28, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.mark_email_unread_outlined, size: 16, color: Colors.orange.shade400),
                              const SizedBox(width: 6),
                              Text(
                                'SOLICITUDES PENDIENTES (${teamRequests.length})',
                                style: TextStyle(
                                  color: Colors.orange.shade400,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...teamRequests.map((req) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        req.playerName,
                                        style: TextStyle(color: text, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'ID: ${req.playerId}',
                                        style: TextStyle(color: muted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(pendingRequestsProvider.notifier).removeRequest(req.playerId);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: muted.withValues(alpha: 0.3)),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Rechazar', style: TextStyle(color: text, fontSize: 12)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        ref.read(teamsProvider.notifier).addPlayerById(team.id, req.playerId, req.playerName);
                                        ref.read(pendingRequestsProvider.notifier).removeRequest(req.playerId);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('✓ ${req.playerName} añadido al equipo')),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppColors.buttonBg(isDark),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text('Aceptar', style: TextStyle(color: AppColors.buttonFg(isDark), fontSize: 12, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],

            // ── Lista de jugadores (SliverList: fluye con el scroll) ──────────
            if (team == null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.group_off_outlined, size: 48, color: muted),
                      const SizedBox(height: 12),
                      Text(
                        'Sin equipos · Pulsa "+ Equipo" para crear uno',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
              )
            else if (team.players.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Text(
                    'Equipo vacío · Añade jugadores con "+ ID"',
                    style: TextStyle(color: muted),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                sliver: SliverList.separated(
                  itemCount: team.players.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final p = team.players[i];
                    return _PlayerRow(
                      player: p,
                      nominated: nominations.contains(p.id),
                      isDark: isDark,
                      onNominate: () {
                        if (p.status == 'injured') {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Jugador lesionado'),
                            ),
                          );
                        } else {
                          ref.read(nominationsProvider.notifier).toggle(p.id);
                        }
                      },
                      onSetCaptain: () {
                        if (p.isCaptain) {
                          ref
                              .read(teamsProvider.notifier)
                              .removeCaptain(team.id);
                        } else {
                          ref
                              .read(teamsProvider.notifier)
                              .setCaptain(team.id, p.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('⭐ ${p.name} designado capitán'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        }
                      },
                      onRemove: () => ref
                          .read(teamsProvider.notifier)
                          .removePlayer(team.id, p.id),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _addTeamDialog(BuildContext ctx, WidgetRef ref, bool isDark) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text(
          'Nuevo equipo',
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          style: TextStyle(color: AppColors.text(isDark)),
          decoration: InputDecoration(
            hintText: 'Nombre del equipo',
            hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(teamsProvider.notifier).addTeam(ctrl.text.trim());
                ref.read(selectedTeamIndexProvider.notifier).state =
                    ref.read(teamsProvider).length - 1;
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg(isDark),
              foregroundColor: AppColors.buttonFg(isDark),
            ),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _addPlayerDialog(
    BuildContext ctx,
    WidgetRef ref,
    bool isDark,
    String teamId,
  ) {
    final idCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text(
          'Añadir jugador',
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idCtrl,
              style: TextStyle(color: AppColors.text(isDark)),
              decoration: InputDecoration(
                hintText: 'ID SportLink (ej: SLP-1234)',
                hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: AppColors.text(isDark)),
              decoration: InputDecoration(
                hintText: 'Nombre (opcional)',
                hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMuted(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final id = idCtrl.text.trim();
              if (id.isNotEmpty) {
                // 🔍 VALIDACIÓN: Comprobamos si el jugador existe en el sistema SportLink
                final players = ref.read(playersProvider);
                final exists = players.any((p) => p.user.uniqueId == id || p.user.id == id);
                
                if (exists) {
                  final pd = players.firstWhere((p) => p.user.uniqueId == id || p.user.id == id);
                  ref.read(teamsProvider.notifier).addPlayerById(
                    teamId,
                    pd.user.id,
                    pd.user.name,
                  );
                  Navigator.pop(ctx);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('❌ ID SportLink no encontrado. El jugador debe estar registrado.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg(isDark),
              foregroundColor: AppColors.buttonFg(isDark),
            ),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }
}

// ── Fila de jugador ───────────────────────────────────────────────────────────
class _PlayerRow extends ConsumerWidget {
  final TeamMember player;
  final bool nominated, isDark;
  final VoidCallback onNominate, onSetCaptain, onRemove;
  const _PlayerRow({
    required this.player,
    required this.nominated,
    required this.isDark,
    required this.onNominate,
    required this.onSetCaptain,
    required this.onRemove,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInjured = player.status == 'injured';
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return GestureDetector(
      onTap: onNominate,
      onLongPress: () => _showActions(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: nominated
              ? (isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.05))
              : surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: nominated ? text.withValues(alpha: 0.3) : border),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isInjured
                    ? const Color(0xFFFF3B30)
                    : const Color(0xFF34C759),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        player.name,
                        style: TextStyle(
                          color: isInjured ? muted : text,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (player.isCaptain) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '⭐ CAP',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '${player.pos} · ${player.id}',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (player.rating > 0)
              Text(
                player.rating.toStringAsFixed(1),
                style: TextStyle(
                  color: isInjured ? muted : text,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(width: 10),
            Icon(
              nominated ? Icons.check_circle : Icons.radio_button_unchecked,
              color: nominated ? text : muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              player.name,
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${player.pos} · ${player.id}',
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.analytics_outlined,
                color: AppColors.accent,
              ),
              title: Text(
                'Evaluación Técnica',
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Registrar rendimiento del partido',
                style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showEvaluationDialog(context, ref, isDark);
              },
            ),
            ListTile(
              leading: Icon(
                player.isCaptain ? Icons.star_border : Icons.star,
                color: const Color(0xFFFFD700),
              ),
              title: Text(
                player.isCaptain ? 'Quitar capitanía' : 'Designar capitán',
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onSetCaptain();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.sticky_note_2_outlined,
                color: Colors.amber.shade600,
              ),
              title: Text(
                'Notas Privadas',
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Solo visibles para ti',
                style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _showPrivateNoteDialog(context, ref, isDark);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: Color(0xFFFF3B30),
              ),
              title: const Text(
                'Retirar del equipo',
                style: TextStyle(
                  color: Color(0xFFFF3B30),
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onRemove();
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showPrivateNoteDialog(BuildContext context, WidgetRef ref, bool isDark) {
    final players = ref.read(playersProvider);
    final pd = players.where((p) => p.user.id == player.id).firstOrNull;
    const coachId = '4'; 
    final initialNote = pd?.user.privateNotes[coachId] ?? '';
    
    final ctrl = TextEditingController(text: initialNote);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface(isDark),
        title: Text('Notas: ${player.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          style: TextStyle(color: AppColors.text(isDark)),
          decoration: InputDecoration(
            hintText: 'Ej: Jugador clave para transiciones rápidas. Le falta fondo físico.',
            hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cerrar', style: TextStyle(color: AppColors.textMuted(isDark))),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(playersProvider.notifier).updatePrivateNote(player.id, coachId, ctrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✓ Nota guardada')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonBg(isDark),
              foregroundColor: AppColors.buttonFg(isDark),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEvaluationDialog(BuildContext context, WidgetRef ref, bool isDark) {
    double tec = 8.0, res = 8.0, fpl = 8.0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          backgroundColor: AppColors.surface(isDark),
          title: Row(
            children: [
              Icon(Icons.analytics_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 10),
              const Text('Evaluación Coach', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _EvaluationSlider(
                label: 'Técnica',
                value: tec,
                onChanged: (v) => setState(() => tec = v),
                isDark: isDark,
              ),
              _EvaluationSlider(
                label: 'Resistencia',
                value: res,
                onChanged: (v) => setState(() => res = v),
                isDark: isDark,
              ),
              _EvaluationSlider(
                label: 'Fair Play',
                value: fpl,
                onChanged: (v) => setState(() => fpl = v),
                isDark: isDark,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancelar', style: TextStyle(color: AppColors.textMuted(isDark))),
            ),
            ElevatedButton(
              onPressed: () {
                final eval = MatchEvaluation(
                  matchId: 'M-COACH-${DateTime.now().millisecondsSinceEpoch}',
                  matchName: 'Evaluación Técnica Coach',
                  playerId: player.id,
                  playerName: player.name,
                  date: DateTime.now(),
                  tecnica: tec,
                  resistencia: res,
                  fairPlay: fpl,
                  source: EvaluationSource.coach,
                  signature: MatchEvaluation.generateSeal(
                    'M-COACH',
                    player.id,
                    tec,
                    res,
                    fpl,
                    EvaluationSource.coach,
                  ),
                );
                ref.read(matchEvaluationsProvider.notifier).addEvaluation(eval);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✓ Evaluación técnica registrada (Peso 20%)')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonBg(isDark),
                foregroundColor: AppColors.buttonFg(isDark),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvaluationSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final bool isDark;

  const _EvaluationSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(color: AppColors.text(isDark), fontSize: 13)),
            Text(value.toStringAsFixed(1), style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 100,
          activeColor: AppColors.accent,
          onChanged: onChanged,
        ),
      ],
    );

  }
}

class _TeamRadarSection extends StatelessWidget {
  final TeamData team;
  final bool isDark;

  const _TeamRadarSection({required this.team, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final teamStats = {
      'ATAQUE': 8.2,
      'DEFENSA': 6.5,
      'FÍSICO': 7.4,
      'TÁCTICA': 7.9,
      'MORAL': 9.0,
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ANÁLISIS DE EQUIPO',
                style: TextStyle(
                  color: Color(0xFFE2F163),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.radar, size: 16, color: AppColors.buttonBg(isDark)),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              height: 180,
              width: 180,
              child: CustomPaint(
                painter: _SimpleRadarPainter(stats: teamStats, isDark: isDark),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TeamMetric(label: 'Fuerte', val: 'Ataque (8.2)', color: Colors.green, isDark: isDark),
              _TeamMetric(label: 'Débil', val: 'Defensa (6.5)', color: Colors.red, isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamMetric extends StatelessWidget {
  final String label, val;
  final Color color;
  final bool isDark;
  const _TeamMetric({required this.label, required this.val, required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 10, letterSpacing: 1)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}

class _SimpleRadarPainter extends CustomPainter {
  final Map<String, double> stats;
  final bool isDark;
  _SimpleRadarPainter({required this.stats, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final keys = stats.keys.toList();
    final points = <Offset>[];

    final paintLine = Paint()
      ..color = AppColors.border(isDark)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = const Color(0xFFE2F163).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = const Color(0xFFE2F163)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(center, radius * (i / 5), paintLine);
    }

    for (var i = 0; i < keys.length; i++) {
      final angle = (i * 2 * math.pi / keys.length) - math.pi / 2;
      final val = stats[keys[i]]! / 10.0;
      final x = center.dx + radius * val * math.cos(angle);
      final y = center.dy + radius * val * math.sin(angle);
      points.add(Offset(x, y));
      canvas.drawLine(center, Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle)), paintLine);
    }

    if (points.isNotEmpty) {
      final path = Path()..addPolygon(points, true);
      canvas.drawPath(path, paintFill);
      canvas.drawPath(path, paintStroke);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
