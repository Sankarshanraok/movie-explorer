// CineVerse - a responsive Movie Explorer built with Flutter (web).
// Concepts: widgets, responsive layout, named routes + custom transitions,
// animations, Provider state, theming + custom widgets, validated forms.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ======================= MODEL =======================
class Movie {
  final int id, year, minutes;
  final String title, genre, desc;
  final double rating;
  final List<String> cast;
  final Color c1, c2;
  const Movie(this.id, this.title, this.genre, this.year, this.minutes, this.rating, this.desc, this.cast, this.c1, this.c2);
}

const _seed = <Movie>[
  Movie(1, 'Inception', 'Sci-Fi', 2010, 148, 8.8, 'A thief who steals secrets from dreams is given a chance to plant an idea instead.', ['Leonardo DiCaprio', 'Joseph Gordon-Levitt', 'Elliot Page'], Color(0xFF141E30), Color(0xFF3A6073)),
  Movie(2, 'The Dark Knight', 'Action', 2008, 152, 9.0, 'Batman faces the Joker, a criminal mastermind who pushes Gotham into chaos.', ['Christian Bale', 'Heath Ledger', 'Aaron Eckhart'], Color(0xFF232526), Color(0xFF616567)),
  Movie(3, 'Interstellar', 'Sci-Fi', 2014, 169, 8.7, 'Explorers travel through a wormhole in search of a new home for humanity.', ['Matthew McConaughey', 'Anne Hathaway', 'Jessica Chastain'], Color(0xFF0F2027), Color(0xFF2C5364)),
  Movie(4, 'The Shawshank Redemption', 'Drama', 1994, 142, 9.3, 'Two imprisoned men build a lasting friendship and find hope over many years.', ['Tim Robbins', 'Morgan Freeman'], Color(0xFF4B4B4B), Color(0xFFB59A6D)),
  Movie(5, 'The Godfather', 'Drama', 1972, 175, 9.2, 'The ageing head of a crime family hands control to his reluctant youngest son.', ['Marlon Brando', 'Al Pacino', 'James Caan'], Color(0xFF200122), Color(0xFF6F0000)),
  Movie(6, 'Avengers: Endgame', 'Action', 2019, 181, 8.4, 'The surviving heroes make a final stand to undo the damage of a cosmic disaster.', ['Robert Downey Jr.', 'Chris Evans', 'Scarlett Johansson'], Color(0xFF42275A), Color(0xFF734B6D)),
  Movie(7, 'Titanic', 'Drama', 1997, 194, 7.9, 'A young couple from different worlds fall in love aboard the doomed ocean liner.', ['Leonardo DiCaprio', 'Kate Winslet'], Color(0xFF0575E6), Color(0xFF021B79)),
  Movie(8, 'Jurassic Park', 'Adventure', 1993, 127, 8.2, 'A theme park of cloned dinosaurs turns into a fight for survival.', ['Sam Neill', 'Laura Dern', 'Jeff Goldblum'], Color(0xFF1D976C), Color(0xFF134E5E)),
  Movie(9, 'The Lion King', 'Animation', 1994, 88, 8.5, 'A young lion prince flees his kingdom, then returns to claim his place.', ['Matthew Broderick', 'Jeremy Irons', 'James Earl Jones'], Color(0xFFF7971E), Color(0xFFDD2476)),
  Movie(10, 'Toy Story', 'Animation', 1995, 81, 8.3, 'A cowboy doll and a space ranger toy must work together to find their way home.', ['Tom Hanks', 'Tim Allen'], Color(0xFF36D1DC), Color(0xFF5B86E5)),
  Movie(11, 'The Matrix', 'Sci-Fi', 1999, 136, 8.7, 'A hacker learns that reality is a simulation and joins a rebellion against it.', ['Keanu Reeves', 'Laurence Fishburne', 'Carrie-Anne Moss'], Color(0xFF000000), Color(0xFF0F9B0F)),
  Movie(12, "Harry Potter and the Sorcerer's Stone", 'Fantasy', 2001, 152, 7.6, 'An orphan discovers he is a wizard and begins his first year at Hogwarts.', ['Daniel Radcliffe', 'Emma Watson', 'Rupert Grint'], Color(0xFF3A1C71), Color(0xFFD76D77)),
  Movie(13, 'Parasite', 'Thriller', 2019, 132, 8.5, 'A poor family schemes its way into the lives of a wealthy household.', ['Song Kang-ho', 'Lee Sun-kyun', 'Cho Yeo-jeong'], Color(0xFF11998E), Color(0xFF38EF7D)),
  Movie(14, '3 Idiots', 'Comedy', 2009, 170, 8.4, 'Three engineering students, and one free-thinking friend, challenge the pressure to succeed.', ['Aamir Khan', 'R. Madhavan', 'Sharman Joshi'], Color(0xFFFF512F), Color(0xFFF09819)),
  Movie(15, 'RRR', 'Action', 2022, 187, 7.8, 'Two revolutionaries form an unlikely friendship while fighting colonial rule.', ['N. T. Rama Rao Jr.', 'Ram Charan', 'Alia Bhatt'], Color(0xFFB92B27), Color(0xFF1565C0)),
  Movie(16, 'Dangal', 'Drama', 2016, 161, 8.3, 'A former wrestler trains his daughters to become world-class champions.', ['Aamir Khan', 'Fatima Sana Shaikh', 'Sanya Malhotra'], Color(0xFFDA4453), Color(0xFF89216B)),
];

