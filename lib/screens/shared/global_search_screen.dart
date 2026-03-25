import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/all_users_provider.dart';
import '../../providers/theme_provider.dart';
import '../fish_card_screen.dart';

class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});
  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final surface = AppColors.surface(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                style: TextStyle(color: text),
                decoration: InputDecoration(
                  hintText: 'Buscar jugador, marca, scout...',
                  hintStyle: TextStyle(color: muted),
                  prefixIcon: Icon(Icons.search, color: muted),
                  filled: true,
                  fillColor: surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            ),
            Expanded(
              child: usersAsync.when(
                data: (users) {
                  final filtered = users.where((u) {
                    final q = _query;
                    return q.isEmpty ||
                           u.name.toLowerCase().contains(q) ||
                           u.uniqueId.toLowerCase().contains(q);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('No hay resultados', style: TextStyle(color: muted)),
                    );
                  }

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final u = filtered[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: surface,
                          child: Icon(Icons.person, color: text),
                        ),
                        title: Text(u.name, style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                        subtitle: Text('${u.role.name.toUpperCase()} · ${u.uniqueId}', style: TextStyle(color: muted, fontSize: 12)),
                        trailing: Icon(Icons.chevron_right, color: muted),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FishCardScreen(viewedUser: u),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
