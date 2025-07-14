import 'package:dio/dio.dart';

class PokemonsService {
  final Dio _dio = Dio();
  Future<List<Map<String, dynamic>>> fetchPokemons() async {
    final response = await _dio.get(
      "https://pokeapi.co/api/v2/pokemon/",
      queryParameters: {"limit": 100},
    );
    return (response.data['results'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> fetchPokemonDetails(String url) async {
    final response = await _dio.get(url);
    return response.data as Map<String, dynamic>;
  }
}
