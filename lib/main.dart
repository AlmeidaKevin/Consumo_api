import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokemon API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00897B), // azul verdoso moderno
        ),
        useMaterial3: true,
      ),
      home: const PokemonPage(),
    );
  }
}

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  static const int firstLoad = 10;
  static const int nextLoad = 5;

  int? expandedIndex;

  late final PagingController<int, Map<String, dynamic>> _pagingController;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;

        if (state.pages == null || state.pages!.isEmpty) {
          return 0;
        }

        return state.keys!.last + 5;
      },
      fetchPage: fetchPokemons,
    );
  }

  Future<List<Map<String, dynamic>>> fetchPokemons(int pageKey) async {
    int limit;
    int offset;

    if (pageKey == 0) {
      limit = firstLoad;
      offset = 0;
    } else {
      limit = nextLoad;
      offset = pageKey;
    }

    final response = await http.get(
      Uri.parse(
        "https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset",
      ),
    );

    if (response.statusCode != 200) {
      throw Exception("Error cargando Pokémon");
    }

    final data = jsonDecode(response.body);
    final List results = data["results"];

    List<Map<String, dynamic>> pokemonList = [];

    for (var pokemon in results) {
      final detail = await http.get(Uri.parse(pokemon["url"]));

      if (detail.statusCode == 200) {
        pokemonList.add(jsonDecode(detail.body));
      }
    }

    return pokemonList;
  }

  Widget buildPokemonCard(Map<String, dynamic> pokemon, int index) {
    final stats = (pokemon["stats"] ?? []) as List;
    final abilities = (pokemon["abilities"] ?? []) as List;
    final types = (pokemon["types"] ?? []) as List;

    bool isExpanded = expandedIndex == index;

    String getStat(int i) {
      if (stats.length > i) {
        return stats[i]["base_stat"].toString();
      }
      return "N/A";
    }

    String firstType() {
      if (types.isNotEmpty) {
        return types[0]["type"]["name"].toString();
      }
      return "N/A";
    }

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 4,
      child: InkWell(
        onTap: () {
          setState(() {
            expandedIndex = expandedIndex == index ? null : index;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                pokemon["sprites"]?["front_default"] ?? "",
                height: 90,
                width: 90,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.catching_pokemon,
                    size: 90,
                  );
                },
              ),

              const SizedBox(height: 10),

              Text(
                pokemon["name"].toString().toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
              ),

              if (isExpanded)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    Text("ID: ${pokemon["id"]}", textAlign: TextAlign.center),
                    Text("Altura: ${pokemon["height"]}", textAlign: TextAlign.center),
                    Text("Peso: ${pokemon["weight"]}", textAlign: TextAlign.center),
                    Text("XP: ${pokemon["base_experience"]}", textAlign: TextAlign.center),
                    Text("Tipo: ${firstType()}", textAlign: TextAlign.center),
                    Text(
                      "Movimientos: ${(pokemon["moves"] as List?)?.length ?? 0}",
                      textAlign: TextAlign.center,
                    ),

                    Text("HP: ${getStat(0)}", textAlign: TextAlign.center),
                    Text("Ataque: ${getStat(1)}", textAlign: TextAlign.center),
                    Text("Defensa: ${getStat(2)}", textAlign: TextAlign.center),
                    Text("Velocidad: ${getStat(5)}", textAlign: TextAlign.center),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokédex Flutter"),
        centerTitle: true,
        backgroundColor: const Color(0xFF00897B),
      ),
      body: PagingListener(
        controller: _pagingController,
        builder: (context, state, fetchNextPage) {
          return PagedListView<int, Map<String, dynamic>>(
            state: state,
            fetchNextPage: fetchNextPage,
            builderDelegate: PagedChildBuilderDelegate(
              itemBuilder: (context, item, index) {
                return buildPokemonCard(item, index);
              },
            ),
          );
        },
      ),
    );
  }
}

