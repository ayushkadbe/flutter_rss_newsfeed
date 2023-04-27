import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class Article {
  final String title;
  final String description;
  final String link;

  Article({required this.title, required this.description, required this.link});
}

class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article.title),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(article.link)),
      ),
    );
  }
}
