import 'package:flutter/material.dart';

class NumpadSection extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final bool isAmountSufficient;
  final VoidCallback onPay;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final Color blue;
  final Widget? quickAmountChips;
  final bool expandVertically;

  const NumpadSection({
    super.key,
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
    required this.isAmountSufficient,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
    final labelText = isAmountSufficient ? 'Bayar' : 'Lanjutkan';
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: blue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
    );

    return Expanded(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: SizedBox(
          height: expandVertically ? double.infinity : 48,
          child: isAmountSufficient
              ? FilledButton.icon(
                  onPressed: onPay,
                  icon: const Icon(Icons.payments_outlined, size: 20),
                  label: Text(
                    labelText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: buttonStyle,
                )
              : FilledButton(
                  onPressed: onPay,
                  style: buttonStyle,
                  child: Text(
                    labelText,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
