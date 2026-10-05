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
              children: [
                Text(movie.name, style: listingTitleStyle,),
                Text("(${movie.releaseYear})"),
                Text("(${movie.rating})")
              ],
            ),
            Image.asset(
              movie.imagePath,
              width: 240,
              height: 360,
              fit: BoxFit.cover
            ),
            const SizedBox(width: 15,)
          ],
        ),
        )
      
      
    );
  }
}