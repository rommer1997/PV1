import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/app_user.dart';
import '../../models/user_role.dart';
import '../../models/match_event.dart';
import '../../providers/matches_provider.dart';
import '../../providers/theme_provider.dart';
import 'match_creation_screen.dart';
import 'match_management_dashboard.dart';

class MatchDiscoveryScreen extends ConsumerWidget {
  const MatchDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final primary = AppColors.buttonBg(isDark);

    final matches = ref.watch(matchesProvider);
    final currentUser = ref.watch(sessionProvider);

    final canCreateMatch = currentUser?.role == UserRole.staff || currentUser?.role == UserRole.brand || currentUser?.role == UserRole.coach;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Text(
                    'Próximos Eventos',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (currentUser != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.monetization_on, color: Colors.amber, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '${currentUser.sportcoins.toInt()} SC',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: matches.isEmpty
                  ? Center(child: Text('No hay eventos programados.', style: TextStyle(color: muted)))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return _PremiumMatchCard(match: match, currentUser: currentUser, isDark: isDark);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: canCreateMatch
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MatchCreationScreen()),
                );
              },
              backgroundColor: primary,
              elevation: 4,
              child: Icon(Icons.add, color: AppColors.buttonFg(isDark)),
            )
          : null,
    );
  }
}

class _PremiumMatchCard extends ConsumerWidget {
  final MatchEvent match;
  final AppUser? currentUser;
  final bool isDark;

  const _PremiumMatchCard({required this.match, required this.currentUser, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);

    final isEnrolled = match.participants.any((p) => p.userId == currentUser?.id);
    final isRefereeInfo = match.refereeId == currentUser?.id;
    final isFull = match.isFull;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  match.title.toUpperCase(),
                  style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.buttonBg(isDark).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  match.skillLevel,
                  style: TextStyle(color: AppColors.buttonBg(isDark), fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.location_on_outlined, text: match.locationName, isDark: isDark),
          _InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('EEE, d MMM • HH:mm').format(match.date), isDark: isDark),
          _InfoRow(
            icon: Icons.people_outline,
            text: '${match.participants.length}/${match.maxPlayers} Inscritos • ${match.matchFormat} • ${match.genderCategory}',
            isDark: isDark,
          ),
          
          if (currentUser != null) ...[
            const SizedBox(height: 16),
            Divider(color: border, height: 1),
            const SizedBox(height: 16),
            _buildRoleSpecificActions(context, ref, isEnrolled, isRefereeInfo, isFull),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleSpecificActions(BuildContext context, WidgetRef ref, bool isEnrolled, bool isRefereeInfo, bool isFull) {
    final primary = AppColors.buttonBg(isDark);
    final primaryFg = AppColors.buttonFg(isDark);
    final muted = AppColors.textMuted(isDark);

    switch (currentUser!.role) {
      case UserRole.player:
        if (isEnrolled) {
          return Center(child: Text('✓ INSCRITO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)));
        }
        if (isFull) {
          return Center(child: Text('COMPLETO', style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12)));
        }
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: primaryFg,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              if (currentUser!.sportcoins < match.priceInSportCoins) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fondos insuficientes')));
                return;
              }
              ref.read(sessionProvider.notifier).addSportCoins(-match.priceInSportCoins);
              ref.read(matchesProvider.notifier).joinMatch(match.id, currentUser!.id);
            },
            child: Text('Unirse (${match.priceInSportCoins.toInt()} SC)', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        );

      case UserRole.referee:
        if (match.refereeId != null) {
          if (isRefereeInfo) return Center(child: Text('✓ ÁRBITRO ASIGNADO', style: TextStyle(color: primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)));
          return Center(child: Text('ÁRBITRO YA CUBIERTO', style: TextStyle(color: muted, fontSize: 12, letterSpacing: 1)));
        }
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: BorderSide(color: primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.sports, size: 18),
            label: const Text('Pitar partido (+30 SC)'),
            onPressed: () {
              ref.read(matchesProvider.notifier).assignRefereeToMatch(match.id, currentUser!.id);
              ref.read(sessionProvider.notifier).addSportCoins(30);
            },
          ),
        );

      case UserRole.scout:
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
            label: const Text('Asistir como Scout', style: TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Visita agendada.')));
            },
          ),
        );

      case UserRole.journalist:
      case UserRole.fan:
        return SizedBox(
          width: double.infinity,
          height: 44,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: muted,
              side: BorderSide(color: muted),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('Cubrir evento'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Solicitud aprobada.')));
            },
          ),
        );

      case UserRole.tutor:
        return Center(child: Text('TUTOR: Las peticiones de pago llegarán aquí.', style: TextStyle(color: muted, fontSize: 11)));
        
      case UserRole.coach:
      case UserRole.staff:
      case UserRole.brand:
        if (match.creatorId == currentUser!.id) {
           return SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surface(isDark),
                foregroundColor: AppColors.text(isDark),
                elevation: 0,
                side: BorderSide(color: AppColors.border(isDark)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => MatchManagementDashboard(matchId: match.id)),
                );
              },
              child: const Text('Gestionar Mi Partido', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
        }
        return Center(child: Text('EVENTO DE OTRO ORGANIZADOR', style: TextStyle(color: muted, fontSize: 10, letterSpacing: 1, fontWeight: FontWeight.bold)));
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _InfoRow({required this.icon, required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted(isDark)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
