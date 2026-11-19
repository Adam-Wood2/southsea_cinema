import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/main.dart';
import 'package:southsea_cinema/views/home_view.dart';

void main() {
  testWidgets("App displays HomeView as home", (WidgetTester tester) async {
    await tester.pumpWidget(const SouthseaCinemaApp());
    expect(find.byType(HomeView), findsOneWidget);
    expect(find.text("Southsea Cinema & Arts Centre"), findsOneWidget);
  });
}
