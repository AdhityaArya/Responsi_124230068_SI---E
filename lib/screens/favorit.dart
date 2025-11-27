// lib/screens/favorite_page.dart (Revisi Sqflite)

import 'package:flutter/material.dart';
import '../services/authentication.dart';
import '../services/api_service.dart';
import '../models/makanan.dart';
import 'detail.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<Restaurant>> _favoritesFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _dbHelper.getFavorites();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _dbHelper.getFavorites();
    });
  }

  void _removeFavorite(String id) async {
    await _dbHelper.removeFavorite(id);
    _refreshFavorites();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorit dihapus.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorit'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Restaurant>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return const Center(child: Text('Belum ada restoran di favorit.'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final restaurant = favorites[index];
              return _buildFavoriteItem(restaurant);
            },
          );
        },
      ),
    );
  }

  Widget _buildFavoriteItem(Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Image.network(
          '${ApiService.smallPictureUrl}${restaurant.pictureId}',
          width: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 50),
        ),
        title: Text(restaurant.name ?? 'Nama Restoran'),
        subtitle: Row(
          children: [
            const Icon(Icons.location_on, size: 14.0),
            Text('${restaurant.city ?? 'Kota'} '),
            const Icon(Icons.star, color: Colors.amber, size: 14.0),
            Text(restaurant.rating.toString()),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeFavorite(restaurant.id!),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                restaurantId: restaurant.id!,
                name: restaurant.name!,
              ),
            ),
          ).then((_) => _refreshFavorites());
        },
      ),
    );
  }
}
