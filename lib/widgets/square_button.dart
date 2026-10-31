import 'package:flutter/material.dart';
import 'package:southsea_cinema/constants.dart';

class SquareButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Widget? icon;

  const SquareButton(
      {super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return ElevatedButton(
          style: cinemaButtonStyle, onPressed: onPressed, child: Text(label));
    } else {
      return ElevatedButton.icon(
          style: cinemaButtonStyle,
          onPressed: onPressed,
          label: Text(label),
          icon: icon);
    }
  }
}
