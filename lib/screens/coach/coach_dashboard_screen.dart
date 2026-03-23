import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/glow_button.dart';

// ── Modelos ───────────────────────────────────────────────────────────────────
class PlayerData {
  final String name, id, pos, status;
  final double rating;
  final bool isCaptain;

  const PlayerData({
    required this.name,
    required this.id,
    required this.pos,
    required this.status,
    required this.rating,
    this.isCaptain = false,
  });

  PlayerData copyWith({bool? isCaptain, String? status}) => PlayerData(
    name: name,
    id: id,
    pos: pos,
    status: status ?? this.status,
    rating: rating,
    isCaptain: isCaptain ?? this.isCaptain,
  );
}

class TeamData {
  final String id, name;
  final List<PlayerData> players;
  const TeamData({required this.id, required this.name, required this.players});
  TeamData copyWith({String? name, List<PlayerData>? players}) => TeamData(
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
        const PlayerData(
          name: 'Marco Silva',
          id: 'SLP-0982',
          pos: 'Delantero',
          status: 'fit',
          rating: 8.5,
          isCaptain: true,
        ),
        const PlayerData(
          name: 'Luis Peña',
          id: 'SLP-1102',
          pos: 'Centrocampista',
          status: 'fit',
          rating: 7.9,
        ),
        const PlayerData(
          name: 'Carlos Vega',
          id: 'SLP-0871',
          pos: 'Portero',
          status: 'injured',
          rating: 7.2,
        ),
        const PlayerData(
          name: 'Adrián Torres',
          id: 'SLP-1341',
          pos: 'Defensa',
          status: 'fit',
          rating: 8.1,
        ),
        const PlayerData(
          name: 'Jorge Ruiz',
          id: 'SLP-1218',
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
    final p = PlayerData(
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
              if (idCtrl.text.trim().isNotEmpty) {
                ref
                    .read(teamsProvider.notifier)
                    .addPlayerById(
                      teamId,
                      idCtrl.text.trim(),
                      nameCtrl.text.trim(),
                    );
                Navigator.pop(ctx);
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
class _PlayerRow extends StatelessWidget {
  final PlayerData player;
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
  Widget build(BuildContext context) {
    final isInjured = player.status == 'injured';
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return GestureDetector(
      onTap: onNominate,
      onLongPress: () => _showActions(context),
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

  void _showActions(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
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
}
