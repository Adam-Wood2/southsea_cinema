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

  factory Movie.fromJson(Map<String, dynamic> json) {
    final String id = json["id"] as String;
    final String name = json["name"] as String;
    final int releaseYear = json["releaseYear"] as int;
    final String ageRating = json["ageRating"] as String;
    final String description = json["description"] as String;
    final num priceNum = json["price"] as num;
    final double price = priceNum.toDouble();
    final String date = json["date"] as String;
    final String time = json["time"] as String;
    final String imagePath = json["imagePath"] as String;

    return Movie(
        id: id,
        name: name,
        releaseYear: releaseYear,
        ageRating: ageRating,
        description: description,
        price: price,
        date: date,
        time: time,
        imagePath: imagePath);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      "id": id,
      "name": name,
      "releaseYear": releaseYear,
      "ageRating": ageRating,
      "description": description,
      "price": price,
      "date": date,
      "time": time,
      "imagePath": imagePath
    };
    return data;
  }

  String get formattedPrice => "£${price.toStringAsFixed(2)}";
}
