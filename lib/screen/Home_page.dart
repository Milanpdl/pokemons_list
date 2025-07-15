import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pokemons_app/providers/pokemons_provider.dart';
import 'package:pokemons_app/screen/widget/pokemons_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final pokemons = ref.watch(filteredPokemonsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Pokemons')),
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
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged:
                    (value) => ref.read(filterProvider.notifier).state = value,
              ),
            ),
          ),
          Expanded(
            child: switch (ref.watch(pokemonListProvider)) {
              AsyncData(:final value) => ListView.builder(
                itemCount: pokemons.length,
                itemBuilder: (context, index) {
                  final pokemon = pokemons[index];
                  return PokemonsWidget_cards(pokemon: pokemon);
                },
              ),
              AsyncError(:final error) => Center(child: Text('Error: $error')),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }
}
