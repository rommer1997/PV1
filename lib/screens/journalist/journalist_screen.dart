import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/app_user.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/help_button.dart';

class JournalistScreen extends ConsumerStatefulWidget {
  const JournalistScreen({super.key});

  @override
  ConsumerState<JournalistScreen> createState() => _JournalistScreenState();
}

class _JournalistScreenState extends ConsumerState<JournalistScreen> {
  final _textCtrl = TextEditingController();
  bool _publishing = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _publish(bool isDark) async {
    if (_textCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe algo antes de publicar')),
      );
      return;
    }
    setState(() => _publishing = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _publishing = false;
      _textCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✓ Crónica publicada y visible en el feed')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final user = ref.watch(sessionProvider);
    final bg = AppColors.bg(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);
    final surface = AppColors.surface(isDark);
    final border = AppColors.border(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PERIODISTA',
                    style: TextStyle(
                      color: muted,
                      fontSize: 11,
                      letterSpacing: 3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const HelpButton(screenKey: 'journalist'),
                ],
              ),
              const SizedBox(height: 24),

              // Perfil
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: surface,
                      border: Border.all(color: border),
                    ),
                    child: Icon(Icons.person, color: muted, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? 'Elena Vance',
                        style: TextStyle(
                          color: text,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        '${user?.followersCount ?? 0} seguidores · ${user?.sportcoins ?? 0} SC',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // Editor
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PUBLICAR CRÓNICA',
                      style: TextStyle(
                        color: muted,
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textCtrl,
                      style: TextStyle(color: text, fontSize: 16, height: 1.6),
                      maxLines: 5,
                      decoration: InputDecoration.collapsed(
                        hintText: 'Escribe tu análisis del partido...',
                        hintStyle: TextStyle(color: muted),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(Icons.attach_file, color: muted, size: 20),
                        GestureDetector(
                          onTap: _publishing ? null : () => _publish(isDark),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _publishing
                                  ? surface
                                  : AppColors.buttonBg(isDark),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: _publishing
                                ? SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.buttonFg(isDark),
                                    ),
                                  )
                                : Text(
                                    'PUBLICAR',
                                    style: TextStyle(
                                      color: AppColors.buttonFg(isDark),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),
              Text(
                'MIS PUBLICACIONES',
                style: TextStyle(
                  color: muted,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _Article(
                title: 'Análisis táctico: Real Madrid Sub-19',
                preview:
                    'La presión alta del equipo fue clave para dominar el mediocampo durante los primeros 70 minutos...',
                tips: '45 SC',
                timeAgo: 'Hace 3 h',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _Article(
                title: 'Top 5 Talentos Validados de la Temporada',
                preview:
                    'Según los datos inmutables de SportLink Pro, estos son los cinco jugadores con mayor calificación certificada...',
                tips: '210 SC',
                timeAgo: 'Hace 2 d',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Article extends StatelessWidget {
  final String title, preview, tips, timeAgo;
  final bool isDark;
  const _Article({
    required this.title,
    required this.preview,
    required this.tips,
    required this.timeAgo,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
              Text(
                timeAgo,
                style: TextStyle(
                  color: AppColors.textMuted(isDark),
                  fontSize: 11,
                ),
              ),
              Text(
                '$tips recibidos',
                style: TextStyle(
                  color: const Color(0xFF34C759),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 17,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            preview,
            style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
