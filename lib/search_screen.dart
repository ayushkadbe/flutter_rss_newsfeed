import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'dart:async';

class Article {
  final String title;
  final String description;
  final String imageUrl;

  Article({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchQuery = '';
  List<Article> articles = [];
  List<Article> searchResults = [];

  void searchArticles() {
    searchResults = articles.where((article) {
      return article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    const searchUrl = 'https://news.google.com/rss?hl=en-US&gl=US&ceid=US:en';
    final response = await http.get(Uri.parse(searchUrl));
    final feed = RssFeed.parse(response.body);
    final List<Article> fetchedArticles = [];

    if (feed.items != null) { // check if feed.items is not null
      for (final item in feed.items!) { // add ! to assert that feed.items is not null
        fetchedArticles.add(
          Article(
            title: item.title ?? '',
            description: item.description ?? '',
            imageUrl: item.enclosure?.url ?? '', // use enclosure url for image
          ),
        );
      }
    }

    setState(() {
      articles = fetchedArticles;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Search Articles...',
            hintStyle: TextStyle(color: Colors.white),
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            setState(() {
              searchQuery = query;
              searchArticles();
            });
          },
        ),
      ),
      body: ListView.builder(
        itemCount: searchResults.length,
        itemBuilder: (context, index) {
          return Card(
            child: Column(
              children: [
                Image.network(
                  searchResults[index].imageUrl, // access imageUrl property
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 8.0),
                Text(
                  searchResults[index].title,
                ),
                const SizedBox(height: 8.0),
                Text(
                  searchResults[index].description,
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
