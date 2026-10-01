class NewsArticle {
  final String title;
  final String? description;
  final String url;
  final String source;
  final DateTime publishedAt;
  final String? imageUrl;

  NewsArticle({
    required this.title,
    required this.description,
    required this.url,
    required this.source,
    required this.publishedAt,
    this.imageUrl,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    return NewsArticle(
      title: json['title'] ?? 'Sans titre',
      description: json['description'],
      url: json['url'] ?? '',
      source: json['source']?['name'] ?? 'Source inconnue',
      publishedAt: DateTime.tryParse(
            json['publishedAt'] ?? '',
          ) ??
          DateTime.now(),
      imageUrl: json['urlToImage'],
    );
  }
}
