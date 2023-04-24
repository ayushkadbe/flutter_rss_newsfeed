import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(),
        child: HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<RssItem> _newsList = [];

  @override
  void initState() {
    super.initState();
    _fetchDefaultFeeds();
  }

  Future<void> _fetchDefaultFeeds() async {
    final defaultFeeds = [
      'https://www.nasa.gov/rss/dyn/lg_image_of_the_day.rss',
      'https://www.reutersagency.com/feed/?dps_paged=1&dps_filter=recent-news&dps_format=feed&dps_query=Mexico&dps_query_name=filter',
      'https://news.google.com/rss/search?q=technology&hl=en-US&gl=US&ceid=US:en',
    ];

    for (final feedUrl in defaultFeeds) {
      final response = await http.get(Uri.parse(feedUrl));
      final feed = RssFeed.parse(response.body);
      setState(() {
        _newsList.addAll(feed.items ?? []);
      });
    }

  }

  Future<void> _fetchSearchResults(String query) async {
    final searchUrl = 'https://news.google.com/rss/search?q=$query&hl=en-US&gl=US&ceid=US:en';
    final response = await http.get(Uri.parse(searchUrl));
    final feed = RssFeed.parse(response.body);
    setState(() {
      _newsList = feed.items ?? [];
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News'),
      ),
      body: ListView.builder(
        itemCount: _newsList.length,
        itemBuilder: (BuildContext context, int index) {
          final item = _newsList[index];
          return ListTile(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: Text(item.title ?? ''),
                    ),
                    body: InAppWebView(
                      initialUrlRequest: URLRequest(url: Uri.parse(item.link ?? '')),
                    ),
                  );
                },
              ));
            },
            title: Text(item.title ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.0),
                Text(
                  item.pubDate?.toIso8601String() ?? '',
                  style: TextStyle(fontSize: 14.0),
                ),
                SizedBox(height: 8.0),
                Text(
                  item.description ?? '',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final query = await showSearch<String>(
            context: context,
            delegate: _SearchDelegate(),
          );
          if (query != null) {
            await _fetchSearchResults(query);
          }
        },
        child: Icon(Icons.search),
      ),
    );
  }
}

class _SearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, '');
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return SizedBox.shrink();
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      textTheme: TextTheme(
        headline6: TextStyle(
          color: Colors.white,
          fontSize: 20.0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: Colors.white54,
        ),
      ),
    );
  }

  @override
  void showResults(BuildContext context) {
    close(context, query);
  }
}
