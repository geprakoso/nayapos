import 'package:flutter/material.dart';

class PaymentMethodTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final String? selectedLainnyaId;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const PaymentMethodTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.selectedLainnyaId,
    required this.colorScheme,
    required this.textTheme,
  });

  static const _methods = [
    (icon: Icons.payments_outlined, label: 'Tunai'),
    (icon: Icons.account_balance_outlined, label: 'Transfer'),
    (icon: Icons.expand_circle_down_outlined, label: 'Lainnya'),
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
                      if (i == 2 && selectedLainnyaId != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedLainnyaId!.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: isSelected
                                    ? Colors.white
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down,
                              size: 16,
                              color: isSelected
                                  ? Colors.white
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ],
                        )
                      else
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
