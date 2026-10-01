import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/news_article.dart';
import 'services/news_api_service.dart';

void main() {
  runApp(const WorldAIApp());
}

class WorldAIApp extends StatelessWidget {
  const WorldAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World AI News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const NewsHome(),
    );
  }
}

class NewsHome extends StatefulWidget {
  const NewsHome({super.key});

  @override
  State<NewsHome> createState() => _NewsHomeState();
}

class _NewsHomeState extends State<NewsHome> {
  final NewsApiService api = NewsApiService(
    const String.fromEnvironment('NEWS_API_KEY'),
  );

  final TextEditingController searchController = TextEditingController();

  List<NewsArticle> articles = [];
  bool loading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadNews() async {
    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await api.getWorldNews();

      if (!mounted) return;

      setState(() {
        articles = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Impossible de charger les actualités : $e';
      });
    }
  }

  Future<void> searchNews(String query) async {
    final text = query.trim();

    if (text.isEmpty) {
      loadNews();
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await api.search(text);

      if (!mounted) return;

      setState(() {
        articles = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Recherche impossible : $e';
      });
    }
  }

  Future<void> openArticle(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null) return;

    final ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir le lien.")),
      );
    }
  }

  String formatDate(DateTime date) {
    final d = date.toLocal();
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '$day/$month/${d.year} à $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('World AI News'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loading ? null : loadNews,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: searchNews,
              decoration: InputDecoration(
                hintText: 'Rechercher une actualité...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          if (loading) const LinearProgressIndicator(),
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          Expanded(
            child: articles.isEmpty && !loading
                ? const Center(
                    child: Text('Aucune actualité disponible.'),
                  )
                : ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: InkWell(
                          onTap: () => openArticle(article.url),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (article.description != null) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    article.description!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  '${article.source} • ${formatDate(article.publishedAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
