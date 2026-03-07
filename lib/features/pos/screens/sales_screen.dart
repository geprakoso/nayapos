import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/mobile_cart_button.dart';
import '../widgets/pos_drawer.dart';
import 'barcode_scanner_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen>
    with SingleTickerProviderStateMixin {
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
      imageUrl: 'assets/images/espresso.png',
    ),
    Product(
      id: '2',
      name: 'Latte',
      price: 25000,
      category: 'Coffee',
      imageUrl: 'assets/images/latte.png',
    ),
    Product(
      id: '3',
      name: 'Cappuccino',
      price: 25000,
      category: 'Coffee',
      imageUrl: 'assets/images/cappuccino.png',
    ),
    Product(
      id: '4',
      name: 'Croissant',
      price: 20000,
      category: 'Pastry',
      imageUrl: 'assets/images/croissant.png',
    ),
    Product(
      id: '5',
      name: 'Muffin',
      price: 18000,
      category: 'Pastry',
      imageUrl: 'assets/images/muffin.png',
    ),
    Product(
      id: '6',
      name: 'Orange Juice',
      price: 15000,
      category: 'Drinks',
      imageUrl: 'assets/images/orange_juice.png',
    ),
    Product(
      id: '7',
      name: 'Water',
      price: 5000,
      category: 'Drinks',
      imageUrl: 'assets/images/water.png',
    ),
    Product(
      id: '8',
      name: 'Sandwich',
      price: 35000,
      category: 'Food',
      imageUrl: 'assets/images/sandwich.png',
    ),
  ];

  final List<CartItem> _cart = [];
  String _selectedCategory = 'All';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<MobileCartButtonState> _cartButtonKey = GlobalKey<MobileCartButtonState>();

  late final AnimationController _searchAnimController;
  late final Animation<double> _searchExpandAnimation;

  @override
  void initState() {
    super.initState();
    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _searchExpandAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _searchAnimController.forward();
    // Focus right after the frame so the TextField is in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
        });
      }
    });
  }

  List<String> get _categories {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  List<Product> get _filteredProducts {
    final query = _searchController.text.toLowerCase();
    return _products.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch =
          query.isEmpty || p.name.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
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
    // Trigger pulse animation on the mobile cart button
    _cartButtonKey.currentState?.pulse();
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
      drawer: const PosDrawer(),
      appBar: AppBar(
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: AnimatedBuilder(
          animation: _searchExpandAnimation,
          builder: (context, child) {
            final t = _searchExpandAnimation.value;
            return Row(
              children: [
                // Hamburger menu — slides out & fades on expand
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor:
                      AlwaysStoppedAnimation(1.0 - t),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0 - t),
                    child: IconButton(
                      icon: const Icon(Icons.menu, size: 28),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    ),
                  ),
                ),
                SizedBox(width: 4 * (1.0 - t)),

                // Search bar — expanded, grows to full width
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: EdgeInsets.only(
                      left: t > 0 ? 4 : 16,
                      right: 16,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left side: back button (always present, sized by animation)
                        SizeTransition(
                          axis: Axis.horizontal,
                          sizeFactor: AlwaysStoppedAnimation(t),
                          child: FadeTransition(
                            opacity: AlwaysStoppedAnimation(t),
                            child: SizedBox(
                              height: 52,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: _closeSearch,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Center: text field or tappable hint
                        Expanded(
                          child: _isSearching
                              ? TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Cari Produk',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 8),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  onChanged: (value) => setState(() {}),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _openSearch,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Cari Produk',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        // Right side: always one widget to keep tree stable
                        if (_isSearching)
                          // Show clear button only when text is typed,
                          // otherwise an empty box to hold the slot
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 22,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(
                                        () => _searchController.clear());
                                  },
                                )
                              : const SizedBox.shrink()
                        else
                          IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 22,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () async {
                              final barcode = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BarcodeScannerScreen(),
                                ),
                              );
                              if (barcode != null && barcode is String) {
                                // Automatically place the scanned barcode into the search field
                                _openSearch();
                                setState(() {
                                  _searchController.text = barcode;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                SizedBox(width: 4 * (1.0 - t)),

                // Profile avatar — slides out & fades on expand
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor:
                      AlwaysStoppedAnimation(1.0 - t),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0 - t),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: MobileCartButton(
                    key: _cartButtonKey,
                    totalItems: _totalItems,
                    totalAmount: _total,
                    onTap: () => _showMobileCart(context),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  width: 56,
                  child: FloatingActionButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Add custom item clicked'),
                        ),
                      );
                    },
                    elevation: 2,
                    backgroundColor: const Color(0xFF1D7AF3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.add, size: 28),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
