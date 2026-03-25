import 'package:flutter/material.dart';
import '../models/cart_item.dart';

/// Cart panel used both as the desktop side panel and the mobile bottom sheet.
///
/// ## Layout (mobile sheet mode)
/// ```
/// ┌──────────────────────────────────────────┐
/// │            ── drag handle ──             │
/// │  Keranjang                  [Bersihkan]  │
/// ├──────────────────────────────────────────┤
/// │  [img] Name              Rp XX.XXX      │
/// │        note text                        │
/// │        [-] 1 [+]        ✏ Ubah Catatan  │
/// │  ────────────────────────────────────    │
/// │  ...more items...                       │
/// ├──────────────────────────────────────────┤
/// │  Subtotal               Rp XX.XXX       │
/// │  Pajak (10%)            Rp X.XXX        │
/// │  Diskon                 -Rp 0           │
/// │  ────────────────────────────────────    │
/// │  Total                  Rp XX.XXX       │
/// │  [ ====== Checkout 🧾 ======= ]        │
/// └──────────────────────────────────────────┘
/// ```
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
          // ── Drag handle (mobile sheet only) ──────────────────────────
          if (isMobileSheet) const _DragHandle(),

          // ── Header ──────────────────────────────────────────────────
          _CartHeader(
            cart: cart,
            isMobileSheet: isMobileSheet,
            onClearCart: onClearCart,
            textTheme: textTheme,
            colorScheme: colorScheme,
          ),

          const SizedBox(height: 4),

          // ── Cart Items ──────────────────────────────────────────────
          Expanded(
            child: cart.isEmpty
                ? _EmptyCartPlaceholder(
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: cart.length,
                    separatorBuilder: (_, _) => Divider(
                      color:
                          colorScheme.outlineVariant.withValues(alpha: 0.3),
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
          _CartSummary(
            subtotal: subtotal,
            tax: tax,
            total: total,
            cart: cart,
            isMobileSheet: isMobileSheet,
            formatCurrency: _formatCurrency,
            onCheckout: onCheckout,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Drag Handle ─────────────────────────────────────────────────────────────

/// A small pill-shaped drag indicator shown at the top of the bottom sheet.
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Center(
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

/// "Keranjang" title with a "Bersihkan" (clear) button.
class _CartHeader extends StatelessWidget {
  final List<CartItem> cart;
  final bool isMobileSheet;
  final VoidCallback onClearCart;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _CartHeader({
    required this.cart,
    required this.isMobileSheet,
    required this.onClearCart,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Text(
              'Keranjang',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          // Clear button
          TextButton.icon(
            onPressed: cart.isEmpty ? null : onClearCart,
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: cart.isEmpty
                  ? colorScheme.outline
                  : Colors.redAccent,
            ),
            label: Text(
              'Bersihkan',
              style: TextStyle(
                color: cart.isEmpty
                    ? colorScheme.outline
                    : Colors.redAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyCartPlaceholder extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _EmptyCartPlaceholder({
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            'Keranjang kosong',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan produk untuk memulai',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart Item Tile ──────────────────────────────────────────────────────────

/// Individual cart item tile matching the reference design.
///
/// ```
/// ┌──────────────────────────────────────────┐
/// │  [img]  Product Name        Rp XX.XXX   │
/// │         note / placeholder              │
/// │         [-] 1 [+]      ✏ Ubah Catatan   │
/// └──────────────────────────────────────────┘
/// ```
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Top row: image + name/note + price ──────────────────────
        Row(
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

            // Name + note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Note placeholder — shows a light hint when no note
                  Text(
                    item.note.isNotEmpty ? item.note : '-',
                    style: textTheme.bodySmall?.copyWith(
                      color: item.note.isNotEmpty
                          ? const Color(0xFF1D7AF3)
                          : colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
                      fontStyle: item.note.isNotEmpty
                          ? FontStyle.italic
                          : FontStyle.normal,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Unit price
            Text(
              formatCurrency(item.product.price),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // ── Bottom row: qty controls + note action ──────────────────
        Row(
          children: [
            // Quantity controls
            _QtyButton(
              icon: Icons.remove,
              onTap: () => onUpdateQuantity(item, -1),
              colorScheme: colorScheme,
            ),
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
            _QtyButton(
              icon: Icons.add,
              onTap: () => onUpdateQuantity(item, 1),
              colorScheme: colorScheme,
              isPrimary: true,
            ),

            const Spacer(),

            // Note action button
            TextButton.icon(
              onPressed: () {
                // TODO: Open note editor for this item
              },
              icon: Icon(
                Icons.edit_outlined,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              label: Text(
                item.note.isNotEmpty ? 'Ubah Catatan' : 'Tambah Catatan',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
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
    );
  }
}

// ── Quantity button ─────────────────────────────────────────────────────────

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
      width: 30,
      height: 30,
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

// ── Summary + Checkout ──────────────────────────────────────────────────────

/// Bottom section with subtotal, tax, discount, total, and checkout button.
class _CartSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final List<CartItem> cart;
  final bool isMobileSheet;
  final String Function(double) formatCurrency;
  final VoidCallback onCheckout;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _CartSummary({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.cart,
    required this.isMobileSheet,
    required this.formatCurrency,
    required this.onCheckout,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              value: formatCurrency(subtotal),
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            // Tax
            _SummaryRow(
              label: 'Pajak (10%)',
              value: formatCurrency(tax),
              textTheme: textTheme,
            ),
            const SizedBox(height: 8),
            // Discount
            _SummaryRow(
              label: 'Diskon',
              value: '-Rp 0',
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
                  formatCurrency(total),
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF1D7AF3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Action buttons ────────────────────────────────────
            // Mobile sheet: single full-width Checkout button
            // Desktop panel: Print + BAYAR side by side
            if (isMobileSheet)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: cart.isEmpty ? null : onCheckout,
                  icon: const Icon(Icons.receipt_long, size: 20),
                  label: const Text(
                    'Checkout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
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
              )
            else
              Row(
                children: [
                  // Print icon button
                  Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: colorScheme.outlineVariant),
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
    );
  }
}

// ── Summary row ─────────────────────────────────────────────────────────────

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
