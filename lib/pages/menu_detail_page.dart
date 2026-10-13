import 'package:flutter/material.dart';

import '../data/menu_data.dart';
import '../models/menu_item.dart';
import '../services/cart_service.dart';
import '../utils/format.dart';

class MenuDetailPage extends StatefulWidget {
  const MenuDetailPage({super.key});

  @override
  State<MenuDetailPage> createState() => _MenuDetailPageState();
}

class _MenuDetailPageState extends State<MenuDetailPage> {
  final CartService _cartService = CartService.instance;

  String _portion = 'Biasa';
  bool _withAddon = false;
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  CartItem _buildCartItem(MenuItem menu) => CartItem(
        menu: menu,
        quantity: _quantity,
        portion: _portion,
        withAddon: _withAddon,
        note: _noteController.text.trim(),
      );

  void _addToCart(MenuItem menu) {
    final cartItem = _buildCartItem(menu);
    _cartService.addToCart(cartItem);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${menu.name} ditambahkan ke keranjang'),
          duration: const Duration(seconds: 1),
        ),
      );
    // Navigate to cart page
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    // Menu dikirim dari halaman daftar lewat arguments.
    final menu = (ModalRoute.of(context)?.settings.arguments as MenuItem?) ??
        menuData.first;
    final cartItem = _buildCartItem(menu);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kantin Bu Sari - Detail Menu'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header gambar menu
              Container(
                width: double.infinity,
                height: 180,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.deepOrange.shade100, Colors.orange.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Text(menu.emoji, style: const TextStyle(fontSize: 96)),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            menu.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          formatRupiah(menu.price),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                          label: Text('${menu.rating}'),
                        ),
                        Chip(
                          avatar: const Icon(Icons.category, size: 18),
                          label: Text(menu.category),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      menu.description,
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Divider(height: 32),

                    // Pilihan porsi
                    const Text(
                      'Pilih Porsi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: [
                          const ButtonSegment(
                            value: 'Biasa',
                            label: Text('Biasa'),
                          ),
                          ButtonSegment(
                            value: 'Jumbo',
                            label: Text(
                              'Jumbo (+${formatRupiah(CartItem.jumboExtra)})',
                            ),
                          ),
                        ],
                        selected: {_portion},
                        onSelectionChanged: (s) =>
                            setState(() => _portion = s.first),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tambahan
                    Card(
                      elevation: 0,
                      color: Colors.deepOrange.shade50,
                      child: SwitchListTile(
                        title: Text(menu.addonName),
                        subtitle: Text('+${formatRupiah(menu.addonPrice)}'),
                        value: _withAddon,
                        activeThumbColor: Colors.deepOrange,
                        onChanged: (v) => setState(() => _withAddon = v),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Jumlah pesanan
                    Row(
                      children: [
                        const Text(
                          'Jumlah',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton.filledTonal(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '$_quantity',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          onPressed: _quantity < 20
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Catatan
                    TextField(
                      controller: _noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Catatan untuk Bu Sari (opsional)',
                        hintText: 'Contoh: tidak pedas, es dipisah',
                        prefixIcon: const Icon(Icons.edit_note),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // Bilah total + tombol tambah ke keranjang
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subtotal', style: TextStyle(color: Colors.grey)),
                  Text(
                    formatRupiah(cartItem.total),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _addToCart(menu),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Tambah ke Keranjang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}