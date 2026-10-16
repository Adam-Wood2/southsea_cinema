class Movie {
  final String id;
  final String name;
  final int releaseYear;
  final String ageRating;
  final String description;
  final double price;
  final String date;
  final String time;
  final String imagePath;


  const Movie(
      {required this.id,
      required this.name,
      required this.releaseYear,
      required this.ageRating,
      required this.description,
      required this.price,
      required this.date,
      required this.time,
      required this.imagePath});

  String get formattedPrice => "£${price.toStringAsFixed(2)}";
}
