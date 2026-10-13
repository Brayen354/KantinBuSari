/// Model data satu menu di Kantin Bu Sari.
class MenuItem {
  final int id;
  final String name;
  final String category; // Makanan / Minuman / Camilan
  final int price;
  final String description;
  final String emoji;
  final double rating;
  final String addonName;
  final int addonPrice;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    required this.emoji,
    required this.rating,
    required this.addonName,
    required this.addonPrice,
  });
}

/// Item di keranjang belanja (cart).
class CartItem {
  final MenuItem menu;
  final int quantity;
  final String portion; // Biasa / Jumbo
  final bool withAddon;
  final String note;

  const CartItem({
    required this.menu,
    required this.quantity,
    required this.portion,
    required this.withAddon,
    required this.note,
  });

  static const int jumboExtra = 5000;

  int get unitPrice =>
      menu.price +
      (portion == 'Jumbo' ? jumboExtra : 0) +
      (withAddon ? menu.addonPrice : 0);

  int get total => unitPrice * quantity;

  CartItem copyWith({
    int? quantity,
    String? portion,
    bool? withAddon,
    String? note,
  }) {
    return CartItem(
      menu: menu,
      quantity: quantity ?? this.quantity,
      portion: portion ?? this.portion,
      withAddon: withAddon ?? this.withAddon,
      note: note ?? this.note,
    );
  }
}

/// Riwayat satu pesanan yang sudah dibayar.
class OrderHistory {
  final String id;
  final DateTime timestamp;
  final String customerName;
  final String? tableNumber;
  final bool takeAway;
  final String paymentMethod;
  final List<CartItem> items;
  final int totalPrice;

  const OrderHistory({
    required this.id,
    required this.timestamp,
    required this.customerName,
    this.tableNumber,
    required this.takeAway,
    required this.paymentMethod,
    required this.items,
    required this.totalPrice,
  });

  String get formattedTime {
    final d = timestamp;
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }

  String get locationText => takeAway ? 'Take Away' : 'Meja $tableNumber';
}