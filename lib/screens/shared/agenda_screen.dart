import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';
import '../../providers/all_users_provider.dart';
import '../../models/app_user.dart';
import '../referee_terminal_screen.dart';

class AgendaMatch {
  final String id;
  final String title;
  final DateTime date;
  final String location;
  final String country;
  final String city;
  final int minAge;
  final String category;

  AgendaMatch(this.id, this.title, this.date, this.location, this.country, this.city, this.minAge, this.category);
}

final agendaProvider = Provider<List<AgendaMatch>>((ref) {
  return [
    AgendaMatch('M1', 'Madrid U19 Summer Cup', DateTime.now().add(const Duration(days: 1)), 'Estadio Bernabéu', 'España', 'Madrid', 17, 'Sub-19'),
    AgendaMatch('M2', 'Barcelona Youth League', DateTime.now().add(const Duration(days: 3)), 'Camp Nou Annex', 'España', 'Barcelona', 14, 'Sub-15'),
    AgendaMatch('M3', 'Regional Clasificatorio', DateTime.now().add(const Duration(days: 7)), 'Polideportivo Sur', 'Argentina', 'Buenos Aires', 26, 'Absoluta'),
    AgendaMatch('M4', 'Copa Libertadores Joven', DateTime.now().add(const Duration(days: 12)), 'Maracaná', 'Brasil', 'Río de Janeiro', 20, 'Sub-21'),
    AgendaMatch('M5', 'Torneo de Invierno', DateTime.now().add(const Duration(days: 15)), 'Wanda Metropolitano', 'España', 'Madrid', 16, 'Sub-17'),
    AgendaMatch('M6', 'Superliga Amateur', DateTime.now().add(const Duration(days: 20)), 'La Bombonera', 'Argentina', 'Buenos Aires', 23, 'Amateur'),
  ];
});

class AgendaScreen extends ConsumerStatefulWidget {
  const AgendaScreen({super.key});

  @override
  ConsumerState<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends ConsumerState<AgendaScreen> {
  String _selectedCountry = 'Todos';
  String _selectedCity = 'Todas';
  String _selectedAge = 'Cualquier Grupo';

  final List<String> _countries = ['Todos', 'España', 'Argentina', 'Brasil'];
  final List<String> _cities = ['Todas', 'Madrid', 'Barcelona', 'Buenos Aires', 'Río de Janeiro'];
  final List<String> _ages = ['Cualquier Grupo', '13-15 años', '16-18 años', '19-21 años', '22-25 años', '26+ años'];

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);

    final allMatches = ref.watch(agendaProvider);
    final sessionUser = ref.watch(sessionProvider);

