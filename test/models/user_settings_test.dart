import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/models/user_settings.dart';

void main() {
  group("User settings model tests", () {
    test("UserSettings defaults to empty values and false newsletter", () {
      const UserSettings settings = UserSettings();

      expect(settings.address, isEmpty);
      expect(settings.email, isEmpty);
      expect(settings.patronNumber, isEmpty);
      expect(settings.receiveNewsletter, isFalse);
    });

    test("UserSettings stores configured values", () {
      const UserSettings settings = UserSettings(
          email: "email@gmail.com",
          address: "Address",
          patronNumber: "1234",
          receiveNewsletter: true);

      expect(settings.address, "Address");
      expect(settings.email, "email@gmail.com");
      expect(settings.patronNumber, "1234");
      expect(settings.receiveNewsletter, isTrue);
    });
  });
}
