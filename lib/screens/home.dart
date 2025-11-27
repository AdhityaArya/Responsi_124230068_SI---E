// lib/screens/home.dart

import 'package:flutter/material.dart';
import '/services/authentication.dart';
import '/services/api_service.dart';
import '/models/makanan.dart';
import '/screens/login.dart';
import '/screens/detail.dart';
import '/screens/favorit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  String _username = 'Loading...';
  String _currentFilter = 'Semua';
  late Future<RestaurantListResult> _restaurantsFuture;

  final List<String> _categories = [
    'Semua',
    'Italia',
    'Modern',
    'Sunda',
    'Jawa',
    'Bali',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsername();
    _restaurantsFuture = _fetchRestaurants('Semua');
  }

  void _loadUsername() async {
    final username = await AuthPreferenceHelper().getUsername();
    setState(() {
      _username = username ?? 'Guest';
    });
  }

  Future<RestaurantListResult> _fetchRestaurants(String filter) async {
    if (filter == 'Semua') {
      return _apiService.fetchAllRestaurants();
    } else {
      return _apiService.searchRestaurants(filter);
    }
  }

  void _setFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _restaurantsFuture = _fetchRestaurants(filter);
    });
  }

  void _logout() async {
    await AuthPreferenceHelper().logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, $_username!'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritePage()),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.exit_to_app), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: _categories.map((category) {
          final isSelected = _currentFilter == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: Colors.blue,
              onSelected: (selected) {
                if (selected) {
                  _setFilter(category);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildList() {
    return FutureBuilder<RestaurantListResult>(
      future: _restaurantsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.restaurants.isEmpty) {
          return const Center(child: Text('Tidak ada restoran ditemukan.'));
        }

        final restaurants = snapshot.data!.restaurants;

        return ListView.builder(
          itemCount: restaurants.length,
          itemBuilder: (context, index) {
            final restaurant = restaurants[index];
            return _buildRestaurantItem(context, restaurant);
          },
        );
      },
    );
  }

  Widget _buildRestaurantItem(BuildContext context, Restaurant restaurant) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(8.0),
        leading: Hero(
          tag: restaurant.pictureId ?? restaurant.id!,
          child: Image.network(
            '${ApiService.smallPictureUrl}${restaurant.pictureId}',
            width: 100,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.broken_image, size: 50),
          ),
        ),
        title: Text(restaurant.name ?? 'Nama Restoran'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, size: 14.0),
                const SizedBox(width: 4),
                Text(restaurant.city ?? 'Kota'),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.star, color: Colors.blueAccent, size: 14.0),
                const SizedBox(width: 4),
                Text(restaurant.rating.toString()),
              ],
            ),
          ],
        ),
        onTap: () {
          // Arahkan ke Detail Screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(
                restaurantId: restaurant.id!,
                name: restaurant.name!,
              ),
            ),
          );
        },
      ),
    );
  }
}

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
        backgroundColor: Colors.blueAccent,
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
            const Icon(Icons.star, color: Colors.cyan, size: 14.0),
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
          ).then((_) => _refreshFavorites()); // Refresh saat kembali
        },
      ),
    );
  }
}
