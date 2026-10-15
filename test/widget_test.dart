import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/movie_listing.dart';
import 'package:southsea_cinema/widgets/movie_card.dart';

void main() {
  group("App smoke tests", (){
    testWidgets("App displays HomeView as home", (WidgetTester tester) async {
      await tester.pumpWidget(const SouthseaCinemaApp());
      expect(find.byType(HomeView), findsOneWidget);
      expect(find.text("Southsea Cinema & Arts Centre"), findsOneWidget);
    });

    testWidgets("Displays movie cards with name, prices, dates and ratings", (WidgetTester tester) async {
      await tester.pumpWidget(SouthseaCinemaApp());
      await tester.pumpAndSettle();
      
      expect(find.text("Everything Everywhere All At Once"), findsOneWidget);
      expect(find.text("£5.99"), findsOneWidget);
      expect(find.text("(2022) "), findsOneWidget);
      expect(find.text("(PG15) "), findsOneWidget);

      await tester.scrollUntilVisible(find.text("Dracula"), 100);

      expect(find.text("Dracula"), findsOneWidget);
      expect(find.text("£7.99"), findsOneWidget);
      expect(find.text("(1931) "), findsOneWidget);
      expect(find.text("(PG) "), findsOneWidget);

      expect(find.text("Book Now"), findsNWidgets(2));
      expect(find.byType(MovieCard), findsNWidgets(2));
    });
  });
}
