import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DATA MODEL
// ═══════════════════════════════════════════════════════════════════════════════

/// Represents a single item in the POS navigation drawer.
///
/// Each menu item has:
/// - [icon]         — outline icon shown in the **unselected** state.
/// - [selectedIcon] — filled icon shown in the **selected** state.
/// - [label]        — the visible text label.
/// - [badge]        — optional numeric badge displayed to the right (e.g. "24").
class _DrawerMenuItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int? badge;

  const _DrawerMenuItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badge,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DRAWER WIDGET
// ═══════════════════════════════════════════════════════════════════════════════

/// The primary navigation drawer for the Naya POS application.
///
/// ## Layout structure
/// ```
/// ┌──────────────────────┐
/// │  "Naya POS"  (header)│  ← [_buildHeader]
/// ├──────────────────────┤
/// │  Penjualan      [24] │  ← index 0 (selected by default)
/// │  Produk / Jasa  [10] │  ← index 1
/// │  Kategori            │  ← index 2
/// │  Manajemen Stok      │  ← index 3
/// │  Promo               │  ← index 4
/// │  Karyawan            │  ← index 5
/// │  Member              │  ← index 6
/// │  Piutang             │  ← index 7
/// │  Pembelian           │  ← index 8
/// │  Kas                 │  ← index 9
/// │  Loyalti Program     │  ← index 10
/// │  ──────────────────  │  ← divider
/// │  Pengaturan          │  ← settings (separate, not indexed)
/// └──────────────────────┘
/// ```
///
/// ## Styling quick-reference
/// - **Selected tile background** : `colorScheme.primaryContainer`
/// - **Selected tile foreground** : `colorScheme.onPrimaryContainer`
/// - **Unselected foreground**    : `colorScheme.onSurfaceVariant`
/// - **Tile corner radius**       : 28 px (pill shape)
/// - **Badge corner radius**      : 12 px
///
/// ## How to change the selected index
/// The selected page is controlled by [_selectedIndex] (currently hardcoded
/// to `0`). To make it dynamic, convert this widget to a `StatefulWidget`
/// or accept the index via a constructor parameter.
class PosDrawer extends StatelessWidget {
  const PosDrawer({super.key});

  // ── Menu item definitions ─────────────────────────────────────────────────
  // Each entry maps to an index (0-based) used for selection highlighting.
  // To add a new menu item, append a _DrawerMenuItem here and the UI updates
  // automatically.

  /// Main navigation items shown above the divider.
  static const List<_DrawerMenuItem> _mainMenuItems = [
    // Index 0 — Sales / POS screen
    _DrawerMenuItem(
      icon: Icons.point_of_sale_outlined,
      selectedIcon: Icons.point_of_sale,
      label: 'Penjualan',
      badge: 24, // active transactions count
    ),
    // Index 1 — Product & service catalog
    _DrawerMenuItem(
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2,
      label: 'Produk / Jasa',
      badge: 10, // total product count
    ),
    // Index 2 — Product categories
    _DrawerMenuItem(
      icon: Icons.category_outlined,
      selectedIcon: Icons.category,
      label: 'Kategori',
    ),
    // Index 3 — Inventory / stock management
    _DrawerMenuItem(
      icon: Icons.warehouse_outlined,
      selectedIcon: Icons.warehouse,
      label: 'Manajemen Stok',
    ),
    // Index 4 — Promotions & discounts
    _DrawerMenuItem(
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
      label: 'Promo',
    ),
    // Index 5 — Employee management
    _DrawerMenuItem(
      icon: Icons.people_alt_outlined,
      selectedIcon: Icons.people_alt,
      label: 'Karyawan',
    ),
    // Index 6 — Customer / member directory
    _DrawerMenuItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Member',
    ),
    // Index 7 — Accounts receivable
    _DrawerMenuItem(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Piutang',
    ),
    // Index 8 — Purchasing / procurement
    _DrawerMenuItem(
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart,
      label: 'Pembelian',
    ),
    // Index 9 — Cash / finance management
    _DrawerMenuItem(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Kas',
    ),
    // Index 10 — Customer loyalty program
    _DrawerMenuItem(
      icon: Icons.card_giftcard_outlined,
      selectedIcon: Icons.card_giftcard,
      label: 'Loyalti Program',
    ),
  ];

  /// Settings item — shown below the divider, outside the main index range.
  static const _DrawerMenuItem _settingsItem = _DrawerMenuItem(
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
    label: 'Pengaturan',
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ── Selected index ────────────────────────────────────────────────────
    // TODO: Make this dynamic — either via constructor param or StatefulWidget.
    // Currently defaults to 0 (Penjualan / Sales screen).
    const int selectedIndex = 0;

    return Drawer(
      // Drawer background follows the current theme surface color.
      backgroundColor: colorScheme.surface,

      // Rounded right edge for a modern look.
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),

      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: App branding ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Text(
                'Naya POS',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),

            // ── Scrollable menu list ──────────────────────────────────
            // Uses ListView so the menu remains usable on small screens.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  // ── Main menu items (index 0 .. n) ────────────────
                  for (int i = 0; i < _mainMenuItems.length; i++)
                    _DrawerTile(
                      item: _mainMenuItems[i],
                      isSelected: i == selectedIndex,
                      onTap: () {
                        // TODO: Implement navigation per index.
                        // Example:
                        //   if (i == 1) Navigator.pushNamed(context, '/products');
                        Navigator.pop(context); // close drawer
                      },
                    ),

                  // ── Divider separating main items from settings ───
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(height: 1),
                  ),

                  // ── Settings tile ─────────────────────────────────
                  _DrawerTile(
                    item: _settingsItem,
                    isSelected: false,
                    onTap: () {
                      // TODO: Navigate to settings screen.
                      Navigator.pop(context);
                    },
                  ),

                  // Bottom spacing to avoid content hugging the edge.
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