    // Filter Logic
    final filteredMatches = allMatches.where((m) {
      if (_selectedCountry != 'Todos' && m.country != _selectedCountry) return false;
      if (_selectedCity != 'Todas' && m.city != _selectedCity) return false;
      if (_selectedAge != 'Cualquier Grupo') {
        if (_selectedAge == '13-15 años' && (m.minAge < 13 || m.minAge > 15)) return false;
        if (_selectedAge == '16-18 años' && (m.minAge < 16 || m.minAge > 18)) return false;
        if (_selectedAge == '19-21 años' && (m.minAge < 19 || m.minAge > 21)) return false;
        if (_selectedAge == '22-25 años' && (m.minAge < 22 || m.minAge > 25)) return false;
        if (_selectedAge == '26+ años' && m.minAge < 26) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AGENDA DE PLAYERS',
                    style: TextStyle(
                      color: AppColors.textMuted(isDark),
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Matchmaking Button (Only for +21)
                  if (sessionUser?.ageGroup == '+21 años') ...[
                    GestureDetector(
                      onTap: () => _showMatchmakingDialog(context, isDark),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.buttonBg(isDark), AppColors.buttonBg(isDark).withValues(alpha: 0.7)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.buttonBg(isDark).withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                              child: const Icon(Icons.radar_outlined, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Modo Clasificatorio (Ranked)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                  Text('Busca un partido de tu nivel (Auto-Balance)', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12, height: 1.4)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  Text(
                    'Calendario Global',
                    style: TextStyle(
                      color: text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Filters
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  _FilterDropdown(
                    label: 'País',
                    value: _selectedCountry,
                    items: _countries,
                    isDark: isDark,
                    onChanged: (val) => setState(() {
                      _selectedCountry = val!;
                      _selectedCity = 'Todas'; // Reset city if country changes (simplified)
                    }),
                  ),
                  const SizedBox(width: 12),
                  _FilterDropdown(
                    label: 'Ciudad',
                    value: _selectedCity,
                    items: _cities,
                    isDark: isDark,
                    onChanged: (val) => setState(() => _selectedCity = val!),
                  ),
                  const SizedBox(width: 12),
                  _FilterDropdown(
                    label: 'Edad Min',
                    value: _selectedAge,
                    items: _ages,
                    isDark: isDark,
                    onChanged: (val) => setState(() => _selectedAge = val!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Match List
            Expanded(
              child: filteredMatches.isEmpty
                  ? Center(
                      child: Text(
                        'No hay eventos para estos filtros.',
                        style: TextStyle(color: muted, fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: filteredMatches.length,
                      itemBuilder: (context, index) {
                        final m = filteredMatches[index];
                        return _PremiumAgendaCard(
                          match: m,
                          isDark: isDark,
                          sessionUser: sessionUser,
                          onAction: () {
                            if (sessionUser?.role.name == 'referee') {
                              _showLineupSelector(context, ref, m, isDark);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Partido: ${m.title} añadido a recordatorios.', style: TextStyle(color: text)),
                                  backgroundColor: surface,
                                ),
                              );
                            }
                          },
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
         return usersAsync.when(
           data: (users) {
             final players = users.where((u) => u.role.name == 'player').toList();
             return Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(24),
                   child: Text(
                     'Designación: ¿A quién evaluarás?',
                     style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold),
                   ),
                 ),
                 Expanded(
                   child: ListView.builder(
                     itemCount: players.length,
                     itemBuilder: (c, i) {
                       final p = players[i];
                       return ListTile(
                         leading: CircleAvatar(
                           backgroundColor: AppColors.bg(isDark),
                           child: Icon(Icons.sports_soccer, color: text, size: 18),
                         ),
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

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: value != items.first ? AppColors.buttonBg(isDark).withValues(alpha: 0.1) : AppColors.surface(isDark),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: value != items.first ? AppColors.buttonBg(isDark) : AppColors.border(isDark),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          icon: Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted(isDark), size: 16),
          dropdownColor: AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(16),
          style: TextStyle(
            color: value != items.first ? AppColors.buttonBg(isDark) : AppColors.text(isDark),
            fontWeight: value != items.first ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
          items: items.map((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val == items.first ? label : val),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PremiumAgendaCard extends StatelessWidget {
  final AgendaMatch match;
  final bool isDark;
  final AppUser? sessionUser;
  final VoidCallback onAction;

  const _PremiumAgendaCard({
    required this.match,
    required this.isDark,
    required this.sessionUser,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final primary = AppColors.buttonBg(isDark);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onAction,
          child: Padding(
            padding: const EdgeInsets.all(22),
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
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        match.category.toUpperCase(),
                        style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 10, letterSpacing: 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _InfoRow(icon: Icons.public, text: '${match.city}, ${match.country}', isDark: isDark),
                _InfoRow(icon: Icons.location_on_outlined, text: match.location, isDark: isDark),
                _InfoRow(icon: Icons.calendar_today_outlined, text: DateFormat('EEE, d MMM • HH:mm').format(match.date), isDark: isDark),
                _InfoRow(icon: Icons.cake_outlined, text: 'Edad Mínima: ${match.minAge} años', isDark: isDark),
                
                const SizedBox(height: 16),
                Divider(color: border, height: 1),
                const SizedBox(height: 12),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      sessionUser?.role.name == 'referee' ? 'Evaluar →' : 'Agendar →',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

void _showMatchmakingDialog(BuildContext context, bool isDark) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => const _MatchmakingModal(),
  );
}

class _MatchmakingModal extends StatefulWidget {
  const _MatchmakingModal();
  @override
  State<_MatchmakingModal> createState() => _MatchmakingModalState();
}

class _MatchmakingModalState extends State<_MatchmakingModal> {
  bool _found = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      setState(() => _found = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Dialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_found) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('Buscando Jugadores...', style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Balanceando Técnica y Resistencia usando Inteligencia Artificial para el mejor partido posible.', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 13, height: 1.4)),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar Búsqueda', style: TextStyle(color: Colors.red)),
              )
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 16),
              Text('¡Partido Encontrado!', style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Partido Oficial SLP-0442\nÁrbitro Asignado: Confirmado\nCuota de Entrada: 15 SC', textAlign: TextAlign.center, style: TextStyle(color: muted, fontSize: 13, height: 1.5)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonBg(isDark),
                    foregroundColor: AppColors.buttonFg(isDark),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: AppColors.buttonBg(isDark), content: Text('Has ingresado al partido con éxito', style: TextStyle(color: AppColors.buttonFg(isDark)))));
                  },
                  child: const Text('Aceptar y Pagar Cuota', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

