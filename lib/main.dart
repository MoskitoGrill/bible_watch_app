import 'package:flutter/material.dart';
import 'bible_loader.dart';

void main() {
  runApp(const BibleApp());
}

class BibleApp extends StatelessWidget {
  const BibleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bible',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return; // <- OCHRANA PŘED CHYBOU
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BookSelectionScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: 160,
                  height: 160,
                  child: Image.asset('assets/icon.png'), // <== změň dle tvého souboru
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bible',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class BookSelectionScreen extends StatefulWidget {
  const BookSelectionScreen({super.key});

  @override
  State<BookSelectionScreen> createState() => _BookSelectionScreenState();
}

class _BookSelectionScreenState extends State<BookSelectionScreen> {
  List<String> books = [];

  @override
  void initState() {
    super.initState();
    BibleLoader.loadBooks().then((loadedBooks) {
      setState(() {
        books = loadedBooks;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController();
    return Scaffold(
      body: books.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  const Text('Kniha', style: TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 50,
                      diameterRatio: 2,
                      perspective: 0.003,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: books.length,
                        builder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChapterSelectionScreen(book: books[index]),
                                ),
                              );
                            },
                            child: Text(books[index], style: const TextStyle(fontSize: 18)),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class ChapterSelectionScreen extends StatefulWidget {
  final String book;
  const ChapterSelectionScreen({super.key, required this.book});

  @override
  State<ChapterSelectionScreen> createState() => _ChapterSelectionScreenState();
}

class _ChapterSelectionScreenState extends State<ChapterSelectionScreen> {
  List<String> chapters = [];

  @override
  void initState() {
    super.initState();
    BibleLoader.loadChapters(widget.book).then((loadedChapters) {
      setState(() {
        chapters = loadedChapters;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController();
    return Scaffold(
      body: chapters.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text(widget.book, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: chapters.length,
                        builder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VerseSelectionScreen(
                                    book: widget.book,
                                    chapter: chapters[index],
                                  ),
                                ),
                              );
                            },
                            child: Text('Kapitola ${chapters[index]}'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class VerseSelectionScreen extends StatefulWidget {
  final String book;
  final String chapter;
  const VerseSelectionScreen({super.key, required this.book, required this.chapter});

  @override
  State<VerseSelectionScreen> createState() => _VerseSelectionScreenState();
}

class _VerseSelectionScreenState extends State<VerseSelectionScreen> {
  List<String> verses = [];

  @override
  void initState() {
    super.initState();
    BibleLoader.loadVerses(widget.book, widget.chapter).then((loadedVerses) {
      setState(() {
        verses = loadedVerses;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = FixedExtentScrollController();
    return Scaffold(
      body: verses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text('${widget.book} ${widget.chapter}', style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: controller,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: verses.length,
                        builder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BibleTextScreen(
                                    book: widget.book,
                                    chapter: widget.chapter,
                                    verse: verses[index],
                                  ),
                                ),
                              );
                            },
                            child: Text('Verš ${verses[index]}'),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class BibleTextScreen extends StatefulWidget {
  final String book;
  final String chapter;
  final String verse;
  const BibleTextScreen({
    super.key,
    required this.book,
    required this.chapter,
    required this.verse,
  });

  @override
  State<BibleTextScreen> createState() => _BibleTextScreenState();
}

class _BibleTextScreenState extends State<BibleTextScreen> {
  late List<String> books;
  late List<String> chapters;
  late List<String> verses;

  int bookIndex = 0;
  int chapterIndex = 0;
  int verseIndex = 0;

  List<String> pages = [];
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _initNavigationData();
  }

  Future<void> _initNavigationData() async {
    books = await BibleLoader.loadBooks();
    bookIndex = books.indexOf(widget.book);

    chapters = await BibleLoader.loadChapters(widget.book);
    chapterIndex = chapters.indexOf(widget.chapter);

    verses = await BibleLoader.loadVerses(widget.book, widget.chapter);
    verseIndex = verses.indexOf(widget.verse);

    await _loadText();
  }

  Future<void> _loadText() async {
    final text = await BibleLoader.loadVerseText(
      books[bookIndex],
      chapters[chapterIndex],
      verses[verseIndex],
    );

    setState(() {
      pages = _splitTextIntoPages(text, maxChars: 120); // word wrap!
      pageIndex = 0;
    });
  }

  List<String> _splitTextIntoPages(String text, {int maxChars = 120}) {
    final words = text.split(' ');
    final pages = <String>[];
    var buffer = StringBuffer();

    for (final word in words) {
      if ((buffer.length + word.length + 1) > maxChars) {
        pages.add(buffer.toString().trim());
        buffer = StringBuffer();
      }
      buffer.write('$word ');
    }

    if (buffer.isNotEmpty) {
      pages.add(buffer.toString().trim());
    }

    return pages;
  }

  void _nextPage() async {
    if (pageIndex < pages.length - 1) {
      setState(() => pageIndex++);
    } else {
      await _nextVerse();
    }
  }

  void _previousPage() async {
    if (pageIndex > 0) {
      setState(() => pageIndex--);
    } else {
      await _previousVerse();
    }
  }

  Future<void> _nextVerse() async {
    if (verseIndex < verses.length - 1) {
      verseIndex++;
    } else if (chapterIndex < chapters.length - 1) {
      chapterIndex++;
      verses = await BibleLoader.loadVerses(books[bookIndex], chapters[chapterIndex]);
      verseIndex = 0;
    } else if (bookIndex < books.length - 1) {
      bookIndex++;
      chapters = await BibleLoader.loadChapters(books[bookIndex]);
      chapterIndex = 0;
      verses = await BibleLoader.loadVerses(books[bookIndex], chapters[chapterIndex]);
      verseIndex = 0;
    } else {
      return;
    }
    await _loadText();
  }

  Future<void> _previousVerse() async {
    if (verseIndex > 0) {
      verseIndex--;
    } else if (chapterIndex > 0) {
      chapterIndex--;
      verses = await BibleLoader.loadVerses(books[bookIndex], chapters[chapterIndex]);
      verseIndex = verses.length - 1;
    } else if (bookIndex > 0) {
      bookIndex--;
      chapters = await BibleLoader.loadChapters(books[bookIndex]);
      chapterIndex = chapters.length - 1;
      verses = await BibleLoader.loadVerses(books[bookIndex], chapters[chapterIndex]);
      verseIndex = verses.length - 1;
    } else {
      return;
    }
    await _loadText();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            _nextPage();
          } else if (details.primaryVelocity! > 0) {
            _previousPage();
          }
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! < 0) {
            _nextPage();
          } else if (details.primaryVelocity! > 0) {
            _previousPage();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              children: [
                Text(
                  '${books[bookIndex]} ${chapters[chapterIndex]}:${verses[verseIndex]}',
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                if (pages.length > 1)
                  Text(
                    '${pageIndex + 1}/${pages.length}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 6),
                Expanded(
                  child: Center(
                    child: Text(
                      pages.isNotEmpty ? pages[pageIndex] : '',
                      style: const TextStyle(fontSize: 16, height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}



