class BookingItem {
  final int? id;
  final int bookingId;
  final String movieId;
  final String movieName;
  final double unitPrice;
  final int quantity;

  const BookingItem({
    this.id,
    required this.bookingId,
    required this.movieId,
    required this.movieName,
    required this.unitPrice,
    required this.quantity,
  });

  factory BookingItem.fromMap(Map<String, Object?> map) {
    final num unitPriceNumber = map["unitPrice"] as num;

    return BookingItem(
      id: map["id"] as int?,
      bookingId: map["bookingId"] as int,
      movieId: map["movieId"] as String,
      movieName: map["movieName"] as String,
      unitPrice: unitPriceNumber.toDouble(),
      quantity: map["quantity"] as int,
    );
  }

  Map<String, Object?> toMap() {
    final Map<String, Object?> data = <String, Object?>{
      "bookingId": bookingId,
      "movieId": movieId,
      "movieName": movieName,
      "unitPrice": unitPrice,
      "quantity": quantity,
    };

    if (id != null) {
      data["id"] = id;
    }
    return data;
  }
}
