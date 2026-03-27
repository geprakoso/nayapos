import 'package:flutter/material.dart';

class QuickAmountChips extends StatelessWidget {
  final double total;
  final VoidCallback onExact;
  final ValueChanged<double> onQuickAmount;
  final String Function(double) formatCurrency;
  final ColorScheme colorScheme;

  const QuickAmountChips({
    super.key,
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
