
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_article.dart';

class NewsApiService {
  final String apiKey;

  NewsApiService(this.apiKey);

  static const String baseUrl = 'https://gnews.io/api/v4';

  // Récupérer les actualités internationales
  Future<List<NewsArticle>> getWorldNews() async {
    return _fetch(
      'top-headlines',
      {
        'category': 'world',
        'lang': 'fr',
        'max': '10',
      },
    );
  }

  // Rechercher des actualités
  Future<List<NewsArticle>> searchNews(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    return _fetch(
      'search',
      {
        'q': query.trim(),
        'lang': 'fr',
        'max': '10',
        'sortby': 'publishedAt',
      },
    );
  }

  // Fonction commune pour contacter GNews
  Future<List<NewsArticle>> _fetch(
    String endpoint,
    Map<String, String> parameters,
  ) async {
    if (apiKey.trim().isEmpty) {
      throw Exception('Clé API GNews manquante.');
    }

    final uri = Uri.parse('$baseUrl/$endpoint').replace(
      queryParameters: parameters,
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'X-Api-Key': apiKey,
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        if (response.statusCode == 401 ||
            response.statusCode == 403) {
          throw Exception(
            'Clé API invalide ou accès refusé par GNews.',
          );
        }

        if (response.statusCode == 429) {
          throw Exception(
            'Limite de requêtes GNews atteinte. Réessaie plus tard.',
          );
        }

        throw Exception(
          'Erreur GNews : ${response.statusCode}',
        );
      }

      final Map<String, dynamic> data =
          jsonDecode(response.body) as Map<String, dynamic>;

      final List<dynamic> articles = data['articles'] as List? ?? [];

      return articles
          .whereType<Map>()
          .map(
            (article) => NewsArticle.fromJson(
              Map<String, dynamic>.from(article),
            ),
          )
          .toList();
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }

      throw Exception('Impossible de contacter GNews : $e');
    }
  }
}
