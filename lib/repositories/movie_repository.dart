import 'dart:convert';

import 'package:southsea_cinema/models/movie.dart';
import 'package:flutter/services.dart';

class MovieRepository {
  List<Movie>? _cachedMovies;

  List<Movie> getMovies() {
    final List<Movie>? cachedMovies = _cachedMovies;
    if (cachedMovies != null) {
      return cachedMovies;
    }


    return [
      Movie(
          id: "everything-everywhere",
          name: "Everything Everywhere All At Once",
          releaseYear: 2022,
          ageRating: "PG15",
          description:
              "A middle-aged Chinese immigrant is swept up into an insane adventure"
              " in which she alone can save existence by exploring other universes and connecting"
              " with the lives she could have led.",
          price: 5.99,
          date: "Thursday 22 Oct",
          time: "18:00 - 20:19",
          imagePath: "assets/images/EEAAO_poster.jpg"),
      Movie(
          id: "dracula",
          name: "Dracula",
          releaseYear: 1931,
          ageRating: "PG",
          description:
              "Transylvanian vampire Count Dracula bends a naive real estate agent"
              " to his will, then takes up residence at a London estate where he sleeps in his"
              " coffin by day and searches for potential victims by night.",
          price: 7.99,
          date: "Friday 23 Oct",
          time: "20:00 - 21:15",
          imagePath: "assets/images/dracula_poster.jpg")
    ];
  }

  Movie? getMovieById(String id) {
    for (final movie in getMovies()) {
      if (movie.id == id) {
        return movie;
      }
    }
    return null;
  }

  Future<List<Movie>> loadMoviesFromAsset(
      {String assetPath = "assets/data/movies.json"}) async {
    final String jsonString = await rootBundle.loadString(assetPath);
    final dynamic decodedData = jsonDecode(jsonString);
    final List<dynamic> jsonList = decodedData as List<dynamic>;
    final List<Movie> loadedMovies = [];

    for (final dynamic item in jsonList) {
      final Map<String, dynamic> itemMap = item as Map<String, dynamic>;
      final Movie movie = Movie.fromJson(itemMap);
      loadedMovies.add(movie);
    }

    _cachedMovies = loadedMovies;
    return loadedMovies;
  }
}
