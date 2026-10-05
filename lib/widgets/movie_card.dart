import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/movie.dart';
import 'package:southsea_cinema/constants.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cinemaSurface,
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(movie.name, style: listingTitleStyle,)),
                Text("  (${movie.releaseYear}) "),
                Text(" (${movie.rating}) "),
                
              ],
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final imageWidth = (constraints.maxWidth * 0.35).clamp(100.0, 200.0);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: imageWidth,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Image.asset(
                          movie.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(child: Text(movie.description, )),
                  ],
                );
              },
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${movie.date} ${movie.time}"),
                ElevatedButton.icon(
                              onPressed: (){},
                              icon: Icon(Icons.shopping_cart), 
                              label: Text("Book Now"),
                              style: cinemaButtonStyle,
                )
              ],
            )
          ],
        ),
        )
      
      
    );
  }
}