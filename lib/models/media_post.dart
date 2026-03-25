import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MediaType { photo, video, reel }

class MediaPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUniqueId;
  final MediaType type;
  final String? filePath; // ruta local del archivo
  final String caption;
  final List<String> hashtags;
  final DateTime createdAt;
  final int likes;
  final int comments;

  const MediaPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUniqueId,
    required this.type,
    this.filePath,
    required this.caption,
    required this.hashtags,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
  });

  MediaPost copyWith({int? likes}) => MediaPost(
    id: id,
    authorId: authorId,
    authorName: authorName,
    authorUniqueId: authorUniqueId,
    type: type,
    filePath: filePath,
    caption: caption,
    hashtags: hashtags,
    createdAt: createdAt,
    likes: likes ?? this.likes,
    comments: comments,
  );

  bool get hasFile => filePath != null && File(filePath!).existsSync();
}

// Media feed global (en producción vendría de Supabase Storage)
class MediaFeedNotifier extends Notifier<List<MediaPost>> {
  @override
  List<MediaPost> build() => _mockPosts;

  void addPost(MediaPost post) => state = [post, ...state];
  void toggleLike(String postId) {
    state = state.map((p) {
      if (p.id != postId) return p;
      return p.copyWith(likes: p.likes > 0 ? p.likes - 1 : p.likes + 1);
    }).toList();
  }
}

final mediaFeedProvider = NotifierProvider<MediaFeedNotifier, List<MediaPost>>(
  () => MediaFeedNotifier(),
);

final _mockPosts = <MediaPost>[
  MediaPost(
    id: 'm1',
    authorId: 'j1',
    authorName: 'Elena Vance (Periodista)',
    authorUniqueId: 'Cantera-J001',
    type: MediaType.photo,
    caption:
        '🔥 INCREÍBLE lo de Marco Silva hoy en la Copa Sub-19. Promedio de 8.8 validado por el colegiado. Los ojeadores del Madrid ya están tomando nota. #FuturoCrack #CanteraPro',
    hashtags: ['#CanteraPro', '#FútbolBase', '#Scouting'],
    createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
    likes: 1240,
    comments: 89,
  ),
  MediaPost(
    id: 'm2',
    authorId: 'p1',
    authorName: 'Marco Silva',
    authorUniqueId: 'Cantera-0982',
    type: MediaType.video,
    caption:
        'Entrenamiento técnico de hoy. Trabajando la pierna mala y definición cruzada ⚽🎯. Gracias @PedroRomero por la sesión.',
    hashtags: ['#Entrenamiento', '#Delantero', '#Disciplina'],
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    likes: 891,
    comments: 44,
  ),
  MediaPost(
    id: 'm3',
    authorId: 's1',
    authorName: 'David Torres (Scout RMA)',
    authorUniqueId: 'Cantera-S001',
    type: MediaType.reel,
    caption:
        'Lo que buscamos en un mediocentro moderno: visión periférica y primer toque. Luis Peña (Cantera-1102) es un claro ejemplo de este perfil. 👀📋',
    hashtags: ['#ScoutingU19', '#Centrocampista', '#Visión'],
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    likes: 2100,
    comments: 130,
  ),
  MediaPost(
    id: 'm4',
    authorId: 'b1',
    authorName: 'Nike Iberia',
    authorUniqueId: 'Cantera-B001',
    type: MediaType.photo,
    caption:
        'El talento no espera. Nueva colección Phantom Elite U19, disponible ahora en el Marketplace Oficial de Cantera. 👟⚡',
    hashtags: ['#NikeFutbol', '#PhantomElite', '#Sponsor'],
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    likes: 5670,
    comments: 212,
  ),
  MediaPost(
    id: 'm5',
    authorId: 'c1',
    authorName: 'Pedro Romero (Entrenador)',
    authorUniqueId: 'Cantera-C001',
    type: MediaType.photo,
    caption:
        'Orgulloso de mis chicos. Victoria sufrida 2-1 pero con los 3 puntos en casa. Actitud intachable. 🛡️🛡️',
    hashtags: ['#AtleticoJuvenil', '#Victoria', '#Equipo'],
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    likes: 342,
    comments: 15,
  ),
];
