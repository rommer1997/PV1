import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Mensajes',
          style: TextStyle(color: text, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.separated(
        itemCount: 3,
        separatorBuilder: (_, __) => Divider(color: border),
        itemBuilder: (context, i) {
          final users = ['Elena Vance', 'Coach Carlos', 'Nike Football'];
          final messages = [
            '¿Podemos agendar una entrevista?',
            'He visto tus métricas, me interesa tu perfil.',
            'Queremos enviarte unos botines de prueba.'
          ];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surface(isDark),
              child: Icon(Icons.person, color: muted),
            ),
            title: Text(
              users[i],
              style: TextStyle(color: text, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              messages[i],
              style: TextStyle(color: muted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              'Hace 1h',
              style: TextStyle(color: muted, fontSize: 12),
            ),
            onTap: () {
              // TODO: Implement individual chat
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat no implementado en mock')),
              );
            },
          );
        },
      ),
    );
  }
}
