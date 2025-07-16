import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';

import 'package:pokemons_app/providers/pokemons_provider.dart';
import 'package:pokemons_app/screen/widget/pokemons_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      ref.read(pokemonListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pokemons = ref.watch(filteredPokemonsProvider);
    final pokemonState = ref.watch(pokemonListProvider);
    final isLoadingMore =
        pokemonState.isLoading && pokemonState.pokemons.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokemons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(pokemonListProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey, // Shadow below
                    offset: Offset(4, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: Colors.white, // Light above
                    offset: Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: "Search Box",
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref.read(filterProvider.notifier).state = '';
                            },
                          )
                          : null,
                ),
                onChanged:
                    (value) => ref.read(filterProvider.notifier).state = value,
              ),
            ),
          ),
          Expanded(
            child: _buildBody(
              ref,
              pokemonState,
              pokemons,
              isLoadingMore,
              _scrollController,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildBody(
  WidgetRef ref,
  PokemonListState state,
  List<Pokemon> pokemons,
  bool isLoadingMore,
  ScrollController _scrollController,
) {
  // Initial loading
  if (state.pokemons.isEmpty && state.isLoading) {
    return const Center(child: CircularProgressIndicator());
  }

  // Error state
  if (state.error != null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            state.error!,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(pokemonListProvider.notifier).refresh(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Empty state
  if (pokemons.isEmpty) {
    return const Center(
      child: Text('No Pokémon found', style: TextStyle(fontSize: 18)),
    );
  }

  // Main list view
  return RefreshIndicator(
    onRefresh: () => ref.read(pokemonListProvider.notifier).refresh(),
    child: ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount:
          pokemons.length + (isLoadingMore ? 1 : 0) + (state.hasMore ? 0 : 1),
      itemBuilder: (context, index) {
        if (index == pokemons.length) {
          if (isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (!state.hasMore) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No more Pokémon to load')),
            );
          }
        }

        if (index < pokemons.length) {
          final pokemon = pokemons[index];
          return PokemonsWidget_cards(pokemon: pokemon);
        }

        return const SizedBox.shrink();
      },
    ),
  );
}
