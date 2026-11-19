import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/movie.dart';

void main() {
  group("Movie model tests", () {
    test("Creates Movie instance with given properties", () {
      const movie = Movie(
          id: "dracula",
          name: "Dracula",
          releaseYear: 1931,
          ageRating: "PG",
          description: "Dracula Movie Description",
          price: 5.99,
          date: "Thursday 21st Feb",
          time: "10:00 - 12:00",
          imagePath: "assets/images/Dracula.jpg");

      expect(movie.id, "dracula");
      expect(movie.name, "Dracula");
      expect(movie.releaseYear, 1931);
      expect(movie.description, "Dracula Movie Description");
      expect(movie.price, 5.99);
      expect(movie.date, "Thursday 21st Feb");
      expect(movie.time, "10:00 - 12:00");
      expect(movie.imagePath, "assets/images/Dracula.jpg");
    });

    group("Movie model formattedPrice tests", () {
      test("formattedPrice returns price 7.50 with pound sign and two decimals",
          () {
        const movie = Movie(
            id: "dracula",
            name: "Dracula",
            releaseYear: 1931,
            ageRating: "PG",
            description: "Dracula Movie Description",
            price: 7.5,
            date: "Thursday 21st Feb",
            time: "10:00 - 12:00",
            imagePath: "assets/images/Dracula.jpg");

        expect(movie.formattedPrice, "£7.50");
      });

      test(
          "formattedPrice returns price below 1 with pound sign and two decimals",
          () {
        const movie = Movie(
            id: "dracula",
            name: "Dracula",
            releaseYear: 1931,
            ageRating: "PG",
            description: "Dracula Movie Description",
            price: 0.75,
            date: "Thursday 21st Feb",
            time: "10:00 - 12:00",
            imagePath: "assets/images/Dracula.jpg");

        expect(movie.formattedPrice, "£0.75");
      });

      test(
          "formattedPrice returns price with no pence with pound sign and two decimals",
          () {
        const movie = Movie(
            id: "dracula",
            name: "Dracula",
            releaseYear: 1931,
            ageRating: "PG",
            description: "Dracula Movie Description",
            price: 7,
            date: "Thursday 21st Feb",
            time: "10:00 - 12:00",
            imagePath: "assets/images/Dracula.jpg");

        expect(movie.formattedPrice, "£7.00");
      });

      test("JSON conversion preserves every movie field", () {
        final Map<String, dynamic> data = <String, dynamic>{
          "id": "movie",
          "name": "name",
          "releaseYear": 2000,
          "ageRating": "PG",
          "description": "desc",
          "price": 10.0,
          "date": "date",
          "time": "time",
          "imagePath": "PATH"
        };
        final Movie movie = Movie.fromJson(data);
        expect(movie.id, "movie");
        expect(movie.name, "name");
        expect(movie.releaseYear, 2000);
        expect(movie.ageRating, "PG");
        expect(movie.description, "desc");
        expect(movie.price, 10.0);
        expect(movie.date, "date");
        expect(movie.time, "time");
        expect(movie.imagePath, "PATH");
        expect(movie.toJson(), data);
      });

      test("fromJson accepts accepts a whole number price", () {
        final Map<String, dynamic> data = <String, dynamic>{
          "id": "movie",
          "name": "name",
          "releaseYear": 2000,
          "ageRating": "PG",
          "description": "desc",
          "price": 5,
          "date": "date",
          "time": "time",
          "imagePath": "PATH"
        };

        final Movie movie = Movie.fromJson(data);
        expect(movie.price, 5.0);
        expect(movie.price, isA<double>());
      });
    });
  });
}
