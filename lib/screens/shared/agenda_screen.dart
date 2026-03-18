import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/all_users_provider.dart';
import '../../models/app_user.dart';
import '../referee_terminal_screen.dart';

class AgendaMatch {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  AgendaMatch(this.id, this.title, this.date, this.location);
}

final agendaProvider = Provider<List<AgendaMatch>>((ref) {
  return [
    AgendaMatch('M1', 'Madrid U19 Summer Cup', DateTime.now().add(const Duration(days: 1)), 'Estadio Bernabéu'),
    AgendaMatch('M2', 'Barcelona Youth League', DateTime.now().add(const Duration(days: 3)), 'Camp Nou Annex'),
    AgendaMatch('M3', 'Regional Clasificatorio', DateTime.now().add(const Duration(days: 7)), 'Polideportivo Sur'),
  ];
});

class AgendaScreen extends ConsumerWidget {
  const AgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    final matches = ref.watch(agendaProvider);
    final sessionUser = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Calendario',
                style: TextStyle(
                  color: text,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: matches.length,
                itemBuilder: (context, index) {
                  final m = matches[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(m.title, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: muted),
                            const SizedBox(width: 4),
                            Text('${m.date.day}/${m.date.month} - ${m.location}', style: TextStyle(color: muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: muted),
                      onTap: () {
                        if (sessionUser?.role.name == 'referee') {
                          _showLineupSelector(context, ref, m, isDark);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Partido: ${m.title} añadido a recordatorios.', style: TextStyle(color: text))),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLineupSelector(BuildContext context, WidgetRef ref, AgendaMatch match, bool isDark) async {
    final usersAsync = ref.read(allUsersProvider);
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
         return usersAsync.when(
           data: (users) {
             final players = users.where((u) => u.role.name == 'player').toList();
             return Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(20),
                   child: Text('Designación: ¿A quién evaluarás?', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold)),
                 ),
                 Expanded(
                   child: ListView.builder(
                     itemCount: players.length,
                     itemBuilder: (c, i) {
                       final p = players[i];
                       return ListTile(
                         leading: CircleAvatar(backgroundColor: AppColors.bg(isDark), child: Icon(Icons.sports_soccer, color: text, size: 18)),
                         title: Text(p.name, style: TextStyle(color: text, fontWeight: FontWeight.w600)),
                         subtitle: Text('ID: ${p.uniqueId}', style: TextStyle(color: muted, fontSize: 12)),
                         trailing: const Icon(Icons.gavel, color: Colors.amber, size: 20),
                         onTap: () {
                           Navigator.pop(ctx);
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => RefereeTerminalScreen(
                                 matchId: match.id,
                                 matchName: match.title,
                                 playerId: p.uniqueId,
                                 playerName: p.name,
                               ),
                             ),
                           );
                         },
                       );
                     },
                   ),
                 ),
               ],
             );
           },
           loading: () => const Center(child: CircularProgressIndicator()),
           error: (e, st) => Center(child: Text('Error: $e')),
         );
      }
    );
  }
}
