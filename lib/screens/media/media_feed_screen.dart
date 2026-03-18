import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/media_post.dart';
import '../../providers/theme_provider.dart';
import 'create_post_screen.dart';

class MediaFeedScreen extends ConsumerStatefulWidget {
  const MediaFeedScreen({super.key});

  @override
  ConsumerState<MediaFeedScreen> createState() => _MediaFeedScreenState();
}

class _MediaFeedScreenState extends ConsumerState<MediaFeedScreen> {
  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(mediaFeedProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Dark immersive bg for Reels
      body: Stack(
        children: [
          // Feed Principal
          _ReelsFeed(
            posts: posts,
            isDark: true, // Always dark for immersive media
          ),

          // Header Flotante
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'SportLink Reels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Botón publicar
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreatePostScreen(),
                        ),
                      ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══ REELS — Scroll vertical fullscreen estilo TikTok ═════════════════════════
class _ReelsFeed extends ConsumerWidget {
  final List<MediaPost> posts;
  final bool isDark;
  const _ReelsFeed({required this.posts, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (posts.isEmpty) {
      return _EmptyState(
        isDark: isDark,
        icon: Icons.movie_creation_outlined,
        label: 'Sube tu primer Reel',
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (ctx, i) => _ReelCard(post: posts[i], isDark: isDark),
    );
  }
}

class _ReelCard extends ConsumerWidget {
  final MediaPost post;
  final bool isDark;
  const _ReelCard({required this.post, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppColors.text(isDark);
    final muted = AppColors.textMuted(isDark);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo del reel
        Container(
          color: Colors.black,
          child: post.hasFile
              ? Image.file(
                  File(post.filePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.movie_creation_outlined,
                        color: Colors.white38,
                        size: 72,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '✨ Reel Deportivo',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
        ),

        // Gradiente inferior
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black, Colors.transparent],
              ),
            ),
          ),
        ),

        // Info del autor y caption
        Positioned(
          left: 20,
          right: 80,
          bottom: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A1A),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white38,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        post.authorUniqueId,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.caption.isNotEmpty ? post.caption : '✨ Reel deportivo',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                post.hashtags.join(' '),
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),

        // Botones laterales (like, comentarios, compartir)
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            children: [
              _ReelAction(
                icon: Icons.favorite,
                label: '${post.likes}',
                onTap: () =>
                    ref.read(mediaFeedProvider.notifier).toggleLike(post.id),
              ),
              const SizedBox(height: 22),
              _ReelAction(
                icon: Icons.chat_bubble_rounded,
                label: '${post.comments}',
                onTap: () {},
              ),
              const SizedBox(height: 22),
              _ReelAction(
                icon: Icons.share_outlined,
                label: 'Compartir',
                onTap: () {},
              ),
              const SizedBox(height: 22),
              _ReelAction(
                icon: Icons.verified,
                label: post.authorUniqueId,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ReelAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ══ Detalle de post en modal ═══════════════════════════════════════════════════

// ══ Estado vacío ══════════════════════════════════════════════════════════════
class _EmptyState extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String label;
  const _EmptyState({
    required this.isDark,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textMuted(isDark), size: 48),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ══ FAB de creación rápida ════════════════════════════════════════════════════
class _CreateFAB extends StatefulWidget {
  final bool isDark;
  const _CreateFAB({required this.isDark});
  @override
  State<_CreateFAB> createState() => _CreateFABState();
}

class _CreateFABState extends State<_CreateFAB>
    with SingleTickerProviderStateMixin {
  bool _open = false;
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _open = !_open);
    _open ? _anim.forward() : _anim.reverse();
  }

  void _open0(MediaType t) {
    _toggle();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CreatePostScreen(initialType: t)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_open) ...[
          _MiniButton(
            label: '✨ Reel',
            isDark: widget.isDark,
            onTap: () => _open0(MediaType.reel),
          ),
          const SizedBox(height: 10),
          _MiniButton(
            label: '🎬 Vídeo',
            isDark: widget.isDark,
            onTap: () => _open0(MediaType.video),
          ),
          const SizedBox(height: 10),
          _MiniButton(
            label: '📷 Foto',
            isDark: widget.isDark,
            onTap: () => _open0(MediaType.photo),
          ),
          const SizedBox(height: 10),
        ],
        FloatingActionButton(
          onPressed: _toggle,
          backgroundColor: AppColors.buttonBg(widget.isDark),
          foregroundColor: AppColors.buttonFg(widget.isDark),
          child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _anim),
        ),
      ],
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _MiniButton({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.buttonBg(isDark),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.buttonFg(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
