import 'package:flutter/material.dart';

import '../services/cart_service.dart';
import '../utils/format.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final CartService _cartService = CartService.instance;

  static const List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Tunai', 'icon': Icons.payments},
    {'label': 'QRIS', 'icon': Icons.qr_code_2},
    {'label': 'Transfer', 'icon': Icons.account_balance},
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _tableController = TextEditingController();

  bool _takeAway = false;
  String _payment = 'Tunai';
  bool _agree = false;

  @override
  void dispose() {
    _nameController.dispose();
    _tableController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Centang persetujuan pesanan terlebih dahulu')),
      );
      return;
    }

    final items = _cartService.items;
    final total = _cartService.totalPrice;
    final customerName = _nameController.text.trim();
    final tableNumber = _takeAway ? null : _tableController.text.trim();

    // Simpan ke riwayat sebelum clear cart
    _cartService.addToHistory(
      customerName: customerName,
      tableNumber: tableNumber,
      takeAway: _takeAway,
      paymentMethod: _payment,
      items: items,
      totalPrice: total,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 56),
        title: const Text('Pesanan Diterima!'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atas nama: $customerName'),
              Text(_takeAway
                  ? 'Dibawa pulang'
                  : 'Makan di tempat (Meja $tableNumber)'),
              Text('Pembayaran: $_payment'),
              const Divider(),
              ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}x ${item.menu.name} (${item.portion}${item.withAddon ? ' + ${item.menu.addonName}' : ''}) - ${formatRupiah(item.total)}',
                  style: const TextStyle(fontSize: 13),
                ),
              )),
              const Divider(),
              Text(
                'Total: ${formatRupiah(total)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              const Text('Tunjukkan struk ini ke kasir Bu Sari.'),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              _cartService.clear();
              Navigator.pop(ctx);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: const Text('Kembali ke Daftar Menu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _cartService.items;
    final total = _cartService.totalPrice;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pembayaran'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ringkasan pesanan
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Pesanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.deepOrange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(item.menu.emoji, style: const TextStyle(fontSize: 20)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.menu.name,
                                      style: const TextStyle(fontWeight: FontWeight.w500),
                                    ),
                                    Text(
                                      '${item.quantity}x Porsi ${item.portion}${item.withAddon ? ' + ${item.menu.addonName}' : ''}${item.note.isNotEmpty ? ' (${item.note})' : ''}',
                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatRupiah(item.total),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ],
                          ),
                        )),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Bayar', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              formatRupiah(total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Data pemesan
                const Text('Data Pemesan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama pemesan',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                ),
                const SizedBox(height: 12),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Bawa pulang (take away)'),
                  subtitle: Text(_takeAway ? 'Pesanan dibungkus' : 'Makan di tempat'),
                  value: _takeAway,
                  activeThumbColor: Colors.deepOrange,
                  onChanged: (v) => setState(() => _takeAway = v),
                ),

                if (!_takeAway)
                  TextFormField(
                    controller: _tableController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Nomor meja',
                      prefixIcon: const Icon(Icons.table_restaurant),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (v) {
                      if (_takeAway) return null;
                      if (v == null || v.trim().isEmpty) return 'Nomor meja wajib diisi';
                      if (int.tryParse(v.trim()) == null) return 'Masukkan angka saja';
                      return null;
                    },
                  ),
                const SizedBox(height: 20),

                // Metode pembayaran
                const Text('Metode Pembayaran', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _paymentMethods.map((m) {
                    final label = m['label'] as String;
                    return ChoiceChip(
                      avatar: Icon(m['icon'] as IconData, size: 18),
                      label: Text(label),
                      selected: _payment == label,
                      selectedColor: Colors.deepOrange.shade100,
                      onSelected: (_) => setState(() => _payment = label),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Saya sudah memeriksa pesanan dan data di atas'),
                  value: _agree,
                  activeColor: Colors.deepOrange,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                ),
                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submit,
                    icon: const Icon(Icons.check),
                    label: const Text('Konfirmasi & Bayar'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali ke Keranjang'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}