import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../widgets/product_grid.dart';
import '../widgets/cart_panel.dart';
import '../widgets/mobile_cart_button.dart';
import '../widgets/pos_drawer.dart';
import 'barcode_scanner_screen.dart';
import 'pembayaran_screen.dart';

/// Main POS sales screen — the primary interface for creating orders.
///
/// ## Responsive Layout
/// - **Mobile** (width < 800): Full-width product grid + floating cart button
///   at the bottom. Tapping the cart button opens a bottom sheet ([CartPanel]).
/// - **Desktop** (width ≥ 800): Side-by-side layout with product grid (2/3)
///   and cart panel (1/3) separated by a vertical divider.
///
/// ## Navigation Flow
/// ```
/// SalesScreen
///   ├─ Mobile checkout  → full-page push → PembayaranScreen
///   └─ Desktop checkout → showDialog popup → PembayaranScreen
/// ```
///
/// ## Key Widgets
/// - [ProductGrid] — displays products as grid or list
/// - [CartPanel] — cart items + summary (side panel or bottom sheet)
/// - [MobileCartButton] — floating cart button (mobile only)
/// - [PosDrawer] — navigation drawer (hamburger menu)
/// - [PembayaranScreen] — payment/checkout screen
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

  /// Hardcoded product catalog.
  /// TODO: Replace with data from repository/API.
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'Espresso',
      price: 15000,
      category: 'Coffee',
      imageUrl: 'assets/images/espresso.png',
      stock: 24,
    ),
    Product(
      id: '2',
      name: 'Latte',
      price: 25000,
      category: 'Coffee',
      imageUrl: 'assets/images/latte.png',
      stock: 12,
    ),
    Product(
      id: '3',
      name: 'Cappuccino',
      price: 25000,
      category: 'Coffee',
      imageUrl: 'assets/images/cappuccino.png',
      stock: 3,
    ),
    Product(
      id: '4',
      name: 'Croissant',
      price: 20000,
      category: 'Pastry',
      imageUrl: 'assets/images/croissant.png',
      stock: 8,
    ),
    Product(
      id: '5',
      name: 'Muffin',
      price: 18000,
      category: 'Pastry',
      imageUrl: 'assets/images/muffin.png',
      stock: 0,
    ),
    Product(
      id: '6',
      name: 'Orange Juice',
      price: 15000,
      category: 'Drinks',
      imageUrl: 'assets/images/orange_juice.png',
      stock: 48,
    ),
    Product(
      id: '7',
      name: 'Water',
      price: 5000,
      category: 'Drinks',
      imageUrl: 'assets/images/water.png',
      stock: 100,
    ),
    Product(
      id: '8',
      name: 'Sandwich',
      price: 35000,
      category: 'Food',
      imageUrl: 'assets/images/sandwich.png',
      stock: 15,
    ),
  ];

  /// Current items in the shopping cart.
  /// Mutated by [_addToCart], [_updateQuantity], and [_clearCart].
  final List<CartItem> _cart = [];

  /// Currently selected category filter. 'All' shows every product.
  String _selectedCategory = 'All';

  /// Whether the product display is in list mode (true) or grid mode (false).
  /// Toggled by tapping the 'All' category chip when it's already selected.
  bool _isListView = false;

  /// Whether the search bar is expanded and the text field is active.
  bool _isSearching = false;

  /// Controller for the search text field. Used to filter [_filteredProducts].
  final TextEditingController _searchController = TextEditingController();

  /// Focus node for the search text field. Managed by [_openSearch]/[_closeSearch].
  final FocusNode _searchFocusNode = FocusNode();

  /// GlobalKey to access [MobileCartButtonState.pulse] for the add-to-cart animation.
  final GlobalKey<MobileCartButtonState> _cartButtonKey =
      GlobalKey<MobileCartButtonState>();

  /// Controls the search bar expand/collapse animation (0.0 = collapsed, 1.0 = expanded).
  /// Duration: 350ms forward, 300ms reverse.
  late final AnimationController _searchAnimController;

  /// Curved animation derived from [_searchAnimController].
  /// Used by the AppBar to animate hamburger menu, search bar, and profile avatar.
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

  /// Expands the search bar and focuses the text field.
  /// The focus is requested in a post-frame callback to ensure
  /// the TextField widget is already in the tree.
  void _openSearch() {
    setState(() => _isSearching = true);
    _searchAnimController.forward();
    // Focus right after the frame so the TextField is in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  /// Collapses the search bar, unfocuses the text field, and clears the query.
  /// The state is only updated after the reverse animation completes
  /// to avoid visual glitches.
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

  /// Unique category names extracted from [_products], with 'All' prepended.
  /// Used to populate the category chip bar.
  List<String> get _categories {
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.insert(0, 'All');
    return categories;
  }

  /// Products filtered by [_selectedCategory] and [_searchController] text.
  /// Returns all products when category is 'All' and search is empty.
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

  /// Adds a product to the cart. If the product already exists,
  /// increments its quantity. Also triggers the pulse animation
  /// on the mobile cart button via [_cartButtonKey].
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

  /// Updates the quantity of a cart item by [delta] (+1 or -1).
  /// Removes the item if quantity drops to 0 or below.
  ///
  /// [onStateChanged] is called after setState — used by the mobile
  /// bottom sheet to sync its local state via `setModalState`.
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

  /// Removes all items from the cart.
  /// [onStateChanged] callback is used by the bottom sheet for state sync.
  void _clearCart({VoidCallback? onStateChanged}) {
    setState(() {
      _cart.clear();
    });
    if (onStateChanged != null) onStateChanged();
  }

  /// Sum of all cart item prices (price × quantity). Recalculated on each access.
  double get _subtotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  /// Tax amount — fixed at 10% of subtotal.
  /// TODO: Make tax rate configurable (settings/backend).
  double get _tax => _subtotal * 0.10;

  /// Grand total = subtotal + tax. Passed to [PembayaranScreen].
  double get _total => _subtotal + _tax;

  /// Total number of individual items (sum of quantities) — shown on the mobile cart button badge.
  int get _totalItems => _cart.fold(0, (sum, item) => sum + item.quantity);

  /// Opens the cart as a draggable bottom sheet (mobile only).
  ///
  /// Uses [StatefulBuilder] so that cart mutations (quantity changes,
  /// clear) are reflected inside the sheet without closing and reopening.
  ///
  /// Checkout flow: pops the bottom sheet first, then pushes
  /// [PembayaranScreen] as a full-page route.
  void _showMobileCart(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PembayaranScreen(
                        cart: _cart,
                        subtotal: _subtotal,
                        tax: _tax,
                        total: _total,
                      ),
                    ),
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
                  sizeFactor: AlwaysStoppedAnimation(1.0 - t),
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
                    padding: EdgeInsets.only(left: t > 0 ? 4 : 16, right: 16),
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
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
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
                                    setState(() => _searchController.clear());
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
                                  builder: (context) =>
                                      const BarcodeScannerScreen(),
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
                  sizeFactor: AlwaysStoppedAnimation(1.0 - t),
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
        // ── Category chips below the search bar ────────────────────────
        bottom: _isSearching
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CategoryChips(
                      categories: _categories,
                      selectedCategory: _selectedCategory,
                      isListView: _isListView,
                      onCategorySelected: (category) {
                        setState(() {
                          if (category == 'All' && _selectedCategory == 'All') {
                            _isListView = !_isListView;
                          } else {
                            _selectedCategory = category;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
      ),
      // ── Body: responsive layout ──────────────────────────────────────
      // Breakpoint at 800px determines mobile vs desktop layout.
      // Mobile: product grid only (cart accessed via FAB bottom sheet).
      // Desktop: product grid (flex 2) | divider | cart panel (flex 1).
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;
          final productGrid = ProductGrid(
            products: _filteredProducts,
            isListView: _isListView,
            cart: _cart,
            onAddToCart: _addToCart,
            onUpdateQuantity: _updateQuantity,
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
                  // Desktop: opens PembayaranScreen as a centered dialog
                  // popup (max 480×700) instead of full-page navigation.
                  // The dialog is dismissible by tapping outside.
                  // Navigator.pop() inside PembayaranScreen closes the dialog.
                  onCheckout: () {
                    showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (_) => Dialog(
                        insetPadding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 24,
                        ),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IntrinsicHeight(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 480,
                            ),
                            child: PembayaranScreen(
                              cart: _cart,
                              subtotal: _subtotal,
                              tax: _tax,
                              total: _total,
                              isDialog: true,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      // ── Floating Action Button: mobile only ──────────────────────────
      // Shows a cart summary button + "add custom item" button.
      // Hidden on desktop (cart panel is always visible) and when cart is empty.
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