const _palettes = <List<Color>>[
  [Color(0xFF3A1C71), Color(0xFFD76D77)],
  [Color(0xFF0575E6), Color(0xFF021B79)],
  [Color(0xFFFF512F), Color(0xFFDD2476)],
  [Color(0xFF134E5E), Color(0xFF71B280)],
];

// ======================= STATE =======================
enum SortBy { rating, year, title }

class AppState extends ChangeNotifier {
  final List<Movie> movies = List.of(_seed);
  final Set<int> watchlist = {};
  final Map<int, int> myRatings = {};
  final Map<int, List<String>> reviews = {};
  String query = '', genre = 'All';
  SortBy sort = SortBy.rating;
  ThemeMode mode = ThemeMode.dark;

  List<String> get genres => ['All', ...{...movies.map((m) => m.genre)}];
  List<Movie> get top => ([...movies]..sort((a, b) => b.rating.compareTo(a.rating))).take(5).toList();
  List<Movie> get saved => movies.where((m) => watchlist.contains(m.id)).toList();

  List<Movie> get filtered {
    final list = movies
        .where((m) => (genre == 'All' || m.genre == genre) && m.title.toLowerCase().contains(query.toLowerCase().trim()))
        .toList();
    list.sort((a, b) => switch (sort) {
          SortBy.rating => b.rating.compareTo(a.rating),
          SortBy.year => b.year.compareTo(a.year),
          SortBy.title => a.title.compareTo(b.title),
        });
    return list;
  }

  void _go(VoidCallback f) { f(); notifyListeners(); }
  void setQuery(String v) => _go(() => query = v);
  void setGenre(String v) => _go(() => genre = v);
  void setSort(SortBy v) => _go(() => sort = v);
  void toggleTheme() => _go(() => mode = mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  void toggleWatch(int id) => _go(() => watchlist.contains(id) ? watchlist.remove(id) : watchlist.add(id));
  void rate(int id, int stars) => _go(() => myRatings[id] = stars);
  void addReview(int id, String t) => _go(() => reviews.putIfAbsent(id, () => []).add(t));
  void addMovie(Movie m) => _go(() => movies.add(m));
}

// ======================= APP =======================
void main() => runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const CineVerseApp()));

ThemeData _theme(Brightness b) => ThemeData(
      useMaterial3: true,
      brightness: b,
      colorSchemeSeed: const Color(0xFF7C4DFF),
      cardTheme: CardThemeData(clipBehavior: Clip.antiAlias, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      inputDecorationTheme: InputDecorationTheme(filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );

class CineVerseApp extends StatelessWidget {
  const CineVerseApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'CineVerse',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        themeMode: context.select<AppState, ThemeMode>((s) => s.mode),
        initialRoute: '/',
        routes: {'/': (_) => const Shell()},
        onGenerateRoute: (s) {
          if (s.name == '/detail') {
            return PageRouteBuilder(
              settings: s,
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (_, __, ___) => const DetailPage(),
              transitionsBuilder: (_, a, __, child) => FadeTransition(
                opacity: a,
                child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.06), end: Offset.zero).animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
                    child: child),
              ),
            );
          }
          return null;
        },
      );
}

