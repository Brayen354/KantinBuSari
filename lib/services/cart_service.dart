import '../models/menu_item.dart';
import '../data/menu_data.dart';

/// Service untuk mengelola state keranjang belanja (cart), favorit, & riwayat pesanan.
class CartService {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartItem> _items = [];
  final Set<int> _favorites = {};
  final List<OrderHistory> _history = [];

  // --- Cart ---
  List<CartItem> get items => List.unmodifiable(_items);
  Set<int> get favorites => Set.unmodifiable(_favorites);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalPrice => _items.fold(0, (sum, item) => sum + item.total);

  bool isFavorite(int menuId) => _favorites.contains(menuId);

  void toggleFavorite(int menuId) {
    if (_favorites.contains(menuId)) {
      _favorites.remove(menuId);
    } else {
      _favorites.add(menuId);
    }
  }

  void addToCart(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) =>
          i.menu.id == item.menu.id &&
          i.portion == item.portion &&
          i.withAddon == item.withAddon &&
          i.note == item.note,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= _items.length) return;
    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
    }
  }

  void clear() {
    _items.clear();
  }

  // --- Favorites ---
  List<CartItem> getFavoritesList() {
    return menuData
        .where((menu) => _favorites.contains(menu.id))
        .map(
          (menu) => CartItem(
            menu: menu,
            quantity: 1,
            portion: 'Biasa',
            withAddon: false,
            note: '',
          ),
        )
        .toList();
  }

  // --- Order History ---
  List<OrderHistory> get history => List.unmodifiable(_history.reversed.toList());

  void addToHistory({
    required String customerName,
    required String? tableNumber,
    required bool takeAway,
    required String paymentMethod,
    required List<CartItem> items,
    required int totalPrice,
  }) {
    final order = OrderHistory(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      customerName: customerName,
      tableNumber: tableNumber,
      takeAway: takeAway,
      paymentMethod: paymentMethod,
      items: List.from(items),
      totalPrice: totalPrice,
    );
    _history.insert(0, order); // newest first
  }

  void clearHistory() {
    _history.clear();
  }

  // --- Statistics for Recommendations ---
  Map<int, int> get _orderCountByMenu {
    final map = <int, int>{};
    for (final order in _history) {
      for (final item in order.items) {
        map[item.menu.id] = (map[item.menu.id] ?? 0) + item.quantity;
      }
    }
    return map;
  }

  Map<int, int> get _favoriteCountByMenu {
    final map = <int, int>{};
    for (final favId in _favorites) {
      map[favId] = (map[favId] ?? 0) + 1;
    }
    return map;
  }

  /// Menu paling banyak dipesan (top N)
  List<MenuItem> getMostOrderedMenus({int limit = 3}) {
    final counts = _orderCountByMenu;
    final sorted = menuData.where((m) => counts.containsKey(m.id)).toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
    return sorted.take(limit).toList();
  }

  /// Menu paling banyak difavoritkan (top N)
  List<MenuItem> getMostFavoritedMenus({int limit = 3}) {
    final counts = _favoriteCountByMenu;
    final sorted = menuData.where((m) => counts.containsKey(m.id)).toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
    return sorted.take(limit).toList();
  }

  /// Rekomendasi gabungan: prioritas most ordered, fallback most favorited
  List<MenuItem> getRecommendedMenus({int limit = 4}) {
    final ordered = getMostOrderedMenus(limit: limit);
    if (ordered.length >= limit) return ordered;

    final favorited = getMostFavoritedMenus(limit: limit);
    final combined = <MenuItem>[];
    combined.addAll(ordered);
    for (final m in favorited) {
      if (!combined.any((x) => x.id == m.id)) combined.add(m);
      if (combined.length >= limit) break;
    }
    // Fallback: rating tinggi
    if (combined.length < limit) {
      final byRating = menuData.where((m) => !combined.any((x) => x.id == m.id)).toList()
        ..sort((a, b) => b.rating.compareTo(a.rating));
      combined.addAll(byRating.take(limit - combined.length));
    }
    return combined.take(limit).toList();
  }
}