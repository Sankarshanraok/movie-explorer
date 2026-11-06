import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ---------- Model & State ----------
class Movie {
  final int id;
  final String title, genre, desc;
  final int year;
  final double rating;
  final Color c1, c2;
  const Movie(this.id, this.title, this.genre, this.year, this.rating, this.desc, this.c1, this.c2);
}

const _seed = <Movie>[
  Movie(1, 'Midnight Orbit', 'Sci-Fi', 2023, 8.4, 'A lone pilot discovers a signal beyond the edge of the solar system.', Color(0xFF141E30), Color(0xFF243B55)),
  Movie(2, 'Crimson Alley', 'Thriller', 2021, 7.6, 'A detective races against time in a city that never sleeps.', Color(0xFF93291E), Color(0xFFED213A)),
  Movie(3, 'Laugh Track', 'Comedy', 2022, 7.1, 'Three failing comedians get one last shot at a TV special.', Color(0xFFF7971E), Color(0xFFFFD200)),
  Movie(4, 'Paper Kingdoms', 'Fantasy', 2020, 8.0, 'A girl folds a map that rewrites a forgotten empire.', Color(0xFF11998E), Color(0xFF38EF7D)),
  Movie(5, 'Echoes of Rain', 'Drama', 2019, 8.7, 'Two strangers share one monsoon and a lifetime of secrets.', Color(0xFF4568DC), Color(0xFFB06AB3)),
  Movie(6, 'Last Lap', 'Action', 2024, 7.3, 'A retired racer is pulled back for one impossible race.', Color(0xFF232526), Color(0xFF414345)),
  Movie(7, 'Stardust Cafe', 'Comedy', 2018, 6.9, 'A cosmic diner serves aliens, ghosts and one very tired chef.', Color(0xFFEE0979), Color(0xFFFF6A00)),
  Movie(8, 'The Quiet Ward', 'Thriller', 2022, 7.8, 'A night nurse notices patients who should not be there.', Color(0xFF0F2027), Color(0xFF2C5364)),
];

class AppState extends ChangeNotifier {
  final List<Movie> movies = List.of(_seed);
  final Set<int> favs = {};
  final Map<int, List<String>> reviews = {};
  String query = '', genre = 'All';

  List<String> get genres => ['All', ...{...movies.map((m) => m.genre)}];
  List<Movie> get filtered => movies
      .where((m) => (genre == 'All' || m.genre == genre) && m.title.toLowerCase().contains(query.toLowerCase()))
      .toList();

  void setQuery(String q) { query = q; notifyListeners(); }
  void setGenre(String g) { genre = g; notifyListeners(); }
  void toggleFav(int id) { favs.contains(id) ? favs.remove(id) : favs.add(id); notifyListeners(); }
  void addReview(int id, String t) { reviews.putIfAbsent(id, () => []).add(t); notifyListeners(); }
  void addMovie(Movie m) { movies.add(m); notifyListeners(); }
}

// ---------- App & Theme ----------
void main() => runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const MovieApp()));

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Movie Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: const Color(0xFFE50914),
          cardTheme: CardThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), clipBehavior: Clip.antiAlias),
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/detail': (_) => const DetailScreen(),
          '/favorites': (_) => const FavoritesScreen(),
          '/add': (_) => const AddMovieScreen(),
        },
      );
}

// ---------- Custom reusable widgets ----------
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(movie.title, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
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
          Text(rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white)),
        ]),
      );
}

class MovieCard extends StatelessWidget {
  final Movie movie;
  const MovieCard(this.movie, {super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final fav = app.favs.contains(movie.id);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (_, v, child) => Opacity(opacity: v, child: Transform.scale(scale: 0.9 + 0.1 * v, child: child)),
      child: Card(
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/detail', arguments: movie),
          child: Stack(fit: StackFit.expand, children: [
            Poster(movie),
            Positioned(top: 8, left: 8, child: RatingBadge(movie.rating)),
            Positioned(top: 0, right: 0, child: IconButton(
              icon: Icon(fav ? Icons.favorite : Icons.favorite_border, color: fav ? Colors.redAccent : Colors.white),
              onPressed: () => app.toggleFav(movie.id),
            )),
            Positioned(left: 0, right: 0, bottom: 0, child: Container(
              color: Colors.black54, padding: const EdgeInsets.all(8),
              child: Text('${movie.genre} • ${movie.year}', style: const TextStyle(color: Colors.white70)),
            )),
          ]),
        ),
      ),
    );
  }
}

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  const MovieGrid(this.movies, {super.key});
  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const Center(child: Text('No movies found'));
    return LayoutBuilder(builder: (_, c) {
      final cols = c.maxWidth < 600 ? 2 : c.maxWidth < 1000 ? 4 : 6; // mobile / tablet / desktop
      return GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: movies.length,
        itemBuilder: (_, i) => MovieCard(movies[i]),
      );
    });
  }
}

