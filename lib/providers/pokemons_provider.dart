import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';
import 'package:pokemons_app/service/pokemons_service.dart';

final pokemonServiceProvider = Provider((ref) => PokemonsService());

class PokemonListState {
  final List<Pokemon> pokemons;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  PokemonListState({
    required this.pokemons,
    this.isLoading = false,
    this.hasMore = true,
    this.page = 0,
    this.error,
  });

  PokemonListState copyWith({
    List<Pokemon>? pokemons,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return PokemonListState(
      pokemons: pokemons ?? this.pokemons,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error ?? this.error,
    );
  }
}

class PokemonListNotifier extends StateNotifier<PokemonListState> {
  final Ref ref;
  static const int pageSize = 10;

  PokemonListNotifier(this.ref) : super(PokemonListState(pokemons: [])) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    if (state.pokemons.isNotEmpty) return;
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(pokemonServiceProvider);
      final newPokemons = await service.fetchPokemons(
        offset: state.page * pageSize,
        limit: pageSize,
      );

      state = state.copyWith(
        pokemons: [...state.pokemons, ...newPokemons],
        isLoading: false,
        page: state.page + 1,
        hasMore: newPokemons.length == pageSize,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load Pokémon: $e',
      );
    }
  }

  Future<void> refresh() async {
    state = PokemonListState(pokemons: []);
    await loadInitialData();
  }
}

final pokemonListProvider =
    StateNotifierProvider<PokemonListNotifier, PokemonListState>(
      (ref) => PokemonListNotifier(ref),
    );

// final pokemonListProvider = FutureProvider<List<Pokemon>>((ref) async {
//   final service = ref.read(pokemonServiceProvider);
//   final pokemons = await service.fetchPokemons();

//   final List<Pokemon> detailedPokemons = [];
//   for (final pokemon in pokemons) {
//     try {
//       final details = await service.fetchPokemonDetails(pokemon['url']);

//       final sprites = details['sprites'] as Map<String, dynamic>?;
//       final typesData = details['types'] as List?;

//       detailedPokemons.add(
//         Pokemon(
//           name: pokemon['name']?.toString() ?? 'Unknown',
//           imageUrl: sprites?['front_default']?.toString() ?? '',
//           types:
//               typesData != null
//                   ? typesData
//                       .map((type) => type['type']['name'].toString())
//                       .toList()
//                   : [],
//         ),
//       );
//     } catch (e) {
//       print('Error loading ${pokemon['name']}: $e');
//     }
//   }
//   return detailedPokemons;
// });

final filterProvider = StateProvider<String>((ref) => '');

final filteredPokemonsProvider = Provider<List<Pokemon>>((ref) {
  final filter = ref.watch(filterProvider);
  final pokemons = ref.watch(pokemonListProvider).pokemons;

  if (filter.isEmpty) return pokemons;

  return pokemons.where((pokemon) {
    return pokemon.name.toLowerCase().contains(filter.toLowerCase());
  }).toList();
});
