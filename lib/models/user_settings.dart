class UserSettings {
  final String address;
  final String email;
  final String patronNumber;
  final bool receiveNewsletter;

  UserSettings(
      {this.email = "",
      this.address = "",
      this.patronNumber = "",
      this.receiveNewsletter = false});
}
