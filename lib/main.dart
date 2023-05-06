import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'News App',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RssItem> _feedItems = [];
  late String _selectedUrl;
  final TextEditingController _controller = TextEditingController();

  // List of default RSS feed URLs
  final List<String> _defaultRssUrls = ['https://cointelegraph.com/rss/category/market-analysis',    'https://cointelegraph.com/rss/category/top-10-cryptocurrencies', 'https://www.coindesk.com/arc/outboundfeeds/rss/', 'https://bitcoinmagazine.com/.rss/full/' ];


  Future<List<RssItem>?> _fetchRss(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final feed = RssFeed.parse(response.body);
        return feed.items;
      } else {
        throw Exception('Failed to load feed');
      }
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) {
          print('Error loading RSS feed from $url: $e');
        }
      }
      throw Exception('Failed to load feed');
    }
  }

  Future<void> _loadRss(String url) async {
    final List<RssItem> allItems = [];
    for (final url in _defaultRssUrls) {
      final feedItems = await _fetchRss(url);
      allItems.addAll(feedItems!);
    }
    allItems.shuffle();
    setState(() {
      _feedItems = allItems;
    });
  }


  Future<void> _loadDefaultRss() async {
    for (final url in _defaultRssUrls) {
      await _loadRss(url);
    }
  }

  Future<void> _loadCustomRss() async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('customRss') ?? [];
    for (final url in urls) {
      final feedItems = await _fetchRss(url);
      setState(() {
        _feedItems.addAll(feedItems as Iterable<RssItem>);
      });
    }
  }

  Future<void> _addCustomRss(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final urls = prefs.getStringList('customRss') ?? [];
    urls.add(url);
    await prefs.setStringList('customRss', urls);
    try {
      final feedItems = await _fetchRss(url);
      setState(() {
        _feedItems.addAll(feedItems as Iterable<RssItem>);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error loading RSS feed from $url: $e');
      }
    }
  }


  void _openWebView(String url) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(url),
        ),
        body: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(url)),
        ),
      );
    }));
  }

  @override
  void initState() {
    super.initState();
    _loadDefaultRss();
    _loadCustomRss();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Add custom RSS feed',
              suffixIcon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  await _addCustomRss(_controller.text);
                  _controller.clear();
                },
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _feedItems.length,
              itemBuilder: (context, index) {
                final item = _feedItems[index];
                return ListTile(
                  title: Text(item.title ?? ''),
                  subtitle: Text(item.pubDate?.toString() ?? ''),
                  onTap: () {
                    _selectedUrl = item.link!;
                    _openWebView(_selectedUrl);
                  },
                );
              },
            ),
          ),


        ],
      ),
    );
  }
}
