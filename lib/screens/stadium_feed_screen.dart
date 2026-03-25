import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../widgets/video_highlight_card.dart';
import '../providers/match_evaluations_provider.dart';
import '../providers/articles_provider.dart';

class StadiumFeedScreen extends ConsumerStatefulWidget {
  const StadiumFeedScreen({super.key});

  @override
  ConsumerState<StadiumFeedScreen> createState() => _StadiumFeedScreenState();
}

class _StadiumFeedScreenState extends ConsumerState<StadiumFeedScreen> {
  String _selectedFilter = 'Todo';

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final bg = AppColors.bg(isDark);
    final border = AppColors.border(isDark);
    final surface = AppColors.surface(isDark);
    final muted = AppColors.textMuted(isDark);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STADIUM FEED',
                      style: TextStyle(
                        color: muted,
                        fontSize: 11,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Composer snippet
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: surface,
                            border: Border.all(color: border),
                          ),
                          child: Icon(Icons.person, color: muted, size: 22),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: surface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '¿Qué está pasando en el campo?',
                                  style: TextStyle(color: muted, fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                                Icon(Icons.photo_library_outlined, color: AppColors.buttonBg(isDark), size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: Row(
                        children: [
                          _Pill(label: 'Todo', isSelected: _selectedFilter == 'Todo', isDark: isDark, onTap: () => setState(() => _selectedFilter = 'Todo')),
                          const SizedBox(width: 12),
                          _Pill(label: 'Fichajes', isSelected: _selectedFilter == 'Fichajes', isDark: isDark, onTap: () => setState(() => _selectedFilter = 'Fichajes')),
                          const SizedBox(width: 12),
                          _Pill(label: 'Torneos', isSelected: _selectedFilter == 'Torneos', isDark: isDark, onTap: () => setState(() => _selectedFilter = 'Torneos')),
                          const SizedBox(width: 12),
                          _Pill(label: 'Periodistas', isSelected: _selectedFilter == 'Periodistas', isDark: isDark, onTap: () => setState(() => _selectedFilter = 'Periodistas')),
                          const SizedBox(width: 12),
                          _Pill(label: 'VOD', isSelected: _selectedFilter == 'VOD', isDark: isDark, onTap: () => setState(() => _selectedFilter = 'VOD')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (_selectedFilter == 'Todo' || _selectedFilter == 'Fichajes') ...[
                    _PremiumFeedCard(
                      authorName: 'SLP Transfer Market',
                      authorRole: 'Agente Oficial',
                      category: 'FICHAJE',
                      title: 'Acuerdo Cerrado: Nuevo Talento',
                      body: 'El contrato deportivo del jugador @SLP_0982 ha sido formalizado y emitido exitosamente mediante contrato inteligente. Otro hito validado en la red. #FichajesSLP #NextGen',
                      time: 'Hace 2 h',
                      likes: 124,
                      comments: 18,
                      isDark: isDark,
                      icon: Icons.handshake_outlined,
                      highlightColor: Colors.blueAccent,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedFilter == 'Todo' || _selectedFilter == 'Periodistas') ...[
                    Consumer(
                      builder: (context, ref, _) {
                        final articles = ref.watch(articlesProvider);
                        return Column(
                          children: articles.map((article) => Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _PremiumFeedCard(
                              authorName: article.authorName,
                              authorRole: 'Periodista Validado',
                              category: 'CRÓNICA',
                              title: article.title,
                              body: article.content,
                              time: 'Reciente',
                              likes: article.likes,
                              comments: 12,
                              isDark: isDark,
                              icon: Icons.campaign_outlined,
                              highlightColor: Colors.green,
                            ),
                          )).toList(),
                        );
                      },
                    ),
                  ],

                  if (_selectedFilter == 'Todo' || _selectedFilter == 'Torneos') ...[
                    _PremiumFeedCard(
                      authorName: 'Liga Regional Juvenil',
                      authorRole: 'Organizador',
                      category: 'TORNEO',
                      title: 'Inscripciones Abiertas: Copa de Verano',
                      body: 'Atención a todos los scouts y @jugadores. La liga juvenil más grande de la región abrirá sus inscripciones. Los ojeadores de la primera división estarán observando. #CopaVerano #Scouting',
                      time: 'Hace 5 h',
                      likes: 340,
                      comments: 52,
                      isDark: isDark,
                      icon: Icons.emoji_events_outlined,
                      highlightColor: Colors.amber,
                      hasImage: true,
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_selectedFilter == 'Todo' || _selectedFilter == 'VOD') ...[
                    VideoHighlightCard(
                      title: 'Las Mejores Salvadas de la Jornada 5',
                      description: 'Revive los momentos más impresionantes de la liga. Material bruto SLP VEO para que jugadores y fans revivan el show.',
                      matchDate: 'Hace 4 h',
                      isDark: isDark,
                      canAdjustStats: false,
                      canBroadcast: false,
                      onAdjustStats: () {},
                      onShareToFeed: () {},
                    ),
                    const SizedBox(height: 20),
                  ],

                if (_selectedFilter == 'Todo' || _selectedFilter == 'Fichajes' || _selectedFilter == 'Periodistas') ...[
                  _BrandSponsoredCard(isDark: isDark),
                  const SizedBox(height: 20),
                ],
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.buttonBg(isDark) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.buttonBg(isDark) : AppColors.border(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.buttonFg(isDark) : AppColors.textMuted(isDark),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _PremiumFeedCard extends StatefulWidget {
  final String authorName, authorRole, category, title, body, time;
  final int likes, comments;
  final bool isDark;
  final IconData icon;
  final Color highlightColor;
  final bool hasImage;

  const _PremiumFeedCard({
    required this.authorName,
    required this.authorRole,
    required this.category,
    required this.title,
    required this.body,
    required this.time,
    required this.likes,
    required this.comments,
    required this.isDark,
    required this.icon,
    required this.highlightColor,
    this.hasImage = false,
  });

  @override
  State<_PremiumFeedCard> createState() => _PremiumFeedCardState();
}

class _PremiumFeedCardState extends State<_PremiumFeedCard> {
  bool _isLiked = false;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.likes;
  }

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(widget.isDark);
    final border = AppColors.border(widget.isDark);
    final text = AppColors.text(widget.isDark);
    final muted = AppColors.textMuted(widget.isDark);

    return Container(
      width: double.infinity,
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
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bg(widget.isDark),
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: Icon(widget.icon, color: widget.highlightColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          widget.authorRole,
                          style: TextStyle(color: muted, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Text(' • ${widget.time}', style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_horiz, color: muted),
            ],
          ),
          const SizedBox(height: 18),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: widget.highlightColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.category.toUpperCase(),
              style: TextStyle(color: widget.highlightColor, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            widget.title,
            style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          _StyledContentText(
            text: widget.body,
            baseStyle: TextStyle(color: muted, fontSize: 14, height: 1.5, fontWeight: FontWeight.w500),
            isDark: widget.isDark,
          ),
          
          if (widget.hasImage) ...[
            const SizedBox(height: 16),
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [widget.highlightColor.withValues(alpha: 0.8), widget.highlightColor.withValues(alpha: 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Icon(Icons.stadium_rounded, color: Colors.white.withValues(alpha: 0.8), size: 56),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Divider(color: border, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SocialButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '$_likeCount',
                color: _isLiked ? Colors.redAccent : muted,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _isLiked ? _likeCount++ : _likeCount--;
                  });
                },
              ),
              _SocialButton(
                icon: Icons.chat_bubble_outline,
                label: '${widget.comments}',
                color: muted,
                onTap: () {},
              ),
              _SocialButton(
                icon: Icons.share_outlined,
                label: 'Compartir',
                color: muted,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalistInteractiveCard extends StatefulWidget {
  final bool isDark;
  const _JournalistInteractiveCard({required this.isDark});

  @override
  State<_JournalistInteractiveCard> createState() => _JournalistInteractiveCardState();
}

class _JournalistInteractiveCardState extends State<_JournalistInteractiveCard> {
  int _donated = 0;
  bool _isLiked = false;
  int _likeCount = 89;

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surface(widget.isDark);
    final border = AppColors.border(widget.isDark);
    final text = AppColors.text(widget.isDark);
    final muted = AppColors.textMuted(widget.isDark);

    return Container(
      width: double.infinity,
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bg(widget.isDark),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.campaign_outlined, color: muted, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elena Vance',
                      style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.3),
                    ),
                    Row(
                      children: [
                        Text('Periodista Validada', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(' • Hace 3 h', style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          
          Consumer(
            builder: (context, ref, _) {
              final evals = ref.watch(matchEvaluationsProvider);
              final latest = evals.firstOrNull;
              final msg = latest != null 
                ? 'Impresionante exhibición de @${latest.playerId} en el ${latest.matchName}. Técnica de ${latest.tecnica.toStringAsFixed(1)} validada inmutablemente. #NextGen'
                : 'Analizando las promesas del fútbol regional. Los datos del árbitro son la única fuente de verdad. ¿Quién será el próximo en destacar? #SportLink';
              
              return _StyledContentText(
                text: msg,
                baseStyle: TextStyle(color: text, fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                isDark: widget.isDark,
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Donation Area
          GestureDetector(
            onTap: () {
              setState(() => _donated += 5);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Aportaste 5 SC a Elena ✓', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.buttonBg(widget.isDark),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _donated > 0 ? Colors.amber.withValues(alpha: 0.1) : AppColors.bg(widget.isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _donated > 0 ? Colors.amber.withValues(alpha: 0.5) : border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.workspace_premium_outlined, color: _donated > 0 ? Colors.amber : muted, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _donated > 0 ? '$_donated SC Apoyados' : 'Respaldar Análisis Periodístico',
                    style: TextStyle(color: _donated > 0 ? Colors.amber : text, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          Divider(color: border, height: 1),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SocialButton(
                icon: _isLiked ? Icons.favorite : Icons.favorite_border,
                label: '$_likeCount',
                color: _isLiked ? Colors.redAccent : muted,
                onTap: () {
                  setState(() {
                    _isLiked = !_isLiked;
                    _isLiked ? _likeCount++ : _likeCount--;
                  });
                },
              ),
              _SocialButton(
                icon: Icons.chat_bubble_outline,
                label: '24',
                color: muted,
                onTap: () {},
              ),
              _SocialButton(
                icon: Icons.share_outlined,
                label: 'Compartir',
                color: muted,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StyledContentText extends StatelessWidget {
  final String text;
  final TextStyle baseStyle;
  final bool isDark;

  const _StyledContentText({
    required this.text,
    required this.baseStyle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final words = text.split(' ');
    final spans = <InlineSpan>[];
    
    final highlightColor = isDark ? const Color(0xFF007AFF) : const Color(0xFF005bb5); 
    
    for (int i = 0; i < words.length; i++) {
      final w = words[i];
      if (w.startsWith('#') || w.startsWith('@')) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Explorar: $w', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    backgroundColor: AppColors.bg(isDark),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                w,
                style: baseStyle.copyWith(
                  color: highlightColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          )
        );
      } else {
        spans.add(TextSpan(text: w, style: baseStyle));
      }
      if (i < words.length - 1) spans.add(const TextSpan(text: ' '));
    }

    return RichText(text: TextSpan(children: spans));
  }
}

class _BrandSponsoredCard extends StatelessWidget {
  final bool isDark;
  const _BrandSponsoredCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final border = AppColors.border(isDark);
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1E1E1E), const Color(0xFF121212)]
              : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF4CA25).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: border),
                ),
                child: const Icon(Icons.bolt, color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Nike SportLink Elite',
                          style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ],
                    ),
                    Text('Patrocinador Oficial', style: TextStyle(color: muted, fontSize: 11)),
                  ],
                ),
              ),
              const Text('PUBLICIDAD', style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '¿Crees que tienes lo necesario?',
            style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Estamos buscando al próximo MVP de la Copa Sub-19. Los jugadores con un OVR superior a 85 en Técnica (TEC) recibirán un kit exclusivo de entrenamiento. ¡Sigue validando tus stats!',
            style: TextStyle(color: muted, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4CA25),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () {},
              child: const Text('Postular mi perfil', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}
