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
        imagePath: "assets/images/Dracula.jpg"
      );

      expect(movie.id, "dracula");
      expect(movie.name, "Dracula");
      expect(movie.releaseYear, 1931);
      expect(movie.description, "Dracula Movie Description");
      expect(movie.price, 5.99);
      expect(movie.date, "Thursday 21st Feb");
      expect(movie.time, "10:00 - 12:00");
      expect(movie.imagePath, "assets/images/Dracula.jpg");

      }
    );

    group("Movie model formattedPrice tests", () {
      test("formattedPrice returns price 7.50 with pound sign and two decimals", (){
        const movie = Movie(
          id: "dracula", 
          name: "Dracula", 
          releaseYear: 1931, 
          ageRating: "PG", 
          description: "Dracula Movie Description", 
          price: 7.5, 
          date: "Thursday 21st Feb", 
          time: "10:00 - 12:00", 
          imagePath: "assets/images/Dracula.jpg"
        );

        expect(movie.formattedPrice, "£7.50");
        }
      );

      test("formattedPrice returns price below 1 with pound sign and two decimals", () {
        const movie = Movie(
          id: "dracula", 
          name: "Dracula", 
          releaseYear: 1931, 
          ageRating: "PG", 
          description: "Dracula Movie Description", 
          price: 0.75, 
          date: "Thursday 21st Feb", 
          time: "10:00 - 12:00", 
          imagePath: "assets/images/Dracula.jpg"
        );

        expect(movie.formattedPrice, "£0.75");
      });

      test("formattedPrice returns price with no pence with pound sign and two decimals", () {
        const movie = Movie(
          id: "dracula", 
          name: "Dracula", 
          releaseYear: 1931, 
          ageRating: "PG", 
          description: "Dracula Movie Description", 
          price: 7, 
          date: "Thursday 21st Feb", 
          time: "10:00 - 12:00", 
          imagePath: "assets/images/Dracula.jpg"
        );

        expect(movie.formattedPrice, "£7.00");
      });
    }
  );
  }
  );
}