// ======================= SHELL (responsive navigation) =======================
class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int idx = 0;
  static const _dest = [
    (Icons.explore_outlined, Icons.explore, 'Discover'),
    (Icons.bookmark_border, Icons.bookmark, 'Watchlist'),
    (Icons.add_circle_outline, Icons.add_circle, 'Add'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final wide = MediaQuery.of(context).size.width >= 800;
    final pages = [const DiscoverPage(), const WatchlistPage(), AddMoviePage(onDone: () => setState(() => idx = 0))];
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(idx), child: pages[idx]),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.movie_filter), SizedBox(width: 8), Text('CineVerse', style: TextStyle(fontWeight: FontWeight.w800))]),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(app.mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: app.toggleTheme,
          ),
        ],
      ),
      body: wide
          ? Row(children: [
              NavigationRail(
                selectedIndex: idx,
                labelType: NavigationRailLabelType.all,
                onDestinationSelected: (i) => setState(() => idx = i),
                destinations: [for (final d in _dest) NavigationRailDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: Text(d.$3))],
              ),
              const VerticalDivider(width: 1),
              Expanded(child: body),
            ])
          : body,
      bottomNavigationBar: wide
          ? null
          : NavigationBar(
              selectedIndex: idx,
              onDestinationSelected: (i) => setState(() => idx = i),
              destinations: [for (final d in _dest) NavigationDestination(icon: Icon(d.$1), selectedIcon: Icon(d.$2), label: d.$3)],
            ),
    );
  }
}

// ======================= REUSABLE WIDGETS =======================
class Poster extends StatelessWidget {
  final Movie movie;
  final double radius;
  const Poster(this.movie, {super.key, this.radius = 0});
  @override
  Widget build(BuildContext context) => Hero(
        tag: 'poster-${movie.id}',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(colors: [movie.c1, movie.c2], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Text(movie.title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, shadows: [Shadow(blurRadius: 8, color: Colors.black54)])),
        ),
      );
}

class RatingBadge extends StatelessWidget {
  final double rating;
  const RatingBadge(this.rating, {super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        ]),
      );
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const EmptyState(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(48),
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
          ]),
        ),
      );
}

class MovieCard extends StatefulWidget {
  final Movie movie;
  const MovieCard(this.movie, {super.key});
  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard> {
  bool hover = false;
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final m = widget.movie;
    final saved = app.watchlist.contains(m.id);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (_, v, child) => Opacity(opacity: v, child: child),
      child: MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: AnimatedScale(
          scale: hover ? 1.04 : 1,
          duration: const Duration(milliseconds: 180),
          child: Card(
            elevation: hover ? 8 : 1,
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, '/detail', arguments: m),
              child: Stack(fit: StackFit.expand, children: [
                Poster(m),
                Positioned(top: 8, left: 8, child: RatingBadge(m.rating)),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, color: saved ? Colors.amber : Colors.white),
                    onPressed: () => app.toggleWatch(m.id),
                  ),
                ),
                Positioned(
                  left: 0, right: 0, bottom: 0,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.all(8),
                    child: Text('${m.genre} • ${m.year}', style: const TextStyle(color: Colors.white70)),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class SliverMovieGrid extends StatelessWidget {
  final List<Movie> movies;
  const SliverMovieGrid(this.movies, {super.key});
  @override
  Widget build(BuildContext context) => SliverLayoutBuilder(builder: (_, c) {
        final w = c.crossAxisExtent;
        final cols = w < 600 ? 2 : w < 900 ? 3 : w < 1200 ? 5 : 6; // mobile / tablet / desktop
        return SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols, childAspectRatio: 0.68, crossAxisSpacing: 12, mainAxisSpacing: 12),
            delegate: SliverChildBuilderDelegate((_, i) => MovieCard(movies[i], key: ValueKey(movies[i].id)), childCount: movies.length),
          ),
        );
      });
}

