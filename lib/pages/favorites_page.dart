import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../services/cart_service.dart';
import '../utils/format.dart';
import '../data/menu_data.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final CartService _cartService = CartService.instance;

  List<MenuItem> get _favoriteMenus {
    return menuData.where((m) => _cartService.isFavorite(m.id)).toList();
  }

  void _toggleFavorite(MenuItem item) {
    setState(() {
      _cartService.toggleFavorite(item.id);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _cartService.isFavorite(item.id)
                ? '${item.name} ditambahkan ke favorit'
                : '${item.name} dihapus dari favorit',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  void _addToCart(MenuItem item) {
    final cartItem = CartItem(
      menu: item,
      quantity: 1,
      portion: 'Biasa',
      withAddon: false,
      note: '',
    );
    _cartService.addToCart(cartItem);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${item.name} ditambahkan ke keranjang'),
          duration: const Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteMenus = _favoriteMenus;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Favorit'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: favoriteMenus.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada menu favorit',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tekan ikon hati di daftar menu untuk menambah favorit',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.restaurant_menu),
                    label: const Text('Lihat Daftar Menu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteMenus.length,
              itemBuilder: (context, index) {
                final item = favoriteMenus[index];
                final isFav = _cartService.isFavorite(item.id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/detail',
                      arguments: item,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.deepOrange.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(item.emoji, style: const TextStyle(fontSize: 32)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text('${item.rating}'),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.category,
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(item.price),
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus dari favorit',
                            icon: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.red : Colors.grey,
                            ),
                            onPressed: () => _toggleFavorite(item),
                          ),
                          IconButton(
                            tooltip: 'Tambah ke keranjang',
                            icon: const Icon(Icons.add_shopping_cart, color: Colors.deepOrange),
                            onPressed: () => _addToCart(item),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}