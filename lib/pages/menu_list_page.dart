import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../services/cart_service.dart';
import '../utils/format.dart';

class MenuListPage extends StatefulWidget {
  const MenuListPage({super.key});

  @override
  State<MenuListPage> createState() => _MenuListPageState();
}

class _MenuListPageState extends State<MenuListPage> {
  static const List<String> _categories = [
    'Semua',
    'Makanan',
    'Minuman',
    'Camilan',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedCategory = 'Semua';
  final CartService _cartService = CartService.instance;

  List<MenuItem> get _filteredMenu {
    return menuData.where((m) {
      final matchCategory =
          _selectedCategory == 'Semua' || m.category == _selectedCategory;
      final matchQuery = m.name.toLowerCase().contains(_query.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  List<MenuItem> get _recommendedMenus => _cartService.getRecommendedMenus(limit: 4);

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildMenuCard(MenuItem item, {bool showActions = true, bool compact = false}) {
    final isFav = _cartService.isFavorite(item.id);
    final double emojiSize = compact ? 48 : 64;
    final double fontSize = compact ? 14 : 16;
    final double priceFontSize = compact ? 13 : 16;
    final double iconSize = compact ? 18 : 24;
    final EdgeInsets padding = compact ? const EdgeInsets.all(8) : const EdgeInsets.all(12);
    final double horizontalGap = compact ? 8 : 12;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/detail',
          arguments: item,
        ),
        child: Padding(
          padding: padding,
          child: Row(
            children: [
              Container(
                width: emojiSize,
                height: emojiSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.deepOrange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item.emoji, style: TextStyle(fontSize: emojiSize * 0.5)),
              ),
              SizedBox(width: horizontalGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: compact ? 12 : 16, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text('${item.rating}', style: TextStyle(fontSize: compact ? 11 : 13)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.category,
                            style: TextStyle(fontSize: compact ? 11 : 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(item.price),
                      style: TextStyle(
                        fontSize: priceFontSize,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (showActions) ...[
                if (compact)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Favorit',
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                          size: iconSize,
                        ),
                        onPressed: () => _toggleFavorite(item),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                      IconButton(
                        tooltip: 'Tambah ke keranjang',
                        icon: Icon(Icons.add_shopping_cart, color: Colors.deepOrange, size: iconSize),
                        onPressed: () => _addToCart(item),
                        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  )
                else ...[
                  IconButton(
                    tooltip: 'Favorit',
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
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final menus = _filteredMenu;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantin Bu Sari - Daftar Menu'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          // Tombol Riwayat
          IconButton(
            tooltip: 'Riwayat Pesanan',
            icon: const Icon(Icons.receipt_long),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
          // Tombol Favorit -> navigasi ke halaman favorit
          IconButton(
            tooltip: 'Menu favorit',
            icon: Badge(
              isLabelVisible: _cartService.favorites.isNotEmpty,
              label: Text('${_cartService.favorites.length}'),
              child: const Icon(Icons.favorite),
            ),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          // Tombol Keranjang
          IconButton(
            tooltip: 'Keranjang',
            icon: Badge(
              isLabelVisible: _cartService.itemCount > 0,
              label: Text('${_cartService.itemCount}'),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner sambutan
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.deepOrange, Colors.orangeAccent],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Text('👩‍🍳', style: TextStyle(fontSize: 40)),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selamat Datang di Kantin Bu Sari!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pilih menu favoritmu di bawah ini.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Kolom pencarian
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                filled: true,
                fillColor: scheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filter kategori
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                return ChoiceChip(
                  label: Text(cat),
                  selected: _selectedCategory == cat,
                  selectedColor: Colors.deepOrange.shade100,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // Rekomendasi untukmu
          if (_recommendedMenus.isNotEmpty && _query.isEmpty && _selectedCategory == 'Semua')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rate_rounded, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Rekomendasi untukmu',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${_recommendedMenus.length} menu',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 160,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _recommendedMenus.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final item = _recommendedMenus[i];
                      return SizedBox(
                        width: 160,
                        child: _buildMenuCard(item, showActions: true, compact: true),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),

          // Daftar menu
          Expanded(
            child: menus.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 56, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Menu tidak ditemukan'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: menus.length,
                    itemBuilder: (context, i) => _buildMenuCard(menus[i]),
                  ),
          ),
        ],
      ),
    );
  }
}