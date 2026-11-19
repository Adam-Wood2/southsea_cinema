import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:southsea_cinema/constants.dart';
import 'package:southsea_cinema/views/basket_view.dart';
import 'package:southsea_cinema/views/home_view.dart';
import 'package:southsea_cinema/views/settings_view.dart';

bool isSupportPlatform() {
  if (kIsWeb) {
    return false;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return true;
  }
  return false;
}

void main() {
  if (isSupportPlatform()) {
    runApp(const SouthseaCinemaApp());
  } else {
    runApp(const UnsupportedPlatformApp());
  }
}

class UnsupportedPlatformApp extends StatelessWidget {
  const UnsupportedPlatformApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
            body: Center(
          child: Padding(
            padding: EdgeInsets.all(25.0),
            child: Text(
                "This app saves orders with SQLite and only runs on Android devices or emulators"),
          ),
        )));
  }
}

class SouthseaCinemaApp extends StatefulWidget {
  const SouthseaCinemaApp({super.key});

  @override
  State<SouthseaCinemaApp> createState() => _SouthseaCinemaAppState();
}

class _SouthseaCinemaAppState extends State<SouthseaCinemaApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final SharedPreferencesAsync prefs = SharedPreferencesAsync();
    final bool? useDarkMode = await prefs.getBool(prefDarkMode);

    if (!mounted || useDarkMode == null) {
      return;
    }

    setState(() {
      _themeMode = useDarkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _updateThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: cinemaLightBackground,
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: cinemaFontBlack,
              displayColor: cinemaFontBlack,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cinemaLightBackground,
          iconTheme: IconThemeData(color: cinemaBrand),
          titleTextStyle: TextStyle(
            color: cinemaFontBlack,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          brightness: Brightness.light,
          primary: cinemaBrand,
          surface: cinemaLightBackground,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: cinemaBackground,
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: cinemaFontWhite,
              displayColor: cinemaFontWhite,
            ),
        appBarTheme: const AppBarTheme(
          backgroundColor: cinemaSurface,
          iconTheme: IconThemeData(color: cinemaBrand),
          titleTextStyle: cinemaHeaderStyle,
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: cinemaBrand,
          brightness: Brightness.dark,
          primary: cinemaBrand,
          surface: cinemaSurface,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeView(),
        '/basket': (context) => const BasketView(),
        '/settings': (context) =>
            SettingsView(onThemeModeSaved: _updateThemeMode)
      },
    );
  }
}
