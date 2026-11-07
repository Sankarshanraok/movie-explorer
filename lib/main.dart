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
  Movie(1, 'Midnight Orbit', 'Sci-Fi', 2023, 128, 8.4, 'A lone pilot discovers a signal beyond the edge of the solar system.', ['Ava Stone', 'Raj Mehta', 'Leo Park'], Color(0xFF141E30), Color(0xFF3A6073)),
  Movie(2, 'Crimson Alley', 'Thriller', 2021, 112, 7.6, 'A detective races against time in a city that never sleeps.', ['Mia Cruz', 'Omar Haddad'], Color(0xFF93291E), Color(0xFFED213A)),
  Movie(3, 'Laugh Track', 'Comedy', 2022, 98, 7.1, 'Three failing comedians get one last shot at a TV special.', ['Tom Reed', 'Nina Patel', 'Gus Lee'], Color(0xFFF7971E), Color(0xFFFFD200)),
  Movie(4, 'Paper Kingdoms', 'Fantasy', 2020, 134, 8.0, 'A girl folds a map that rewrites a forgotten empire.', ['Iris Wong', 'Callum Fox'], Color(0xFF11998E), Color(0xFF38EF7D)),
  Movie(5, 'Echoes of Rain', 'Drama', 2019, 121, 8.7, 'Two strangers share one monsoon and a lifetime of secrets.', ['Anaya Rao', 'Daniel Kim'], Color(0xFF4568DC), Color(0xFFB06AB3)),
  Movie(6, 'Last Lap', 'Action', 2024, 109, 7.3, 'A retired racer is pulled back for one impossible race.', ['Jack Moreno', 'Sofia Lane'], Color(0xFF232526), Color(0xFF616567)),
  Movie(7, 'Stardust Cafe', 'Comedy', 2018, 95, 6.9, 'A cosmic diner serves aliens, ghosts and one very tired chef.', ['Pia Novak', 'Eli Brooks'], Color(0xFFEE0979), Color(0xFFFF6A00)),
  Movie(8, 'The Quiet Ward', 'Thriller', 2022, 105, 7.8, 'A night nurse notices patients who should not be there.', ['Hana Sato', 'Victor Hale'], Color(0xFF0F2027), Color(0xFF2C5364)),
  Movie(9, 'Dune Runners', 'Action', 2023, 140, 7.5, 'Smugglers cross a burning desert with a stolen map.', ['Zane Cole', 'Lila Roy'], Color(0xFFDA4453), Color(0xFF89216B)),
  Movie(10, 'Lantern Hill', 'Drama', 2017, 117, 8.2, 'A village lights one lantern a night for a son who never returned.', ['Mei Lin', 'Arjun Das'], Color(0xFF1D976C), Color(0xFF93F9B9)),
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
    const genres = ['Drama', 'Action', 'Comedy', 'Sci-Fi', 'Thriller', 'Fantasy'];
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
