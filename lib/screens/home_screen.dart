import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:pokedex_app/screens/PokemonDetailScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<dynamic> _pokemonList;
  bool _isLoading = true;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _fetchPokemonData();
  }

  Future<void> _fetchPokemonData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://pokeapi.co/api/v2/pokemon/?limit=100')); // Fetching first 100 Pokemon
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pokemonList = data['results'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Pokemon data');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchPokemon(String value) {
    setState(() {
      _searchTerm = value.toLowerCase();
    });
  }

  List<dynamic> getFilteredPokemonList() {
    if (_searchTerm.isEmpty) {
      return _pokemonList;
    } else {
      return _pokemonList
          .where((pokemon) =>
              pokemon['name'].toString().toLowerCase().contains(_searchTerm))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pokedex'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Pokemon',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _searchPokemon,
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    children: getFilteredPokemonList().map<Widget>((pokemon) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PokemonDetailScreen(
                                pokemonName: pokemon['name'],
                              ),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Lottie.asset(
                                'assets/pokeball.json',
                                height: 100,
                                width: 100,
                              ),
                              Text(
                                pokemon['name'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}
