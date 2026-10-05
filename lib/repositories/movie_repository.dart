import 'package:southsea_cinema/models/movie.dart';

class MovieRepository {
  List<Movie> getMovies() {
    return const [
      Movie(
        id: "everything-everywhere", 
        name: "Everything Everywhere All At Once",
        releaseYear: 2022,
        rating: "PG15", 
        description: "A middle-aged Chinese immigrant is swept up into an insane adventure" + 
        " in which she alone can save existence by exploring other universes and connecting" +
        " with the lives she could have led.", 
        price: 5.99, 
        date: "Thursday 22 Oct", 
        time: "18:00 - 20:19", 
        imagePath: "assets/images/EEAAO_poster.jpg"
      ),
      Movie(
        id: "dracula", 
        name: "Dracula", 
        releaseYear: 1931, 
        rating: "PG", 
        description: "Transylvanian vampire Count Dracula bends a naive real estate agent" + 
        " to his will, then takes up residence at a London estate where he sleeps in his" + 
        " coffin by day and searches for potential victims by night.", 
        price: 7.99, 
        date: "Friday 23 Oct", 
        time: "20:00 - 21:15", 
        imagePath: "assets/images/dracula_poster.jpg"
      )
    ];
  }
}