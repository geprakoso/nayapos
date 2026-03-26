import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DiskonDialog extends StatefulWidget {
  final String initialType;
  final double initialValue;

  const DiskonDialog({
    super.key,
    this.initialType = 'nominal',
    this.initialValue = 0,
  });

  @override
  State<DiskonDialog> createState() => _DiskonDialogState();
}

class _DiskonDialogState extends State<DiskonDialog> {
  late String _type; // 'nominal' or 'persentase'
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    String initialText = '';
    if (widget.initialValue > 0) {
      if (_type == 'nominal') {
        initialText = widget.initialValue.toStringAsFixed(0);
      } else {
        initialText = widget.initialValue.toString();
        // remove trailing .0 if integer percentage
        if (initialText.endsWith('.0')) {
          initialText = initialText.substring(0, initialText.length - 2);
        }
      }
    }
    _controller = TextEditingController(text: initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    double value = 0;
    if (_controller.text.isNotEmpty) {
      value = double.tryParse(_controller.text.replaceAll('.', '')) ?? 0;
    }
    
    Navigator.of(context).pop({
      'type': _type,
      'value': value,
    });
  }

  Widget _buildToggleButton(
      String title, IconData icon, String type, ColorScheme colorScheme) {
    final isSelected = _type == type;
    final blue = const Color(0xFF1D7AF3);
    
    return Expanded(
      child: Material(
        color: isSelected ? blue : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              _type = type;
              _controller.clear();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final blue = const Color(0xFF1D7AF3);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.discount_outlined,
                color: colorScheme.onSurfaceVariant,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              'Tambahkan diskon',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Tambahkan diskon untuk transaksi ini?',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Toggle
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _buildToggleButton('Nominal', Icons.pin, 'nominal', colorScheme),
                  _buildToggleButton('Persentase', Icons.percent, 'persentase', colorScheme),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Input TextField
            TextField(
              controller: _controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              ],
              style: Theme.of(context).textTheme.titleMedium,
              decoration: InputDecoration(
                labelText: 'Jumlah Diskon',
                labelStyle: TextStyle(
                  color: blue,
                  fontWeight: FontWeight.w500,
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _type == 'nominal' ? 'Rp' : '%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: blue, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            const SizedBox(height: 32),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Batal',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _onSave,
                  child: Text(
                    'Simpan',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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
