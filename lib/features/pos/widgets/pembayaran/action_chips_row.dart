import 'package:flutter/material.dart';

class ActionChipsRow extends StatelessWidget {
  final ColorScheme colorScheme;
  final String? selectedMemberName;
  final bool hasDiskon;
  final String diskonLabel;
  final VoidCallback? onPelangganTap;
  final VoidCallback? onDiskonTap;

  const ActionChipsRow({
    super.key,
    required this.colorScheme,
    this.selectedMemberName,
    this.hasDiskon = false,
    required this.diskonLabel,
    this.onPelangganTap,
    this.onDiskonTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
            label: diskonLabel,
            colorScheme: colorScheme,
            onTap: onDiskonTap,
            isSelected: hasDiskon,
          ),
          const SizedBox(width: 8),
          _ActionChip(
            icon: Icons.receipt_outlined,
            label: 'Pajak',
            colorScheme: colorScheme,
          ),
        ],
      ),
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
    const activeColor = Color(0xFF1D7AF3);
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
