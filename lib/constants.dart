import 'package:flutter/material.dart';

const String appTitle = 'Southsea Cinema & Arts Centre';

const Color cinemaBrand = Color(0xFF55BEDE);
const Color cinemaBrandLight = Color(0xFF7FCEE6);
const Color cinemaBrandDark = Color(0xFF3FB5D9);

const Color cinemaBackground = Color(0xFF1B1E28);
const Color cinemaFontWhite = Color(0xFFFFFFFF);
const Color cinemaFontMuted = Color(0xFF8A90A0);
const Color cinemaSurface = Color(0xFF242936);

const TextStyle cinemaHeaderStyle = TextStyle(
  color: cinemaFontWhite,
  fontSize: 18,
  fontWeight: FontWeight.bold,
);

const TextStyle listingTitleStyle = TextStyle(
  color: cinemaFontWhite,
  fontSize: 30,
  fontWeight: FontWeight.bold
);

const TextStyle listingDescriptionStyle = TextStyle(
  color: cinemaFontWhite,
  fontSize: 18
);

const ButtonStyle dropdownButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll<Color>(cinemaSurface),
  foregroundColor: WidgetStatePropertyAll<Color>(cinemaFontWhite),
);

const MenuStyle dropdownMenuStyle = MenuStyle(
  backgroundColor: WidgetStatePropertyAll(cinemaSurface)
);

const TextStyle dropdownTextStyle = TextStyle(
  color: cinemaFontWhite
);

const ButtonStyle cinemaButtonStyle = ButtonStyle(
  backgroundColor: WidgetStatePropertyAll<Color>(cinemaSurface),
  foregroundColor: WidgetStatePropertyAll<Color>(cinemaFontWhite),
);