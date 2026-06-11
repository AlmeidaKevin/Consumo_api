import 'package:flutter/material.dart';
import 'pages/pokemon/pokemon_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Pokedex Flutter",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      routes: {
        '/': (context) => const PokemonPage(),
        '/pokemon': (context) => const PokemonPage(),
      },
    );
  }
}