// ---------- Screens ----------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('🎬 Movie Explorer'), actions: [
        IconButton(icon: Badge(label: Text('${app.favs.length}'), isLabelVisible: app.favs.isNotEmpty, child: const Icon(Icons.favorite)),
            onPressed: () => Navigator.pushNamed(context, '/favorites')),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, '/add'), icon: const Icon(Icons.add), label: const Text('Add Movie')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            decoration: const InputDecoration(hintText: 'Search movies...', prefixIcon: Icon(Icons.search)),
            onChanged: app.setQuery,
          ),
        ),
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              for (final g in app.genres)
                Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
                  child: ChoiceChip(label: Text(g), selected: app.genre == g, onSelected: (_) => app.setGenre(g)),
                ),
            ],
          ),
        ),
        Expanded(child: MovieGrid(app.filtered)),
      ]),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final list = app.movies.where((m) => app.favs.contains(m.id)).toList();
    return Scaffold(appBar: AppBar(title: const Text('My Favorites')), body: MovieGrid(list));
  }
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final _key = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final movie = ModalRoute.of(context)!.settings.arguments as Movie;
    final app = context.watch<AppState>();
    final fav = app.favs.contains(movie.id);
    final width = MediaQuery.of(context).size.width;
    final wide = width > 800;

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(movie.title, style: Theme.of(context).textTheme.headlineMedium),
      const SizedBox(height: 8),
      Row(children: [RatingBadge(movie.rating), const SizedBox(width: 12), Text('${movie.genre} • ${movie.year}')]),
      const SizedBox(height: 16),
      Text(movie.desc, style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 16),
      FilledButton.icon(
        onPressed: () => app.toggleFav(movie.id),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(fav ? Icons.favorite : Icons.favorite_border, key: ValueKey(fav)),
        ),
        label: Text(fav ? 'In favorites' : 'Add to favorites'),
      ),
      const Divider(height: 32),
      Text('Reviews', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Form(
        key: _key,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: TextFormField(
              controller: _ctrl,
              decoration: const InputDecoration(labelText: 'Write a review'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Review cannot be empty';
                if (v.trim().length < 5) return 'Use at least 5 characters';
                return null;
              },
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () {
              if (_key.currentState!.validate()) {
                app.addReview(movie.id, _ctrl.text.trim());
                _ctrl.clear();
              }
            },
            child: const Text('Post'),
          ),
        ]),
      ),
      for (final r in app.reviews[movie.id] ?? <String>[])
        ListTile(leading: const Icon(Icons.person), title: Text(r)),
    ]);

    final poster = AspectRatio(aspectRatio: 0.7, child: Poster(movie, radius: 16));

    return Scaffold(
      appBar: AppBar(title: Text(movie.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: wide
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    SizedBox(width: 320, child: poster),
                    const SizedBox(width: 24),
                    Expanded(child: info),
                  ])
                : Column(children: [SizedBox(width: 240, child: poster), const SizedBox(height: 16), info]),
          ),
        ),
      ),
    );
  }
}

class AddMovieScreen extends StatefulWidget {
  const AddMovieScreen({super.key});
  @override
  State<AddMovieScreen> createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(), _year = TextEditingController(), _rating = TextEditingController(), _desc = TextEditingController();
  String _genre = 'Drama';

  @override
  void dispose() {
    for (final c in [_title, _year, _rating, _desc]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    const genres = ['Drama', 'Action', 'Comedy', 'Sci-Fi', 'Thriller', 'Fantasy'];
    return Scaffold(
      appBar: AppBar(title: const Text('Add Movie')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Form(
            key: _key,
            child: ListView(padding: const EdgeInsets.all(16), children: [
              TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null),
              const SizedBox(height: 12),
              TextFormField(controller: _year, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Year'),
                  validator: (v) {
                    final y = int.tryParse(v ?? '');
                    return (y == null || y < 1900 || y > 2100) ? 'Enter a year between 1900 and 2100' : null;
                  }),
              const SizedBox(height: 12),
              TextFormField(controller: _rating, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Rating (0-10)'),
                  validator: (v) {
                    final r = double.tryParse(v ?? '');
                    return (r == null || r < 0 || r > 10) ? 'Enter a rating from 0 to 10' : null;
                  }),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _genre,
                decoration: const InputDecoration(labelText: 'Genre'),
                items: [for (final g in genres) DropdownMenuItem(value: g, child: Text(g))],
                onChanged: (v) => setState(() => _genre = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) => (v == null || v.trim().length < 10) ? 'Describe it in at least 10 characters' : null),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (_key.currentState!.validate()) {
                    final id = DateTime.now().millisecondsSinceEpoch;
                    app.addMovie(Movie(id, _title.text.trim(), _genre, int.parse(_year.text), double.parse(_rating.text),
                        _desc.text.trim(), const Color(0xFF3A1C71), const Color(0xFFD76D77)));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Movie added!')));
                  }
                },
                child: const Text('Save Movie'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
