import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

/// Displays products either as a grid (default) or as a list view.
///
/// The layout mode is controlled by [isListView]. When in list mode, each row
/// shows product image, name, price, stock status, and add-to-cart / quantity
/// controls matching the reference POS design.
class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final ValueChanged<Product> onAddToCart;

  /// When true, renders a vertical list instead of the default card grid.
  final bool isListView;

  /// Current cart items — needed in list view to show quantity controls
  /// for products already in the cart.
  final List<CartItem> cart;

  /// Callback to update quantity of a cart item by delta (+1 / -1).
  final Function(CartItem, int)? onUpdateQuantity;

  const ProductGrid({
    super.key,
    required this.products,
    required this.onAddToCart,
    this.isListView = false,
    this.cart = const [],
    this.onUpdateQuantity,
  });

  String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0);
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $result';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // Products only — category chips are now placed externally
    // (e.g. in the AppBar bottom of SalesScreen).
    return isListView
        ? _buildListView(colorScheme, textTheme)
        : _buildGridView(colorScheme, textTheme);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GRID VIEW (original layout)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildGridView(ColorScheme colorScheme, TextTheme textTheme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _ProductGridCard(
          product: product,
          formatCurrency: _formatCurrency,
          onTap: () => onAddToCart(product),
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LIST VIEW (new layout matching reference UI)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildListView(ColorScheme colorScheme, TextTheme textTheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ).copyWith(bottom: 100),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        // Find the matching cart item (if any) for this product.
        final cartItem = cart.cast<CartItem?>().firstWhere(
          (item) => item!.product.id == product.id,
          orElse: () => null,
        );

        return _ProductListTile(
          product: product,
          cartItem: cartItem,
          formatCurrency: _formatCurrency,
          onAddToCart: () => onAddToCart(product),
          onUpdateQuantity: onUpdateQuantity,
          colorScheme: colorScheme,
          textTheme: textTheme,
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Category chips row ──────────────────────────────────────────────────────

/// Horizontal scrollable row of [FilterChip]s for category filtering.
///
/// Made public so it can be placed in the AppBar or any other location.
/// When [isListView] is true and "All" is selected, the chip icon changes
/// to a list icon to hint at the current mode.
class CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final bool isListView;
  final ValueChanged<String> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.isListView,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: categories.map((category) {
          final isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilterChip(
              avatar: category == 'All'
                  ? Icon(
                      // Show list icon when in list mode, grid icon otherwise.
                      isListView && isSelected
                          ? Icons.view_list_rounded
                          : Icons.apps,
                      size: 18,
                      color: isSelected ? Colors.white : null,
                    )
                  : null,
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF1D7AF3),
              showCheckmark: false,
              onSelected: (_) => onCategorySelected(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Grid card (original design) ─────────────────────────────────────────────

class _ProductGridCard extends StatelessWidget {
  final Product product;
  final String Function(double) formatCurrency;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ProductGridCard({
    required this.product,
    required this.formatCurrency,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      color: colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Stack(
                    children: [
                      // Rounded Image
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: product.imageUrl.startsWith('assets/')
                              ? Image.asset(product.imageUrl, fit: BoxFit.cover)
                              : Container(
                                  color: colorScheme.surfaceContainerHighest,
                                  child: Center(
                                    child: Text(
                                      product.imageUrl,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Stock Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stock: ${product.stock}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color.fromARGB(255, 30, 41, 59),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatCurrency(product.price),
                      style: textTheme.bodyLarge?.copyWith(
                        color: const Color(0xFF1371EC),
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── List tile (new design matching reference UI) ────────────────────────────

/// A single product row in list view mode.
///
/// ## Visual anatomy
/// ```
/// ┌────────────────────────────────────────────────────────┐
/// │  [image]  [name]                            [+] btn   │
/// │           [price]                    or  [-] qty [+]   │
/// │           [stock label]                               │
/// └────────────────────────────────────────────────────────┘
/// ```
class _ProductListTile extends StatelessWidget {
  final Product product;
  final CartItem? cartItem;
  final String Function(double) formatCurrency;
  final VoidCallback onAddToCart;
  final Function(CartItem, int)? onUpdateQuantity;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ProductListTile({
    required this.product,
    required this.cartItem,
    required this.formatCurrency,
    required this.onAddToCart,
    required this.onUpdateQuantity,
    required this.colorScheme,
    required this.textTheme,
  });

  /// Returns the stock status label and its color.
  ({String label, Color color}) _stockStatus() {
    if (product.stock <= 0) {
      return (label: 'HABIS TERJUAL', color: Colors.red.shade400);
    } else if (product.stock <= 5) {
      return (label: 'STOK MENIPIS: ${product.stock}', color: Colors.orange);
    } else {
      return (
        label: 'TERSEDIA: ${product.stock}',
        color: const Color(0xFF1D7AF3),
      );
    }
  }

  bool get _isOutOfStock => product.stock <= 0;
  bool get _isInCart => cartItem != null && cartItem!.quantity > 0;

  @override
  Widget build(BuildContext context) {
    final status = _stockStatus();

    // Highlight row if product is in cart.
    final cardColor = _isInCart
        ? colorScheme.primaryContainer.withValues(alpha: 0.3)
        : colorScheme.surface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _isOutOfStock ? null : onAddToCart,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // ── Product image ──────────────────────────────────
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: product.imageUrl.startsWith('assets/')
                      ? Opacity(
                          opacity: _isOutOfStock ? 0.4 : 1.0,
                          child: Image.asset(
                            product.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            product.imageUrl,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                ),

                const SizedBox(width: 12),

                // ── Name, price, stock ─────────────────────────────
                Expanded(
                  child: Opacity(
                    opacity: _isOutOfStock ? 0.5 : 1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatCurrency(product.price),
                          style: textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF1D7AF3),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          status.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: status.color,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // ── Action buttons ─────────────────────────────────
                _buildAction(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the right-side action: quantity controls if in cart,
  /// a disabled icon if out of stock, or an add button otherwise.
  Widget _buildAction() {
    // Out of stock → disabled icon
    if (_isOutOfStock) {
      return Icon(
        Icons.block,
        color: colorScheme.outline.withValues(alpha: 0.4),
        size: 24,
      );
    }

    // Already in cart → quantity stepper
    if (_isInCart) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleButton(
            icon: Icons.remove,
            onTap: () => onUpdateQuantity?.call(cartItem!, -1),
            colorScheme: colorScheme,
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 32),
            alignment: Alignment.center,
            child: Text(
              '${cartItem!.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
          _CircleButton(
            icon: Icons.add,
            onTap: () => onUpdateQuantity?.call(cartItem!, 1),
            colorScheme: colorScheme,
            isPrimary: true,
          ),
        ],
      );
    }

    // Not in cart → add button
    return _CircleButton(
      icon: Icons.add,
      onTap: onAddToCart,
      colorScheme: colorScheme,
      isPrimary: true,
    );
  }
}

// ── Shared small circle button ──────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isPrimary;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: isPrimary
            ? const Color(0xFF1D7AF3)
            : colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(
            icon,
            size: 18,
            color: isPrimary ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
