import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/mobile_cart_button.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // ===========================================================================
  // 1. DATA & STATE
  // ===========================================================================

  // Dummy data
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Espresso',
      price: 15000,
      category: 'Coffee',
      imageUrl: '☕',
    ),
    Product(
      id: '2',
      name: 'Latte',
      price: 25000,
      category: 'Coffee',
      imageUrl: '☕',
    ),
    Product(
      id: '3',
      name: 'Cappuccino',
      price: 25000,
      category: 'Coffee',
      imageUrl: '☕',
    ),
    Product(
      id: '4',
      name: 'Croissant',
      price: 20000,
      category: 'Pastry',
      imageUrl: '🥐',
    ),
    Product(
      id: '5',
      name: 'Muffin',
      price: 18000,
      category: 'Pastry',
      imageUrl: '🧁',
    ),
    Product(
      id: '6',
      name: 'Orange Juice',
      price: 15000,
      category: 'Drinks',
      imageUrl: '🥤',
    ),
    Product(
      id: '7',
      name: 'Water',
      price: 5000,
      category: 'Drinks',
      imageUrl: '💧',
    ),
    Product(
      id: '8',
      name: 'Sandwich',
      price: 35000,
      category: 'Food',
      imageUrl: '🥪',
    ),
  ];

  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';

  List<String> get _categories {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'All') return _products;
    return _products.where((p) => p.category == _selectedCategory).toList();
  }

  // ===========================================================================
  // 2. ACTIONS / MUTATIONS
  // ===========================================================================

  void _addToCart(Product product) {
    setState(() {
      final existingItemIndex = _cart.indexWhere(
        (item) => item.product.id == product.id,
      );
      if (existingItemIndex != -1) {
        _cart[existingItemIndex].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
  }

  void _updateQuantity(
    CartItem item,
    int delta, {
    VoidCallback? onStateChanged,
  }) {
    setState(() {
      item.quantity += delta;
      if (item.quantity <= 0) {
        _cart.remove(item);
      }
    });
    if (onStateChanged != null) onStateChanged();
  }

  void _clearCart({VoidCallback? onStateChanged}) {
    setState(() {
      _cart.clear();
    });
    if (onStateChanged != null) onStateChanged();
  }

  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);
  double get _tax => _subtotal * 0.10; // 10% tax
  double get _total => _subtotal + _tax;
  int get _totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return FractionallySizedBox(
              heightFactor: 0.9,
              child: CartPanel(
                cart: _cart,
                subtotal: _subtotal,
                tax: _tax,
                total: _total,
                isMobileSheet: true,
                onUpdateQuantity: (item, delta) => _updateQuantity(
                  item,
                  delta,
                  onStateChanged: () => setModalState(() {}),
                ),
                onClearCart: () =>
                    _clearCart(onStateChanged: () => setModalState(() {})),
                onCheckout: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Checkout not implemented')),
                  );
                },
                onClose: () => Navigator.of(context).pop(),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // 3. MAIN BUILD METHOD (Layout Composition)
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Sale'),
        centerTitle: false,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              'A',
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          final productGrid = ProductGrid(
            categories: _categories,
            selectedCategory: _selectedCategory,
            products: _filteredProducts,
            onCategorySelected: (category) =>
                setState(() => _selectedCategory = category),
            onAddToCart: _addToCart,
          );

          if (isMobile) {
            return productGrid;
          }

          return Row(
            children: [
              Expanded(flex: 2, child: productGrid),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(
                flex: 1,
                child: CartPanel(
                  cart: _cart,
                  subtotal: _subtotal,
                  tax: _tax,
                  total: _total,
                  onUpdateQuantity: _updateQuantity,
                  onClearCart: _clearCart,
                  onCheckout: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout not implemented')),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          if (!isMobile || _cart.isEmpty) return const SizedBox.shrink();

          return MobileCartButton(
            totalItems: _totalItems,
            totalAmount: _total,
            onTap: () => _showMobileCart(context),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
