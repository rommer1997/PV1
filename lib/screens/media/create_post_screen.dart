import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/media_post.dart';
import '../../models/app_user.dart';
import '../../providers/theme_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final MediaType initialType;
  const CreatePostScreen({super.key, this.initialType = MediaType.photo});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionCtrl = TextEditingController();
  final _picker = ImagePicker();
  XFile? _mediaFile;
  MediaType _type = MediaType.photo;
  bool _uploading = false;
  bool _posted = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  Future<void> _pickMedia() async {
    XFile? file;
    if (_type == MediaType.photo) {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
    } else {
      file = await _picker.pickVideo(source: ImageSource.gallery);
    }
    if (file != null) setState(() => _mediaFile = file);
  }

  Future<void> _submit() async {
    if (_captionCtrl.text.trim().isEmpty && _mediaFile == null) return;
    setState(() => _uploading = true);

    await Future.delayed(const Duration(milliseconds: 1400)); // simula upload

    final user = ref.read(sessionProvider);
    final post = MediaPost(
      id: 'post-${DateTime.now().millisecondsSinceEpoch}',
      authorId: user?.id ?? 'demo',
      authorName: user?.name ?? 'Jugador Demo',
      authorUniqueId: user?.uniqueId ?? 'Cantera-0000',
      type: _type,
      filePath: _mediaFile?.path,
      caption: _captionCtrl.text.trim(),
      hashtags: _extractHashtags(_captionCtrl.text),
      createdAt: DateTime.now(),
    );

    ref.read(mediaFeedProvider.notifier).addPost(post);
    setState(() {
      _uploading = false;
      _posted = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) Navigator.pop(context);
  }

  List<String> _extractHashtags(String text) =>
      RegExp(r'#\w+').allMatches(text).map((m) => m.group(0)!).toList();

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
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        iconTheme: IconThemeData(color: text),
        title: Text(
          'Nuevo contenido',
          style: TextStyle(color: muted, fontSize: 14, letterSpacing: 0.5),
        ),
        actions: [
          if (!_posted)
            GestureDetector(
              onTap: _uploading ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: _uploading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: text,
                        ),
                      )
                    : Text(
                        'Publicar',
                        style: TextStyle(
                          color: text,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tipo de contenido
            Row(
              children: [
                _TypeChip(
                  label: '📷 Foto',
                  selected: _type == MediaType.photo,
                  isDark: isDark,
                  onTap: () => setState(() => _type = MediaType.photo),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: '🎬 Vídeo',
                  selected: _type == MediaType.video,
                  isDark: isDark,
                  onTap: () => setState(() => _type = MediaType.video),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: '✨ Reel',
                  selected: _type == MediaType.reel,
                  isDark: isDark,
                  onTap: () => setState(() => _type = MediaType.reel),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Área de selección de media
            GestureDetector(
              onTap: _pickMedia,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: _mediaFile != null ? 300 : 200,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: border, width: 1.5),
                ),
                child: _mediaFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _type == MediaType.photo
                            ? Image.file(
                                File(_mediaFile!.path),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 300,
                              )
                            : _VideoPreview(
                                path: _mediaFile!.path,
                                isDark: isDark,
                              ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_iconForType(), color: muted, size: 44),
                          const SizedBox(height: 16),
                          Text(
                            _type == MediaType.photo
                                ? 'Elegir foto de galería'
                                : _type == MediaType.video
                                ? 'Elegir vídeo de galería'
                                : 'Elegir vídeo para Reel',
                            style: TextStyle(
                              color: text,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Toca para seleccionar',
                            style: TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // Caption / texto
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESCRIPCIÓN',
                    style: TextStyle(
                      color: muted,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _captionCtrl,
                    style: TextStyle(color: text, fontSize: 15, height: 1.6),
                    maxLines: 4,
                    decoration: InputDecoration.collapsed(
                      hintText:
                          'Escribe algo... Añade #hashtags para más visibilidad',
                      hintStyle: TextStyle(color: muted),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Hashtags sugeridos
            Text(
              'HASHTAGS SUGERIDOS',
              style: TextStyle(color: muted, fontSize: 10, letterSpacing: 2),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                        '#CanteraPro',
                        '#TalentoCertificado',
                        '#Fútbol',
                        '#Sub19',
                        '#Verificado',
                        '#Reel',
                      ]
                      .map(
                        (h) => GestureDetector(
                          onTap: () => _captionCtrl.text += ' $h',
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: surface,
                              border: Border.all(color: border),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              h,
                              style: TextStyle(color: muted, fontSize: 12),
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),

            const SizedBox(height: 40),

            // Publish button
            if (!_posted)
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _uploading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 58,
                    decoration: BoxDecoration(
                      color: _uploading ? surface : AppColors.buttonBg(isDark),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: _uploading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.buttonFg(isDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Subiendo...',
                                style: TextStyle(
                                  color: AppColors.textMuted(isDark),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'PUBLICAR',
                            style: TextStyle(
                              color: AppColors.buttonFg(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, color: text, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      '¡Publicado!',
                      style: TextStyle(
                        color: text,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  IconData _iconForType() {
    switch (_type) {
      case MediaType.photo:
        return Icons.add_photo_alternate_outlined;
      case MediaType.video:
        return Icons.video_library_outlined;
      case MediaType.reel:
        return Icons.movie_creation_outlined;
    }
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected, isDark;
  final VoidCallback onTap;
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.buttonBg(isDark)
              : AppColors.surface(isDark),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? AppColors.buttonBg(isDark)
                : AppColors.border(isDark),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? AppColors.buttonFg(isDark)
                : AppColors.textMuted(isDark),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VideoPreview extends StatelessWidget {
  final String path;
  final bool isDark;
  const _VideoPreview({required this.path, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      color: AppColors.surface(isDark),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline,
            color: AppColors.text(isDark),
            size: 56,
          ),
          const SizedBox(height: 12),
          Text(
            path.split('/').last,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