/// A single row inside the POS drawer.
///
/// Handles its own selected / unselected styling and optional badge rendering.
///
/// ## Visual anatomy
/// ```
/// ┌─────────────────────────────────────────┐
/// │  [icon]  [label text]         [badge?]  │
/// └─────────────────────────────────────────┘
/// ```
///
/// ## Styling quick-reference (edit here to tweak appearance)
///
/// | Property              | Selected value              | Unselected value              | Line  |
/// |-----------------------|-----------------------------|-------------------------------|-------|
/// | Background color      | `primaryContainer`          | `transparent`                 | ~219  |
/// | Foreground color      | `onPrimaryContainer`        | `onSurfaceVariant`            | ~222  |
/// | Icon variant          | `item.selectedIcon` (filled)| `item.icon` (outlined)        | ~225  |
/// | Label font weight     | `FontWeight.w500`           | `FontWeight.w400`             | ~247  |
/// | Label font size       | inherits `bodyMedium`       | inherits `bodyMedium`         | ~245  |
/// | Icon size             | 22                          | 22                            | ~240  |
/// | Tile corner radius    | 28                          | 28                            | ~231  |
/// | Tile vertical padding | 14                          | 14                            | ~237  |
/// | Badge font weight     | `FontWeight.w700`           | `FontWeight.w700`             | ~273  |
/// | Badge corner radius   | 12                          | 12                            | ~268  |
///
class _DrawerTile extends StatelessWidget {
  final _DrawerMenuItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // ── Resolve selected vs unselected colors ────────────────────────────
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer   // highlighted pill background
        : Colors.transparent;            // no background when inactive
    final foregroundColor = isSelected
        ? colorScheme.onPrimaryContainer // text & icon color when selected
        : colorScheme.onSurfaceVariant;  // muted color when inactive
    final iconData = isSelected
        ? item.selectedIcon              // filled icon for selected
        : item.icon;                     // outlined icon for unselected

    return Padding(
      // Vertical gap between tiles.
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28), // pill-shaped tile
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            // Inner padding — controls tile height & horizontal breathing room.
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Icon ───────────────────────────────────────────
                Icon(iconData, size: 22, color: foregroundColor),

                const SizedBox(width: 14),

                // ── Label text ─────────────────────────────────────
                // Font size & weight are controlled here.
                // To change:
                //   • size  → add `fontSize: <value>` below
                //   • weight → adjust the FontWeight values below
                Expanded(
                  child: Text(
                    item.label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: foregroundColor,
                      // Font weight: selected vs unselected
                      fontWeight: isSelected
                          ? FontWeight.w500  // semi-bold for active item
                          : FontWeight.w400, // regular for inactive items
                      // Uncomment & adjust to override font size:
                      // fontSize: isSelected ? 15 : 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // ── Badge (optional) ──────────────────────────────
                // Only rendered when `item.badge` is non-null.
                if (item.badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      // Badge background adapts to selected state.
                      color: isSelected
                          ? colorScheme.onPrimaryContainer.withValues(
                              alpha: 0.12,
                            )
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${item.badge}',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
