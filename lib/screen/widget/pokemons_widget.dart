import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';

class PokemonsWidget_cards extends StatelessWidget {
  const PokemonsWidget_cards({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: pokemon.imageUrl,
          placeholder: (context, url) => const CircularProgressIndicator(),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(
          pokemon.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          pokemon.types.join(", "),
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
