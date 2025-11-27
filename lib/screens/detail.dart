// lib/screens/detail.dart

import 'package:flutter/material.dart';
import '../models/makanan.dart';
import '../services/api_service.dart';
import '../services/authentication.dart';

class DetailScreen extends StatefulWidget {
  final String restaurantId;
  final String name;

  const DetailScreen({
    super.key,
    required this.restaurantId,
    required this.name,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final ApiService _apiService = ApiService();
  final DatabaseHelper _dbHelper = DatabaseHelper();
  late Future<RestaurantDetailResult> _detailFuture;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _detailFuture = _apiService.fetchRestaurantDetail(widget.restaurantId);
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final result = await _dbHelper.getFavoriteById(widget.restaurantId);
    setState(() {
      _isFavorite = result.isNotEmpty;
    });
  }

  // Fungsi Toggle Favorit (Soal No. 3)
  Future<void> _toggleFavorite(RestaurantDetail detail) async {
    final restaurantLite = Restaurant(
      id: detail.id,
      name: detail.name,
      description: detail.description,
      pictureId: detail.pictureId,
      city: detail.city,
      rating: detail.rating,
    );

    if (_isFavorite) {
      await _dbHelper.removeFavorite(restaurantLite.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dihapus dari Favorit'),
          backgroundColor: Colors.red,
        ), // Snackbar merah
      );
    } else {
      await _dbHelper.insertFavorite(restaurantLite);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ditambahkan ke Favorit'),
          backgroundColor: Colors.green,
        ), // Snackbar hijau
      );
    }
    _checkFavoriteStatus(); // Update status icon
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<RestaurantDetailResult>(
        future: _detailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.restaurant == null) {
            return const Center(child: Text('Detail data tidak ditemukan.'));
          }

          final detail = snapshot.data!.restaurant;
          return CustomScrollView(
            slivers: <Widget>[
              _buildSliverAppBar(detail),
              SliverList(
                delegate: SliverChildListDelegate([_buildContent(detail)]),
              ),
            ],
          );
        },
      ),
    );
  }

  // AppBar dengan Gambar dan Tombol Favorit
  Widget _buildSliverAppBar(RestaurantDetail detail) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.blueAccent,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.all(16.0),
        title: Text(
          detail.name ?? 'Detail',
          style: const TextStyle(fontSize: 16.0),
        ),
        background: detail.pictureId != null
            ? Hero(
                tag: detail.pictureId!,
                child: Image.network(
                  '${ApiService.mediumPictureUrl}${detail.pictureId}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image, size: 50)),
                ),
              )
            : const Center(child: Icon(Icons.image_not_supported)),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : Colors.white,
          ),
          onPressed: () => _toggleFavorite(detail),
        ),
      ],
    );
  }

  // Konten Detail Restoran (Soal No. 3)
  Widget _buildContent(RestaurantDetail detail) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama & Rating
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  detail.name ?? '-',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.cyan),
                  Text(
                    detail.rating.toString(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Lokasi & Alamat
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: Colors.grey),
              Expanded(
                child: Text(
                  '${detail.city} - ${detail.address}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Kategori
          Text('Kategori:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: detail.categories
                .map(
                  (c) => Chip(
                    label: Text(c.name, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
          ),
          const Divider(height: 24),

          Text('Deskripsi:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(detail.description ?? 'Deskripsi tidak tersedia.'),
          const Divider(height: 24),

          Text('Menu Makanan:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: detail.menus.foods
                .map(
                  (m) => Chip(
                    label: Text(m.name),
                    backgroundColor: Colors.orange.shade100,
                  ),
                )
                .toList(),
          ),
          const Divider(height: 24),

          Text('Menu Minuman:', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            children: detail.menus.drinks
                .map(
                  (m) => Chip(
                    label: Text(m.name),
                    backgroundColor: Colors.blue.shade100,
                  ),
                )
                .toList(),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
