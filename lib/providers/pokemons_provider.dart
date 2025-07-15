import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';
import 'package:pokemons_app/service/pokemons_service.dart';

final pokemonServiceProvider = Provider((ref) => PokemonsService());

final pokemonListProvider = FutureProvider<List<Pokemon>>((ref) async {
  final service = ref.read(pokemonServiceProvider);
  final pokemons = await service.fetchPokemons();

  final List<Pokemon> detailedPokemons = [];
  for (final pokemon in pokemons) {
    try {
      final details = await service.fetchPokemonDetails(pokemon['url']);

      final sprites = details['sprites'] as Map<String, dynamic>?;
      final typesData = details['types'] as List?;

      detailedPokemons.add(
        Pokemon(
          name: pokemon['name']?.toString() ?? 'Unknown',
          imageUrl: sprites?['front_default']?.toString() ?? '',
          types:
              typesData != null
                  ? typesData
                      .map((type) => type['type']['name'].toString())
                      .toList()
                  : [],
        ),
      );
    } catch (e) {
      print('Error loading ${pokemon['name']}: $e');
    }
  }
  return detailedPokemons;
});

final filterProvider = StateProvider<String>((ref) => '');

final filteredPokemonsProvider = Provider<List<Pokemon>>((ref) {
  final filter = ref.watch(filterProvider);
  final pokemons = ref.watch(pokemonListProvider).value ?? [];

  if (filter.isEmpty) return pokemons;

  return pokemons.where((pokemon) {
    return pokemon.name.toLowerCase().contains(filter.toLowerCase());
  }).toList();
});
