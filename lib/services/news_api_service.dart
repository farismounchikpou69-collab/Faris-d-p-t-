import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/news_article.dart';

class NewsApiService {
  final String apiKey;

  NewsApiService(this.apiKey);

  Future<List<NewsArticle>> getWorldNews() async {
    final uri = Uri.https(
      'newsapi.org',
      '/v2/everything',
      {
        'q': 'world OR international OR breaking',
        'sortBy': 'publishedAt',
        'pageSize': '100',
        'apiKey': apiKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur NewsAPI: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List articles = data['articles'] ?? [];

    return articles
        .map(
          (item) => NewsArticle.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<List<NewsArticle>> search(String query) async {
    final uri = Uri.https(
      'newsapi.org',
      '/v2/everything',
      {
        'q': query,
        'sortBy': 'publishedAt',
        'pageSize': '50',
        'apiKey': apiKey,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Erreur NewsAPI: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    final List articles = data['articles'] ?? [];

    return articles
        .map(
          (item) => NewsArticle.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}