// ======================= DISCOVER =======================
class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  final _pc = PageController(viewportFraction: 0.9);
  int _page = 0;
  @override
  void dispose() { _pc.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final top = app.top;
    final list = app.filtered;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Column(children: [
          const SizedBox(height: 12),
          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pc,
              itemCount: top.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) {
                final m = top[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(colors: [m.c1, m.c2])),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('TOP RATED #${i + 1}', style: const TextStyle(color: Colors.white70, letterSpacing: 1.5, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(m.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(children: [
                        RatingBadge(m.rating),
                        const Spacer(),
                        FilledButton.tonal(onPressed: () => Navigator.pushNamed(context, '/detail', arguments: m), child: const Text('Details')),
                      ]),
                    ]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < top.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _page == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: _page == i ? 1 : 0.3), borderRadius: BorderRadius.circular(4)),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
            child: Row(children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Search movies...', prefixIcon: Icon(Icons.search)),
                  onChanged: app.setQuery,
                ),
              ),
              const SizedBox(width: 12),
              DropdownButton<SortBy>(
                value: app.sort,
                underline: const SizedBox.shrink(),
                icon: const Icon(Icons.sort),
                items: const [
                  DropdownMenuItem(value: SortBy.rating, child: Text('Rating')),
                  DropdownMenuItem(value: SortBy.year, child: Text('Newest')),
                  DropdownMenuItem(value: SortBy.title, child: Text('A–Z')),
                ],
                onChanged: (v) => app.setSort(v!),
              ),
            ]),
          ),
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final g in app.genres)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 10),
                    child: ChoiceChip(label: Text(g), selected: app.genre == g, onSelected: (_) => app.setGenre(g)),
                  ),
              ],
            ),
          ),
        ]),
      ),
      if (list.isEmpty)
        const SliverToBoxAdapter(child: EmptyState(Icons.search_off, 'No movies match your search.'))
      else
        SliverMovieGrid(list),
    ]);
  }
}

// ======================= WATCHLIST =======================
class StatTile extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const StatTile(this.icon, this.value, this.label, {super.key});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 6),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
      );
}

class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});
  @override
  Widget build(BuildContext context) {
    final saved = context.watch<AppState>().saved;
    if (saved.isEmpty) return const EmptyState(Icons.bookmark_add_outlined, 'Your watchlist is empty.\nTap the bookmark on any movie to save it.');
    final avg = saved.map((m) => m.rating).reduce((a, b) => a + b) / saved.length;
    final hours = saved.map((m) => m.minutes).reduce((a, b) => a + b) / 60;
    return CustomScrollView(slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Wrap(spacing: 12, runSpacing: 12, children: [
            StatTile(Icons.bookmark, '${saved.length}', 'Saved'),
            StatTile(Icons.star, avg.toStringAsFixed(1), 'Avg rating'),
            StatTile(Icons.schedule, '${hours.toStringAsFixed(1)} h', 'Total runtime'),
          ]),
        ),
      ),
      SliverMovieGrid(saved),
    ]);
  }
}

