import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../models/tournament.dart';

enum _StaffTab { kyc, disputes, tournaments, users }

class StaffDashboardScreen extends ConsumerStatefulWidget {
  const StaffDashboardScreen({super.key});
  @override
  ConsumerState<StaffDashboardScreen> createState() =>
      _StaffDashboardScreenState();
}

class _StaffDashboardScreenState extends ConsumerState<StaffDashboardScreen> {
  _StaffTab _tab = _StaffTab.kyc;

  // Estado local de demo
  final List<_KycItem> _kycQueue = [
    _KycItem(
      id: 'SLP-S001',
      name: 'David Torres',
      role: 'Scout',
      doc: 'Licencia #LIC-90821',
      status: 'pendiente',
    ),
    _KycItem(
      id: 'SLP-R002',
      name: 'María López',
      role: 'Árbitro',
      doc: 'ID Árbitro #ARB-442',
      status: 'pendiente',
    ),
    _KycItem(
      id: 'SLP-J002',
      name: 'Tomás Vega',
      role: 'Periodista',
      doc: 'Medio: LaLiga News',
      status: 'aprobado',
    ),
  ];
  final List<_DisputeItem> _disputes = [
    _DisputeItem(
      id: 'D-001',
      title: 'Disputa Fichaje SLP-0982 ↔ RM Academy',
      status: 'abierta',
      date: '2026-03-01',
    ),
    _DisputeItem(
      id: 'D-002',
      title: 'Impugnación Evaluación Árbitro SLP-R001',
      status: 'resuelta',
      date: '2026-02-28',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Panel Staff',
                    style: TextStyle(
                      color: text,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs horizontales
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: _StaffTab.values.map((t) {
                  final sel = _tab == t;
                  return GestureDetector(
                    onTap: () => setState(() => _tab = t),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.buttonBg(isDark) : surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: sel ? AppColors.buttonBg(isDark) : border,
                        ),
                      ),
                      child: Text(
                        _tabLabel(t),
                        style: TextStyle(
                          color: sel ? AppColors.buttonFg(isDark) : muted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _buildTab(isDark, text, muted, surface, border),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tabLabel(_StaffTab t) {
    switch (t) {
      case _StaffTab.kyc:
        return '🪪 KYC';
      case _StaffTab.disputes:
        return '⚖️ Disputas';
      case _StaffTab.tournaments:
        return '🏆 Torneos';
      case _StaffTab.users:
        return '👥 Usuarios';
    }
  }

  Widget _buildTab(
    bool isDark,
    Color text,
    Color muted,
    Color surface,
    Color border,
  ) {
    switch (_tab) {
      // ── KYC ──────────────────────────────────────────────────────────────
      case _StaffTab.kyc:
        return ListView(
          children: [
            Text(
              'Cola de verificación · ${_kycQueue.where((k) => k.status == 'pendiente').length} pendientes',
              style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            ..._kycQueue.map(
              (k) => _KycCard(
                item: k,
                isDark: isDark,
                onApprove: () => setState(() => k.status = 'aprobado'),
                onReject: () => setState(() => k.status = 'rechazado'),
              ),
            ),
          ],
        );

      // ── DISPUTAS ─────────────────────────────────────────────────────────
      case _StaffTab.disputes:
        return ListView(
          children: [
            Text(
              'Disputas activas',
              style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1),
            ),
            const SizedBox(height: 16),
            ..._disputes.map(
              (d) => _DisputeCard(
                item: d,
                isDark: isDark,
                onResolve: () => setState(() => d.status = 'resuelta'),
              ),
            ),
          ],
        );

      // ── TORNEOS ──────────────────────────────────────────────────────────
      case _StaffTab.tournaments:
        return _TournamentPanel(isDark: isDark);

      // ── USUARIOS ─────────────────────────────────────────────────────────
      case _StaffTab.users:
        return _UsersPanel(isDark: isDark);
    }
  }
}

// ── Tarjeta KYC ──────────────────────────────────────────────────────────────
class _KycItem {
  final String id, name, role, doc;
  String status;
  _KycItem({
    required this.id,
    required this.name,
    required this.role,
    required this.doc,
    required this.status,
  });
}

class _KycCard extends StatelessWidget {
  final _KycItem item;
  final bool isDark;
  final VoidCallback onApprove, onReject;
  const _KycCard({
    required this.item,
    required this.isDark,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = item.status == 'pendiente';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPending
              ? AppColors.border(isDark)
              : (item.status == 'aprobado'
                    ? Colors.green.withOpacity(0.4)
                    : Colors.red.withOpacity(0.4)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item.name}  ·  ${item.role}',
                      style: TextStyle(
                        color: AppColors.text(isDark),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.id}  ·  ${item.doc}',
                      style: TextStyle(
                        color: AppColors.textMuted(isDark),
                        fontSize: 11,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(item.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(item.status),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onApprove,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.buttonBg(isDark),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'APROBAR',
                        style: TextStyle(
                          color: AppColors.buttonFg(isDark),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: onReject,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'RECHAZAR',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'aprobado':
        return Colors.green;
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}

// ── Disputas ─────────────────────────────────────────────────────────────────
class _DisputeItem {
  final String id, title, date;
  String status;
  _DisputeItem({
    required this.id,
    required this.title,
    required this.status,
    required this.date,
  });
}

class _DisputeCard extends StatelessWidget {
  final _DisputeItem item;
  final bool isDark;
  final VoidCallback onResolve;
  const _DisputeCard({
    required this.item,
    required this.isDark,
    required this.onResolve,
  });

  @override
  Widget build(BuildContext context) {
    final open = item.status == 'abierta';
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: open
              ? Colors.orange.withOpacity(0.4)
              : AppColors.border(isDark),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.id}  ·  ${item.date}  ·  ${item.status.toUpperCase()}',
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11),
          ),
          if (open) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onResolve,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.buttonBg(isDark),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: Text(
                  'MARCAR COMO RESUELTA',
                  style: TextStyle(
                    color: AppColors.buttonFg(isDark),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TournamentPanel extends ConsumerWidget {
  final bool isDark;
  const _TournamentPanel({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tournaments = ref.watch(tournamentsProvider);
    final muted = AppColors.textMuted(isDark);
    final text = AppColors.text(isDark);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FASE 0 - TORNEOS ACTIVOS',
          style: TextStyle(
            color: muted,
            fontSize: 10,
            letterSpacing: 2,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...tournaments.map((t) {
          final isActive = t.status == TournamentStatus.active;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surface(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? Colors.orange.withOpacity(0.4)
                    : AppColors.border(isDark),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.name,
                        style: TextStyle(
                          color: text,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.orange.withOpacity(0.12)
                            : Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isActive ? 'ACTIVO' : 'FINALIZADO',
                        style: TextStyle(
                          color: isActive ? Colors.orange : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Escrow (Bolsa de Premios): +${t.prizePoolSC.toStringAsFixed(0)} SC',
                  style: TextStyle(
                    color: isActive ? const Color(0xFF34C759) : muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Equipos Participantes: ${t.teamIds.length} / 16',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                if (isActive)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Liberar pago por Escrow (Smart Contract simulado) al equipo ganador
                        ref
                            .read(tournamentsProvider.notifier)
                            .finalizeTournament(t.id, t.teamIds.first);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Smart Contract Ejecutado: ${t.prizePoolSC} SC transferidos a ${t.teamIds.first}.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: const Color(0xFF34C759),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonBg(isDark),
                        foregroundColor: AppColors.buttonFg(isDark),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'FINALIZAR Y LIBERAR ESCROW',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      const Icon(Icons.verified, color: Colors.green, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'Premio SC transferido a: ${t.winnerTeamId}',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ── Panel Usuarios ────────────────────────────────────────────────────────────
class _UsersPanel extends StatefulWidget {
  final bool isDark;
  const _UsersPanel({required this.isDark});
  @override
  State<_UsersPanel> createState() => _UsersPanelState();
}

class _UsersPanelState extends State<_UsersPanel> {
  final _users = [
    {
      'id': 'SLP-0982',
      'name': 'Marco Silva',
      'role': 'Jugador',
      'status': 'activo',
    },
    {
      'id': 'SLP-S001',
      'name': 'David Torres',
      'role': 'Scout',
      'status': 'activo',
    },
    {
      'id': 'SLP-1102',
      'name': 'Luis Peña',
      'role': 'Jugador',
      'status': 'activo',
    },
    {
      'id': 'SLP-J001',
      'name': 'Elena Vance',
      'role': 'Periodista',
      'status': 'activo',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          'GESTIÓN DE USUARIOS',
          style: TextStyle(
            color: AppColors.textMuted(widget.isDark),
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        ..._users.map(
          (u) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface(widget.isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(widget.isDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${u['name']}',
                        style: TextStyle(
                          color: AppColors.text(widget.isDark),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${u['id']}  ·  ${u['role']}',
                        style: TextStyle(
                          color: AppColors.textMuted(widget.isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(
                    () => u['status'] = u['status'] == 'activo'
                        ? 'baneado'
                        : 'activo',
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: u['status'] == 'baneado'
                          ? Colors.red.withOpacity(0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: u['status'] == 'baneado'
                            ? Colors.red.withOpacity(0.4)
                            : AppColors.border(widget.isDark),
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      u['status'] == 'baneado' ? 'Desbanear' : 'Banear',
                      style: TextStyle(
                        color: u['status'] == 'baneado'
                            ? Colors.red
                            : AppColors.textMuted(widget.isDark),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
