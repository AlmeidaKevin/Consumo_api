import 'dart:convert';
import 'package:http/http.dart' as http;

class PokeApiService {
  final String baseUrl = "https://pokeapi.co/api/v2/";

  Future<List<dynamic>> getPokemonListPaginated(int offset, int limit) async {
    final response = await http.get(
      Uri.parse("${baseUrl}pokemon?offset=$offset&limit=$limit"),
    );
    final data = json.decode(response.body);

    List results = data["results"];
    List<Future<dynamic>> futures = results.map((p) async {
      final res = await http.get(Uri.parse(p["url"]));
      return json.decode(res.body);
    }).toList();

    return Future.wait(futures);
  }

  Future<dynamic> getPokemonByName(String name) async {
    final response = await http.get(
      Uri.parse("${baseUrl}pokemon/${name.toLowerCase()}"),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return null;
  }
}
