import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class RecommendationsPage extends StatelessWidget {
  const RecommendationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pregnancy Recommendations',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.pink[200],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Books Section
              Text(
                'Books to Read During Pregnancy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800],
                ),
              ),
              SizedBox(height: 10),
              ...bookList.map((book) => _buildBookCard(book)),
              SizedBox(height: 20),

              // Songs Section
              Text(
                'Songs to Listen to During Pregnancy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink[800],
                ),
              ),
              SizedBox(height: 10),
              ...songList.map((song) => _buildSongCard(song)),
            ],
          ),
        ),
      ),
    );
  }

  // Book Card Widget
  Widget _buildBookCard(Map<String, String> book) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.book, color: Colors.pink[400], size: 40),
        title: Text(
          book['title']!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          book['author']!,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        onTap: () {
          launchURL(book['url']!);
        },
      ),
    );
  }

  // Song Card Widget
  Widget _buildSongCard(Map<String, String> song) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Icon(Icons.music_note, color: Colors.pink[400], size: 40),
        title: Text(
          song['title']!,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          song['artist']!,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        onTap: () {
          launchURL(song['url']!);
        },
      ),
    );
  }

  // Launch URL Function
  void launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}

// Sample Data for Books
final List<Map<String, String>> bookList = [
  {
    'title': 'What to Expect When You\'re Expecting',
    'author': 'By Heidi Murkoff',
    'url':
        'https://www.amazon.com/What-Expect-When-Youre-Expecting/dp/0761187488',
  },
  {
    'title': 'The Expectant Father',
    'author': 'By Armin A. Brott and Jennifer Ash',
    'url':
        'https://www.amazon.com/Expectant-Father-Ultimate-Dads-Be/dp/0789213445',
  },
  {
    'title': 'Ina May\'s Guide to Childbirth',
    'author': 'By Ina May Gaskin',
    'url':
        'https://www.amazon.com/Ina-Mays-Guide-Childbirth-Gaskin/dp/0553381156',
  },
  {
    'title': 'The Pregnancy Countdown Book',
    'author': 'By Susan Magee',
    'url':
        'https://www.amazon.com/Pregnancy-Countdown-Book-Nine-Months/dp/1606524700',
  },
  {
    'title': 'Bumpin\'',
    'author': 'By Leslie Schrock',
    'url':
        'https://www.amazon.com/Bumpin-Modern-Guide-Pregnancy-Science/dp/1797202185',
  },
  {
    'title': 'The Mama Natural Week-by-Week Guide to Pregnancy',
    'author': 'By Genevieve Howland',
    'url':
        'https://www.amazon.com/Mama-Natural-Week-Week-Pregnancy-Childbirth/dp/0062846867',
  },
  {
    'title': 'Expecting Better',
    'author': 'By Emily Oster',
    'url':
        'https://www.amazon.com/Expecting-Better-Conventional-Pregnancy-Wrong/dp/0143125702',
  },
  {
    'title': 'The Whole 9 Months',
    'author': 'By Jennifer Lang',
    'url':
        'https://www.amazon.com/Whole-9-Months-Healthy-Pregnancy/dp/1940358931',
  },
  {
    'title': 'Pregnancy, Childbirth, and the Newborn',
    'author': 'By Penny Simkin',
    'url':
        'https://www.amazon.com/Pregnancy-Childbirth-Newborn-Penny-Simkin/dp/1558327902',
  },
  {
    'title': 'The Pregnancy Encyclopedia',
    'author': 'By DK',
    'url':
        'https://www.amazon.com/Pregnancy-Encyclopedia-All-Expecting-Parents/dp/1465436095',
  },
];

// Sample Data for Songs
final List<Map<String, String>> songList = [
  {
    'title': 'Beautiful Day',
    'artist': 'U2',
    'url': 'https://www.youtube.com/watch?v=co6WMzDOh1o',
  },
  {
    'title': 'Three Little Birds',
    'artist': 'Bob Marley',
    'url': 'https://www.youtube.com/watch?v=zaGUr6wzyT8',
  },
  {
    'title': 'Here Comes the Sun',
    'artist': 'The Beatles',
    'url': 'https://www.youtube.com/watch?v=KQetemT1sWc',
  },
  {
    'title': 'A Thousand Years',
    'artist': 'Christina Perri',
    'url': 'https://www.youtube.com/watch?v=rtOvBOTyX00',
  },
  {
    'title': 'You Are the Sunshine of My Life',
    'artist': 'Stevie Wonder',
    'url': 'https://www.youtube.com/watch?v=Y5JmFLjzx1Q',
  },
  {
    'title': 'Isn\'t She Lovely',
    'artist': 'Stevie Wonder',
    'url': 'https://www.youtube.com/watch?v=wDZFf0pm0SE',
  },
  {
    'title': 'Sweet Child O\' Mine',
    'artist': 'Guns N\' Roses',
    'url': 'https://www.youtube.com/watch?v=1w7OgIMMRc4',
  },
  {
    'title': 'Lullaby',
    'artist': 'Billy Joel',
    'url': 'https://www.youtube.com/watch?v=3Oc3DhA9ZgQ',
  },
  {
    'title': 'Your Song',
    'artist': 'Elton John',
    'url': 'https://www.youtube.com/watch?v=GlPlfCy1urI',
  },
  {
    'title': 'Brave',
    'artist': 'Sara Bareilles',
    'url': 'https://www.youtube.com/watch?v=QUQsqBqxoR4',
  },
];
