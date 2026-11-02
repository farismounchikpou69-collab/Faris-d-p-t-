
class NewsArticle {
  final String title;
  final String? description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final sourceData = json['source'];

    return NewsArticle(
      title: json['title']?.toString() ?? 'Sans titre',

      description: json['description']?.toString(),

      url: json['url']?.toString() ?? '',

      source: sourceData is Map
          ? sourceData['name']?.toString() ?? 'Source inconnue'
          : 'Source inconnue',

      publishedAt: DateTime.tryParse(
            json['publishedAt']?.toString() ?? '',
          ) ??
          DateTime.now(),

      // GNews utilise "image", et non "urlToImage".
      imageUrl: json['image']?.toString(),
    );
  }
}
