import 'package:flutter_riverpod/flutter_riverpod.dart';

class Article {
  final String id;
  final String authorName;
  final String title;
  final String content;
  final DateTime date;
  final String? imageUrl;
  final int likes;

  const Article({
    required this.id,
    required this.authorName,
    required this.title,
    required this.content,
    required this.date,
    this.imageUrl,
    this.likes = 0,
  });

  Article copyWith({int? likes}) {
    return Article(
      id: id,
      authorName: authorName,
      title: title,
      content: content,
      date: date,
      imageUrl: imageUrl,
      likes: likes ?? this.likes,
    );
  }
}

class ArticlesNotifier extends Notifier<List<Article>> {
  @override
  List<Article> build() {
    return [
      Article(
        id: '1',
        authorName: 'Mario Kempes',
        title: 'El resurgir de Marco Silva',
        content: 'Tras una racha de 3 partidos sin ver portería, el joven delantero ha recuperado su mejor versión con un hat-trick espectacular en el derbi juvenil. Los scouts de media Europa ya tienen su nombre marcado en rojo.',
        date: DateTime.now().subtract(const Duration(days: 1)),
        likes: 124,
      ),
      Article(
        id: '2',
        authorName: 'Cantera News',
        title: 'Nueva actualización del Mercado de Talentos',
        content: 'Ya está disponible la nueva oleada de perfiles verificados en la plataforma. Más de 500 nuevos talentos listos para ser descubiertos.',
        date: DateTime.now().subtract(const Duration(hours: 5)),
        likes: 89,
      ),
    ];
  }

  void addArticle(String title, String content, String authorName) {
    final newArticle = Article(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorName: authorName,
      title: title,
      content: content,
      date: DateTime.now(),
    );
    state = [newArticle, ...state];
  }

  void likeArticle(String id) {
    state = [
      for (final a in state)
        if (a.id == id) a.copyWith(likes: a.likes + 1) else a,
    ];
  }
}

final articlesProvider = NotifierProvider<ArticlesNotifier, List<Article>>(
  () => ArticlesNotifier(),
);
