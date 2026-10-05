import 'package:flutter/material.dart';
import 'package:southsea_cinema/models/movie.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(movie.name),
                Text("(${movie.releaseYear})"),
                Text("(${movie.rating})")
              ],
            ),
            Image.asset(
              movie.imagePath,
              width:80,
              height: 80,
              fit: BoxFit.cover
            ),
            const SizedBox(width: 15,)
          ],
        ),
        )
      
      
    );
  }
}