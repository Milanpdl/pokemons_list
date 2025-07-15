import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokemons_app/Models/pokemon_model.dart';

class PokemonsWidget_cards extends StatelessWidget {
  const PokemonsWidget_cards({super.key, required this.pokemon});
  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Soft background
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey, // Dark shadow bottom right
            offset: Offset(6, 6),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.white, // Light shadow top left
            offset: Offset(-6, -6),
            blurRadius: 10,
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: const Color.fromARGB(255, 240, 239, 239),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(8.0),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: pokemon.imageUrl,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          title: Text(
            pokemon.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          subtitle: Text(
            pokemon.types.join(", "),
            style: TextStyle(color: const Color.fromARGB(255, 73, 73, 73)),
          ),
        ),
      ),
    );
  }
}
