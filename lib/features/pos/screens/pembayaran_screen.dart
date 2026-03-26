import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/member.dart';
import '../widgets/cart_panel.dart';
import 'member_picker_screen.dart';

/// Payment screen shown after checkout.
///
/// ## Layout
/// ```
/// ┌──────────────────────────────────────────┐
/// │  ← Pembayaran                           │
/// ├──────────────────────────────────────────┤
/// │  🛍 Total Tagihan         Rp XXX.XXX ˅  │
/// │     N item pesanan                       │
/// ├──────────────────────────────────────────┤
/// │  [Pelanggan] [Diskon] [Pajak]            │
/// ├──────────────────────────────────────────┤
/// │  [Tunai✓]  [Transfer]  [Lainnya]         │
/// ├──────────────────────────────────────────┤
/// │  JUMLAH DITERIMA                         │
/// │  Rp       200.000                        │
/// │  Kembalian          Rp 50.000            │
/// ├──────────────────────────────────────────┤
/// │  [Uang Pas] [Rp 50.000] [Rp 100.000]    │
/// ├──────────────────────────────────────────┤
/// │  [1] [2] [3] [⌫]                        │
/// │  [4] [5] [6]                             │
/// │  [7] [8] [9]   C                         │
/// │  [000] [0]   [  Bayar  ]                 │
/// └──────────────────────────────────────────┘
/// ```
class PembayaranScreen extends StatefulWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double total;
  final bool isDialog;

  const PembayaranScreen({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.isDialog = false,
  });

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  // ═══════════════════════════════════════════════════════════════════════════
  // STATE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Selected payment method index: 0 = Tunai, 1 = Transfer, 2 = Lainnya
  int _selectedMethod = 0;

  /// Raw digits entered by the user (no formatting).
  String _enteredAmount = '';

  /// Selected member (customer). Null until user picks one.
  Member? _selectedMember;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED
  // ═══════════════════════════════════════════════════════════════════════════

  int get _totalItems => widget.cart.fold(0, (s, i) => s + i.quantity);

  double get _amountReceived {
    if (_enteredAmount.isEmpty) return 0;
    return double.tryParse(_enteredAmount) ?? 0;
  }

  bool get _canPay => _amountReceived >= widget.total;

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════════════════

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: FractionallySizedBox(
            heightFactor: 0.85,
            child: CartPanel(
              cart: widget.cart,
              subtotal: widget.subtotal,
              tax: widget.tax,
              total: widget.total,
              isMobileSheet: true,
              readonly: true,
              onUpdateQuantity: (item, delta) {},
              onClearCart: () {},
              onCheckout: () {},
            ),
          ),
        );
      },
    );
  }

  void _openMemberPicker() async {
    final member = await Navigator.of(context).push<Member>(
      MaterialPageRoute(
        builder: (_) =>
            MemberPickerScreen(selectedMemberId: _selectedMember?.id),
      ),
    );
    if (member != null && mounted) {
      setState(() => _selectedMember = member);
    }
  }

  String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0);
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $result';
  }

  String _formatEnteredAmount() {
    if (_enteredAmount.isEmpty) return '0';
    return _enteredAmount.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // NUMPAD ACTIONS
  // ═══════════════════════════════════════════════════════════════════════════

  void _onDigit(String digit) {
    // Prevent absurdly long input
    if (_enteredAmount.length >= 12) return;
    setState(() => _enteredAmount += digit);
  }

  void _onBackspace() {
    if (_enteredAmount.isNotEmpty) {
      setState(
        () => _enteredAmount = _enteredAmount.substring(
          0,
          _enteredAmount.length - 1,
        ),
      );
    }
  }

  void _onClear() => setState(() => _enteredAmount = '');

  void _onQuickAmount(double amount) {
    setState(() => _enteredAmount = amount.toStringAsFixed(0));
  }

  void _onExactAmount() {
    setState(() => _enteredAmount = widget.total.toStringAsFixed(0));
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  // ═══════════════════════════════════════════════════════════════════════════
  // SHARED CONTENT BUILDERS
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Pembayaran',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          _TotalTagihanCard(
            total: widget.total,
            totalItems: _totalItems,
            formatCurrency: _formatCurrency,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: _showCartSheet,
          ),
          const SizedBox(height: 12),
          _ActionChipsRow(
            colorScheme: colorScheme,
            selectedMemberName: _selectedMember?.name,
            onPelangganTap: _openMemberPicker,
          ),
          const SizedBox(height: 12),
          _PaymentMethodTabs(
            selectedIndex: _selectedMethod,
            onSelected: (i) => setState(() => _selectedMethod = i),
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 12),
          _AmountReceivedCard(
            formattedAmount: _formatEnteredAmount(),
            amountReceived: _amountReceived,
            total: widget.total,
            formatCurrency: _formatCurrency,
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNumpad(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color blue,
  ) {
    return _NumpadSection(
      onDigit: _onDigit,
      onBackspace: _onBackspace,
      onClear: _onClear,
      canPay: _canPay,
      onPay: () {
        Navigator.of(context).pop(true);
      },
      colorScheme: colorScheme,
      textTheme: textTheme,
      blue: blue,
      quickAmountChips: _QuickAmountChips(
        total: widget.total,
        onExact: _onExactAmount,
        onQuickAmount: _onQuickAmount,
        formatCurrency: _formatCurrency,
        colorScheme: colorScheme,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const blue = Color(0xFF1D7AF3);

    // Desktop dialog: shrink-wrap to content, no extra whitespace
    if (widget.isDialog) {
      return Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(textTheme),
            _buildTopSection(colorScheme, textTheme),
            _buildNumpad(colorScheme, textTheme, blue),
          ],
        ),
      );
    }

    // Mobile full-page: fill the screen, numpad pinned to bottom
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _TotalTagihanCard(
                      total: widget.total,
                      totalItems: _totalItems,
                      formatCurrency: _formatCurrency,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: _showCartSheet,
                    ),
                    const SizedBox(height: 16),
                    _ActionChipsRow(
                      colorScheme: colorScheme,
                      selectedMemberName: _selectedMember?.name,
                      onPelangganTap: _openMemberPicker,
                    ),
                    const SizedBox(height: 16),
                    _PaymentMethodTabs(
                      selectedIndex: _selectedMethod,
                      onSelected: (i) => setState(() => _selectedMethod = i),
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 16),
                    _AmountReceivedCard(
                      formattedAmount: _formatEnteredAmount(),
                      amountReceived: _amountReceived,
                      total: widget.total,
                      formatCurrency: _formatCurrency,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 16),
                    _QuickAmountChips(
                      total: widget.total,
                      onExact: _onExactAmount,
                      onQuickAmount: _onQuickAmount,
                      formatCurrency: _formatCurrency,
                      colorScheme: colorScheme,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _NumpadSection(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onClear: _onClear,
                canPay: _canPay,
                onPay: () {
                  Navigator.of(context).pop(true);
                },
                colorScheme: colorScheme,
                textTheme: textTheme,
                blue: blue,
                expandVertically: true,
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

// ── Total Tagihan Card ──────────────────────────────────────────────────────

class _TotalTagihanCard extends StatelessWidget {
  final double total;
  final int totalItems;
  final String Function(double) formatCurrency;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback? onTap;

  const _TotalTagihanCard({
    required this.total,
    required this.totalItems,
    required this.formatCurrency,
    required this.colorScheme,
    required this.textTheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 22,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Tagihan',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$totalItems item pesanan',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D7AF3),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Action Chips Row ────────────────────────────────────────────────────────

class _ActionChipsRow extends StatelessWidget {
  final ColorScheme colorScheme;
  final String? selectedMemberName;
  final VoidCallback? onPelangganTap;

  const _ActionChipsRow({
    required this.colorScheme,
    this.selectedMemberName,
    this.onPelangganTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionChip(
          icon: selectedMemberName != null
              ? Icons.person
              : Icons.person_outline,
          label: selectedMemberName ?? 'Pelanggan',
          colorScheme: colorScheme,
          onTap: onPelangganTap,
          isSelected: selectedMemberName != null,
        ),
        const SizedBox(width: 8),
        _ActionChip(
          icon: Icons.percent,
          label: 'Diskon',
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 8),
        _ActionChip(
          icon: Icons.receipt_outlined,
          label: 'Pajak',
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;
  final bool isSelected;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.colorScheme,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF1D7AF3);
    return OutlinedButton.icon(
      onPressed: onTap ?? () {},
      icon: Icon(
        icon,
        size: 18,
        color: isSelected ? activeColor : colorScheme.onSurface,
      ),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: isSelected ? activeColor : colorScheme.onSurface,
        side: BorderSide(
          color: isSelected ? activeColor : colorScheme.outlineVariant,
          width: isSelected ? 1.5 : 1,
        ),
        backgroundColor: isSelected
            ? activeColor.withValues(alpha: 0.05)
            : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ── Payment Method Tabs ─────────────────────────────────────────────────────

class _PaymentMethodTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PaymentMethodTabs({
    required this.selectedIndex,
    required this.onSelected,
    required this.colorScheme,
    required this.textTheme,
  });

  static const _methods = [
    (icon: Icons.payments_outlined, label: 'Tunai'),
    (icon: Icons.account_balance_outlined, label: 'Transfer'),
    (icon: Icons.more_horiz, label: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_methods.length, (i) {
        final method = _methods[i];
        final isSelected = i == selectedIndex;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _methods.length - 1 ? 8 : 0),
            child: Material(
              color: isSelected
                  ? const Color(0xFF1D7AF3)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelected(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        method.icon,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        method.label,
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Amount Received Card ────────────────────────────────────────────────────

class _AmountReceivedCard extends StatelessWidget {
  final String formattedAmount;
  final double amountReceived;
  final double total;
  final String Function(double) formatCurrency;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _AmountReceivedCard({
    required this.formattedAmount,
    required this.amountReceived,
    required this.total,
    required this.formatCurrency,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'JUMLAH DITERIMA',
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                'Rp',
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formattedAmount,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            height: 1,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                amountReceived < total ? 'Kekurangan' : 'Kembalian',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                formatCurrency((amountReceived - total).abs()),
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick Amount Chips ──────────────────────────────────────────────────────

class _QuickAmountChips extends StatelessWidget {
  final double total;
  final VoidCallback onExact;
  final ValueChanged<double> onQuickAmount;
  final String Function(double) formatCurrency;
  final ColorScheme colorScheme;

  const _QuickAmountChips({
    required this.total,
    required this.onExact,
    required this.onQuickAmount,
    required this.formatCurrency,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Generate sensible quick amounts based on total
    final quickAmounts = _generateQuickAmounts(total);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickChip(
            label: 'Uang Pas',
            onTap: onExact,
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 8),
          ...quickAmounts.map(
            (amount) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _QuickChip(
                label: formatCurrency(amount),
                onTap: () => onQuickAmount(amount),
                colorScheme: colorScheme,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generates common rounded amounts above the total.
  List<double> _generateQuickAmounts(double total) {
    final amounts = <double>[];
    // Round up to nearest 10k, 50k, 100k
    final roundTo10k = ((total / 10000).ceil() * 10000).toDouble();
    final roundTo50k = ((total / 50000).ceil() * 50000).toDouble();
    final roundTo100k = ((total / 100000).ceil() * 100000).toDouble();

    if (roundTo10k > total) amounts.add(roundTo10k);
    if (roundTo50k > total && !amounts.contains(roundTo50k)) {
      amounts.add(roundTo50k);
    }
    if (roundTo100k > total && !amounts.contains(roundTo100k)) {
      amounts.add(roundTo100k);
    }
    // Add 200k if total > 100k
    if (total > 100000) amounts.add(200000);

    return amounts;
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _QuickChip({
    required this.label,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

// ── Numpad Section ──────────────────────────────────────────────────────────

class _NumpadSection extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool canPay;
  final VoidCallback onPay;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final Color blue;
  final Widget? quickAmountChips;
  final bool expandVertically;

  const _NumpadSection({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.canPay,
    required this.onPay,
    required this.colorScheme,
    required this.textTheme,
    required this.blue,
    this.quickAmountChips,
    this.expandVertically = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget row1 = Row(
      children: [
        _numKey('1'),
        _numKey('2'),
        _numKey('3'),
        _funcKey(Icons.backspace_outlined, onBackspace),
      ],
    );
    Widget row2 = Row(
      children: [_numKey('4'), _numKey('5'), _numKey('6'), _emptyOrClear()],
    );
    Widget row3 = Row(
      children: [
        _numKey('7'),
        _numKey('8'),
        _numKey('9'),
        _funcKeyText('C', onClear),
      ],
    );
    Widget row4 = Row(children: [_numKey('000'), _numKey('0'), _payButton()]);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: expandVertically
          ? Column(
              children: [
                if (quickAmountChips != null) ...[
                  quickAmountChips!,
                  const SizedBox(height: 10),
                ],
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: row1,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: row2,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: row3,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: row4,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (quickAmountChips != null) ...[
                  quickAmountChips!,
                  const SizedBox(height: 10),
                ],
                row1,
                const SizedBox(height: 6),
                row2,
                const SizedBox(height: 6),
                row3,
                const SizedBox(height: 6),
                row4,
              ],
            ),
    );
  }

  Widget _numKey(String digit) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: expandVertically ? double.infinity : 48,
          child: Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onDigit(digit),
              child: Center(
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _funcKey(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: expandVertically ? double.infinity : 48,
          child: Material(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Icon(icon, size: 24, color: colorScheme.onSurface),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _funcKeyText(String text, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: expandVertically ? double.infinity : 48,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: Center(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyOrClear() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(height: expandVertically ? double.infinity : 48),
      ),
    );
  }

  Widget _payButton() {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: expandVertically ? double.infinity : 48,
          child: FilledButton.icon(
            onPressed: canPay ? onPay : null,
            icon: const Icon(Icons.payments_outlined, size: 20),
            label: const Text(
              'Bayar',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: Colors.white,
              disabledBackgroundColor: blue.withValues(alpha: 0.4),
              disabledForegroundColor: Colors.white70,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
