
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
  // IMPORTANT : utiliser GNEWS_API_KEY
  final NewsApiService api = NewsApiService(
    const String.fromEnvironment('GNEWS_API_KEY'),
  );

  final TextEditingController searchController =
      TextEditingController();

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

  // Charger les actualités internationales
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
        error = e.toString();
      });
    }
  }

  // Rechercher des actualités
  Future<void> searchNews() async {
    final query = searchController.text.trim();

    if (query.isEmpty) {
      loadNews();
      return;
    }

    setState(() {
      loading = true;
      error = '';
    });

    try {
      final result = await api.searchNews(query);

      if (!mounted) return;

      setState(() {
        articles = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  // Ouvrir l'article original
  Future<void> openArticle(String url) async {
    final uri = Uri.tryParse(url);

    if (uri == null ||
        !uri.hasScheme ||
        (uri.scheme != 'https' && uri.scheme != 'http')) {
      return;
    }

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Impossible d'ouvrir cet article."),
        ),
      );
    }
  }

  String formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year;

    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.public),
            SizedBox(width: 10),
            Text(
              'World AI News',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: loadNews,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
          ),
        ],
      ),

      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => searchNews(),
              decoration: InputDecoration(
                hintText: 'Rechercher une actualité...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: searchNews,
                  icon: const Icon(Icons.arrow_forward),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          // Indicateur de chargement
          if (loading)
            const LinearProgressIndicator(),

          // Message d'erreur
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: loadNews,
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            ),

          // Liste des actualités
          Expanded(
            child: articles.isEmpty && !loading
                ? Center(
                    child: error.isEmpty
                        ? const Text(
                            'Aucune actualité disponible.',
                          )
                        : const SizedBox.shrink(),
                  )
                : RefreshIndicator(
                    onRefresh: loadNews,
                    child: ListView.builder(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          clipBehavior: Clip.antiAlias,
                          elevation: 3,
                          child: InkWell(
                            onTap: () =>
                                openArticle(article.url),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                // Image de l'article
                                if (article.imageUrl != null &&
                                    article.imageUrl!.isNotEmpty)
                                  Image.network(
                                    article.imageUrl!,
                                    width: double.infinity,
                                    height: 190,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(
                                            Icons.image_not_supported,
                                            size: 45,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      if (article.description != null)
                                        Text(
                                          article.description!,
                                          maxLines: 3,
                                          overflow:
                                              TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                          ),
                                        ),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.newspaper,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              article.source,
                                              style: const TextStyle(
                                                color: Colors.blue,
                                                fontWeight:
                                                    FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            formatDate(
                                              article.publishedAt,
                                            ),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Lire l'article",
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight:
                                                  FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.open_in_new,
                                            size: 16,
                                            color: Colors.blue,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
