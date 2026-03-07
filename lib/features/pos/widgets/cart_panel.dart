import 'package:flutter/material.dart';
import '../models/cart_item.dart';

class CartPanel extends StatelessWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double total;
  final Function(CartItem, int) onUpdateQuantity;
  final VoidCallback onClearCart;
  final VoidCallback onCheckout;
  final bool isMobileSheet;
  final VoidCallback? onClose;

  const CartPanel({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onUpdateQuantity,
    required this.onClearCart,
    required this.onCheckout,
    this.isMobileSheet = false,
    this.onClose,
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

    return Container(
      color: colorScheme.surface,
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button for mobile sheet
                if (isMobileSheet)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onClose,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Expanded(
                      child: Text(
                        'Current Order',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    // // Table Badge
                    // Container(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 12,
                    //     vertical: 6,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     color: colorScheme.surfaceContainerHighest,
                    //     borderRadius: BorderRadius.circular(8),
                    //     border: Border.all(
                    //       color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                    //     ),
                    //   ),
                    //   child: Text(
                    //     'Table 05',
                    //     style: textTheme.labelMedium?.copyWith(
                    //       fontWeight: FontWeight.w700,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                const SizedBox(height: 4),
                // Transaction row + Clear
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction #00124',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: cart.isEmpty ? null : onClearCart,
                      icon: Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: cart.isEmpty ? colorScheme.outline : Colors.red,
                      ),
                      label: Text(
                        'Clear',
                        style: TextStyle(
                          color: cart.isEmpty
                              ? colorScheme.outline
                              : Colors.red,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Cart Items ──────────────────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: colorScheme.outline.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Cart is empty',
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => Divider(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                      height: 24,
                    ),
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return _CartItemTile(
                        item: item,
                        formatCurrency: _formatCurrency,
                        onUpdateQuantity: onUpdateQuantity,
                        colorScheme: colorScheme,
                        textTheme: textTheme,
                      );
                    },
                  ),
          ),

          // ── Summary + Checkout ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtotal
                  _SummaryRow(
                    label: 'Subtotal',
                    value: _formatCurrency(subtotal),
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 8),
                  // Tax
                  _SummaryRow(
                    label: 'Tax (10%)',
                    value: _formatCurrency(tax),
                    textTheme: textTheme,
                  ),
                  const SizedBox(height: 8),
                  // Discount
                  _SummaryRow(
                    label: 'Discount',
                    value: '- Rp 0',
                    textTheme: textTheme,
                    valueColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  // Divider before total
                  Divider(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Total',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _formatCurrency(total),
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1D7AF3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Bottom buttons: Print + BAYAR
                  Row(
                    children: [
                      // Print icon button
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.print_outlined,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // BAYAR button
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: FilledButton.icon(
                            onPressed: cart.isEmpty ? null : onCheckout,
                            icon: const Icon(Icons.payment, size: 20),
                            label: const Text(
                              'BAYAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF1D7AF3),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// Individual cart item tile matching the reference design.
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final String Function(double) formatCurrency;
  final Function(CartItem, int) onUpdateQuantity;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _CartItemTile({
    required this.item,
    required this.formatCurrency,
    required this.onUpdateQuantity,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product image
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: item.product.imageUrl.startsWith('assets/')
              ? Image.asset(item.product.imageUrl, fit: BoxFit.cover)
              : Center(
                  child: Text(
                    item.product.imageUrl,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
        ),
        const SizedBox(width: 12),
        // Name, note, quantity controls
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + Unit Price row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      item.product.name,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatCurrency(item.product.price),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Note placeholder
              Text(
                '-',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 8),
              // Quantity controls + line total
              Row(
                children: [
                  // Minus
                  _QtyButton(
                    icon: Icons.remove,
                    onTap: () => onUpdateQuantity(item, -1),
                    colorScheme: colorScheme,
                  ),
                  // Quantity
                  Container(
                    constraints: const BoxConstraints(minWidth: 32),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.quantity}',
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Plus
                  _QtyButton(
                    icon: Icons.add,
                    onTap: () => onUpdateQuantity(item, 1),
                    colorScheme: colorScheme,
                    isPrimary: true,
                  ),
                  const Spacer(),
                  // Line total
                  Text(
                    formatCurrency(item.totalPrice),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D7AF3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small circular quantity button (-, +).
class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final bool isPrimary;

  const _QtyButton({
    required this.icon,
    required this.onTap,
    required this.colorScheme,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 28,
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
            size: 16,
            color: isPrimary ? Colors.white : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// A single summary row (key / value).
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final TextTheme textTheme;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.textTheme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
