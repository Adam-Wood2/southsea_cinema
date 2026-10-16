import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/repositories/movie_repository.dart';

void main() {
  group("Movie Repository unit tests", () {
    test("getMovies returns two movies", () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      expect(movies.length, 2);
    });

    test("getMovies contains valid movies", () {
      final MovieRepository repository = MovieRepository();
      final List<Movie> movies = repository.getMovies();

      final Movie eeaao = movies[0];
      expect(eeaao.id, "everything-everywhere");
      expect(eeaao.name, "Everything Everywhere All At Once");
      expect(eeaao.releaseYear, 2022);
      expect(eeaao.ageRating, "PG15");
      expect(
          eeaao.description,
          "A middle-aged Chinese immigrant is swept up into an insane adventure"
          " in which she alone can save existence by exploring other universes and connecting"
          " with the lives she could have led.");
      expect(eeaao.price, 5.99);
      expect(eeaao.date, "Thursday 22 Oct");
      expect(eeaao.time, "18:00 - 20:19");
      expect(eeaao.imagePath, isNotEmpty);

      final Movie dracula = movies[1];
      expect(dracula.id, "dracula");
      expect(dracula.name, "Dracula");
      expect(dracula.releaseYear, 1931);
      expect(dracula.ageRating, "PG");
      expect(
          dracula.description,
          "Transylvanian vampire Count Dracula bends a naive real estate agent"
          " to his will, then takes up residence at a London estate where he sleeps in his"
          " coffin by day and searches for potential victims by night.");
      expect(dracula.price, 7.99);
      expect(dracula.date, "Friday 23 Oct");
      expect(dracula.time, "20:00 - 21:15");
      expect(dracula.imagePath, isNotEmpty);
    });

    test("getMovieByID returns matching movie when id exists", () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById("everything-everywhere");

      expect(movie, isNotNull);
      expect(movie?.name, "Everything Everywhere All At Once");
      expect(movie?.price, 5.99);
    });

    test("getMovieById returns null when id does not exist", () {
      final MovieRepository repository = MovieRepository();
      final Movie? movie = repository.getMovieById("terminator");

      expect(movie, isNull);
    });
  });
}
