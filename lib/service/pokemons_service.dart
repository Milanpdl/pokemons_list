import 'package:dio/dio.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';

class PokemonsService {
  final Dio _dio = Dio();

  Future<List<Pokemon>> fetchPokemons({int offset = 0, int limit = 20}) async {
    try {
      final response = await _dio.get(
        "https://pokeapi.co/api/v2/pokemon/",
        queryParameters: {'offset': offset, 'limit': limit},
      );

      final results =
          (response.data['results'] as List).cast<Map<String, dynamic>>();
      final List<Pokemon> pokemons = [];

      // Fetch details in parallel
      final detailsFutures = results.map(
        (pokemon) => fetchPokemonDetails(pokemon['url']),
      );
      final details = await Future.wait(detailsFutures);

      for (int i = 0; i < results.length; i++) {
        final detail = details[i];
        pokemons.add(
          Pokemon(
            name: results[i]['name'] ?? 'Unknown',
            imageUrl: detail['sprites']['front_default'] ?? '',
            types:
                (detail['types'] as List)
                    .map<String>(
                      (type) => type['type']['name']?.toString() ?? 'Unknown',
                    )
                    .toList(),
          ),
        );
      }

      return pokemons;
    } catch (e) {
      throw Exception('Failed to load pokemons: $e');
    }
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    try {
      final response = await _dio.get(url);
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load pokemon details: $e');
    }
  }
}
