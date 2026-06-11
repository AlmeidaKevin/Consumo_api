import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../services/pokeapi_service.dart';

class PokemonPage extends StatefulWidget {
  const PokemonPage({super.key});

  @override
  State<PokemonPage> createState() => _PokemonPageState();
}

class _PokemonPageState extends State<PokemonPage> {
  final PokeApiService api = PokeApiService();

  static const int pageSize = 5;

  dynamic searchedPokemon;
  bool isLoading = false;
  String searchTerm = "";

  int? openIndex;

  late final PagingController<int, dynamic> _pagingController;

  @override
  void initState() {
    super.initState();

    _pagingController = PagingController(
      getNextPageKey: (state) {
        if (state.lastPageIsEmpty) return null;
        return state.nextIntPageKey;
      },
      fetchPage: _fetchPage,
    );
  }

  Future<List<dynamic>> _fetchPage(int pageKey) async {
    return await api.getPokemonListPaginated(
      pageKey * pageSize,
      pageSize,
    );
  }

  Future<void> searchPokemon() async {
    if (searchTerm.trim().isEmpty) {
      setState(() {
        searchedPokemon = null;
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    searchedPokemon = await api.getPokemonByName(searchTerm);

    setState(() {
      isLoading = false;
    });
  }

  void toggleAccordion(int index) {
    setState(() {
      openIndex = openIndex == index ? null : index;
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Widget _pokemonCard(dynamic p, int index) {
    final abilities = p["abilities"] as List;
    final stats = p["stats"] as List;
    final types = p["types"] as List;

    return InkWell(
      onTap: () => toggleAccordion(index),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.all(6),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                p["sprites"]["front_default"],
                width: 100,
                height: 100,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  "${p["name"]}".toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              if (openIndex == index)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text("ID: ${p["id"]}"),
                      Text("Nombre: ${p["name"]}"),
                      Text("Altura: ${p["height"]}"),
                      Text("Peso: ${p["weight"]}"),

                      Text(
                        "Experiencia Base: ${p["base_experience"]}",
                      ),

                      Text(
                        "Tipo 1: ${types[0]["type"]["name"]}",
                      ),

                      Text(
                        "Cantidad de Tipos: ${types.length}",
                      ),

                      Text(
                        "Cantidad de Habilidades: ${abilities.length}",
                      ),

                      Text(
                        "Cantidad de Movimientos: ${p["moves"].length}",
                      ),

                      Text(
                        "HP: ${stats[0]["base_stat"]}",
                      ),

                      Text(
                        "Ataque: ${stats[1]["base_stat"]}",
                      ),

                      Text(
                        "Defensa: ${stats[2]["base_stat"]}",
                      ),

                      Text(
                        "Ataque Especial: ${stats[3]["base_stat"]}",
                      ),

                      Text(
                        "Defensa Especial: ${stats[4]["base_stat"]}",
                      ),

                      Text(
                        "Velocidad: ${stats[5]["base_stat"]}",
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokédex Infinite Scroll"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText:
                          "Buscar Pokémon por nombre o ID",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => searchTerm = v,
                    onSubmitted: (_) => searchPokemon(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: searchPokemon,
                  child: const Text("Buscar"),
                ),
              ],
            ),

            const SizedBox(height: 10),

            if (isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            if (!isLoading && searchedPokemon != null)
              Expanded(
                child: ListView(
                  children: [
                    _pokemonCard(
                      searchedPokemon,
                      999999,
                    ),
                  ],
                ),
              ),

            if (!isLoading && searchedPokemon == null)
              Expanded(
                child: PagingListener(
                  controller: _pagingController,
                  builder:
                      (
                        context,
                        state,
                        fetchNextPage,
                      ) {
                        return PagedGridView<
                          int,
                          dynamic
                        >(
                          state: state,
                          fetchNextPage: fetchNextPage,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: .75,
                              ),
                          builderDelegate:
                              PagedChildBuilderDelegate<
                                dynamic
                              >(
                                itemBuilder:
                                    (
                                      context,
                                      item,
                                      index,
                                    ) => _pokemonCard(
                                      item,
                                      index,
                                    ),
                              ),
                        );
                      },
                ),
              ),
          ],
        ),
      ),
    );
  }
}