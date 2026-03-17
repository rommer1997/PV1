import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/all_users_provider.dart';
import '../../models/app_user.dart';
import 'athletic_cv_screen.dart';
import 'shared/chat_list_screen.dart';

class StadiumFeedScreen extends ConsumerWidget {
  const StadiumFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FEED',
                        style: TextStyle(
                          color: muted,
                          fontSize: 11,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Stadium Feed',
                        style: TextStyle(
                          color: text,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // Chat / Mensajes
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ChatListScreen()),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Icon(Icons.chat_bubble_outline, color: muted, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Búsqueda
                      GestureDetector(
                        onTap: () async {
                          final users = await ref.read(allUsersProvider.future);
                          if (!context.mounted) return;
                          showSearch(
                            context: context,
                            delegate: _FeedSearch(users: users, isDark: isDark),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Icon(Icons.search, color: muted, size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Notificaciones
                      GestureDetector(
                        onTap: () => _showNotifications(context, isDark),
                        child: Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: border),
                              ),
                              child: Icon(
                                Icons.notifications_none,
                                color: muted,
                                size: 20,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Menu Lateral para Configuración (Tema/Salir)
                      GestureDetector(
                        onTap: () {
                          // Buscar el Scaffold ancestro más cercano que tenga el endDrawer (RoleShell)
                          context.findAncestorStateOfType<ScaffoldState>()?.openEndDrawer();
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.buttonBg(isDark),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.menu, color: AppColors.buttonFg(isDark), size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Filtros
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  'Todo',
                  'Fichajes',
                  'Torneos',
                  'Periodistas',
                ].map((f) => _Pill(f, f == 'Todo', isDark)).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Contenido
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                children: [
                  _FeedCard(
                    category: 'FICHAJE',
                    title: 'Oferta de Escrow Aceptada',
                    body:
                        'El tutor de SLP-0982 aprobó la oferta. El 10% de comisión ha sido retenido automáticamente.',
                    time: 'Hace 2 h',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),
                  _JournalistCard(isDark: isDark),
                  const SizedBox(height: 18),
                  _FeedCard(
                    category: 'TORNEO',
                    title: 'Madrid U19 Summer Cup',
                    body:
                        "Torneo oficial patrocinado por Nike. Las predicciones del público generaron 14,000 SC en recompensas.",
                    time: 'Hace 5 h',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 18),
                  _FeedCard(
                    category: 'FICHAJE',
                    title: 'Nuevo Talento Validado',
                    body:
                        'SLP-1241 ha alcanzado 5 evaluaciones certificadas y recibe el badge de Talento Oficial.',
                    time: 'Hace 1 d',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Módulo de creación de posts en desarrollo'),
              backgroundColor: AppColors.buttonBg(isDark),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
        backgroundColor: AppColors.buttonBg(isDark),
        child: Icon(Icons.add, color: AppColors.buttonFg(isDark)),
      ),
    );
  }

  void _showNotifications(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Notificaciones',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _NotifRow(
              '⚽ Marco Silva recibió oferta de Real Madrid',
              'Hace 2 h',
              isDark,
            ),
            _NotifRow(
              '🏆 Madrid U19 Cup — Resultados publicados',
              'Hace 5 h',
              isDark,
            ),
            _NotifRow(
              '🎙️ Elena Vance publicó nueva crónica',
              'Hace 1 d',
              isDark,
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _NotifRow extends StatelessWidget {
  final String text;
  final String time;
  final bool isDark;
  const _NotifRow(this.text, this.time, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.text(isDark), fontSize: 13),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            time,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool sel;
  final bool isDark;
  const _Pill(this.label, this.sel, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: sel ? AppColors.buttonBg(isDark) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: sel ? AppColors.buttonBg(isDark) : AppColors.border(isDark),
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: sel
                ? AppColors.buttonFg(isDark)
                : AppColors.textMuted(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  final String category, title, body, time;
  final bool isDark;
  const _FeedCard({
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
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
              Text(
                category,
                style: TextStyle(
                  color: AppColors.textMuted(isDark),
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: AppColors.textMuted(isDark),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalistCard extends StatefulWidget {
  final bool isDark;
  const _JournalistCard({required this.isDark});
  @override
  State<_JournalistCard> createState() => _JournalistCardState();
}

class _JournalistCardState extends State<_JournalistCard> {
  int _donated = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface(widget.isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(widget.isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg(widget.isDark),
                ),
                child: Icon(
                  Icons.person,
                  color: AppColors.textMuted(widget.isDark),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elena Vance',
                    style: TextStyle(
                      color: AppColors.text(widget.isDark),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Periodista · Hace 3 h',
                    style: TextStyle(
                      color: AppColors.textMuted(widget.isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Impresionante exhibición táctica del Atletico hoy. Los datos del árbitro ya están en la base de datos inmutable.',
            style: TextStyle(
              color: AppColors.textMuted(widget.isDark),
              fontSize: 13,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() => _donated += 5);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Donaste 5 SC a Elena ✓'),
                  backgroundColor: Colors.white10,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(
                  Icons.volunteer_activism_outlined,
                  color: AppColors.textMuted(widget.isDark),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'Donar SportCoins${_donated > 0 ? ' · $_donated SC enviados' : ''}',
                  style: TextStyle(
                    color: AppColors.textMuted(widget.isDark),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Búsqueda
class _FeedSearch extends SearchDelegate {
  final List<AppUser> users;
  final bool isDark;
  _FeedSearch({required this.users, required this.isDark});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg(isDark),
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
        elevation: 0,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
      ),
      scaffoldBackgroundColor: AppColors.bg(isDark),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: Icon(Icons.clear, color: AppColors.text(isDark)),
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back, color: AppColors.text(isDark)),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    final f = query.isEmpty
        ? users
        : users
              .where(
                (u) =>
                    u.name.toLowerCase().contains(query.toLowerCase()) ||
                    u.uniqueId.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();

    return Container(
      color: AppColors.bg(isDark),
      child: ListView.builder(
        itemCount: f.length,
        itemBuilder: (context, i) {
          final u = f[i];
          final muted = AppColors.textMuted(isDark);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surface(isDark),
              child: Icon(Icons.person, color: muted, size: 18),
            ),
            title: Text(
              u.name,
              style: TextStyle(
                color: AppColors.text(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${u.uniqueId} · ${u.role.name.toUpperCase()}',
              style: TextStyle(color: muted, fontSize: 11),
            ),
            trailing: u.isVerified
                ? const Icon(Icons.verified, color: Colors.green, size: 16)
                : null,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AthleticCVScreen(viewedUser: u),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