// ======================= DETAIL =======================
class DetailPage extends StatefulWidget {
  const DetailPage({super.key});
  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  final _key = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final m = ModalRoute.of(context)!.settings.arguments as Movie;
    final app = context.watch<AppState>();
    final saved = app.watchlist.contains(m.id);
    final mine = app.myRatings[m.id] ?? 0;
    final wide = MediaQuery.of(context).size.width > 800;
    final t = Theme.of(context).textTheme;

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(m.title, style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        RatingBadge(m.rating),
        Chip(label: Text(m.genre)),
        Text('${m.year} • ${m.minutes} min'),
      ]),
      const SizedBox(height: 12),
      Text(m.desc, style: t.bodyLarge),
      const SizedBox(height: 16),
      Text('Cast', style: t.titleMedium),
      const SizedBox(height: 4),
      Wrap(spacing: 8, children: [for (final c in m.cast) Chip(avatar: const Icon(Icons.person, size: 16), label: Text(c))]),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: () => app.toggleWatch(m.id),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(saved ? Icons.bookmark : Icons.bookmark_border, key: ValueKey(saved)),
        ),
        label: Text(saved ? 'In watchlist' : 'Add to watchlist'),
      ),
      const SizedBox(height: 16),
      Text('Your rating', style: t.titleMedium),
      Row(children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => app.rate(m.id, i),
            icon: AnimatedScale(
              scale: i == mine ? 1.3 : 1,
              duration: const Duration(milliseconds: 200),
              child: Icon(i <= mine ? Icons.star : Icons.star_border, color: Colors.amber, size: 30),
            ),
          ),
      ]),
      const Divider(height: 32),
      Text('Reviews', style: t.titleLarge),
      const SizedBox(height: 8),
      Form(
        key: _key,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextFormField(
              controller: _ctrl,
              decoration: const InputDecoration(labelText: 'Write a review'),
              validator: (v) {
                final s = v?.trim() ?? '';
                if (s.isEmpty) return 'Review cannot be empty';
                if (s.length < 5) return 'Use at least 5 characters';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: FilledButton(
              onPressed: () {
                if (_key.currentState!.validate()) {
                  app.addReview(m.id, _ctrl.text.trim());
                  _ctrl.clear();
                }
              },
              child: const Text('Post'),
            ),
          ),
        ]),
      ),
      for (final r in app.reviews[m.id] ?? <String>[]) ListTile(leading: const CircleAvatar(child: Icon(Icons.person)), title: Text(r)),
    ]);

    final poster = AspectRatio(aspectRatio: 0.68, child: Poster(m, radius: 16));
    return Scaffold(
      appBar: AppBar(title: Text(m.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 320, child: poster), const SizedBox(width: 24), Expanded(child: info)])
                : Column(children: [SizedBox(width: 240, child: poster), const SizedBox(height: 16), info]),
          ),
        ),
      ),
    );
  }
}

// ======================= ADD MOVIE =======================
class AddMoviePage extends StatefulWidget {
  final VoidCallback onDone;
  const AddMoviePage({super.key, required this.onDone});
  @override
  State<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends State<AddMoviePage> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(), _year = TextEditingController(), _mins = TextEditingController(), _rating = TextEditingController(), _desc = TextEditingController();
  String _genre = 'Drama';
  int _pal = 0;

  @override
  void dispose() {
    for (final c in [_title, _year, _mins, _rating, _desc]) { c.dispose(); }
    super.dispose();
  }

  String? _num(String? v, num lo, num hi, String msg) {
    final n = num.tryParse(v ?? '');
    return (n == null || n < lo || n > hi) ? msg : null;
  }

  @override
  Widget build(BuildContext context) {
    const genres = ['Drama', 'Action', 'Comedy', 'Sci-Fi', 'Thriller', 'Fantasy', 'Adventure', 'Animation'];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Form(
          key: _key,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Add a movie', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextFormField(controller: _year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year'), validator: (v) => _num(v, 1900, 2100, '1900–2100'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _mins, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes'), validator: (v) => _num(v, 30, 300, '30–300'))),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(controller: _rating, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rating'), validator: (v) => _num(v, 0, 10, '0–10'))),
            ]),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _genre,
              decoration: const InputDecoration(labelText: 'Genre'),
              items: [for (final g in genres) DropdownMenuItem(value: g, child: Text(g))],
              onChanged: (v) => setState(() => _genre = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'), validator: (v) => (v == null || v.trim().length < 10) ? 'Use at least 10 characters' : null),
            const SizedBox(height: 16),
            const Text('Poster colour'),
            const SizedBox(height: 8),
            Row(children: [
              for (var i = 0; i < _palettes.length; i++)
                GestureDetector(
                  onTap: () => setState(() => _pal = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 12),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: _palettes[i]),
                      border: Border.all(color: _pal == i ? Theme.of(context).colorScheme.primary : Colors.transparent, width: 3),
                    ),
                  ),
                ),
            ]),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save movie'),
              onPressed: () {
                if (!_key.currentState!.validate()) return;
                context.read<AppState>().addMovie(Movie(
                      DateTime.now().millisecondsSinceEpoch, _title.text.trim(), _genre, int.parse(_year.text), int.parse(_mins.text),
                      double.parse(_rating.text), _desc.text.trim(), const ['Unknown'], _palettes[_pal][0], _palettes[_pal][1],
                    ));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movie added to Discover!')));
                widget.onDone();
              },
            ),
          ]),
        ),
      ),
    );
  }
}
