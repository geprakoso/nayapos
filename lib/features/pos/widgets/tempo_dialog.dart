import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/member.dart';
import '../screens/member_picker_screen.dart';

/// A dialog to confirm changing a transaction into a "Tempo" (Credit) transaction.
/// Shown when the payment received is less than the total.
class TempoDialog extends StatefulWidget {
  final Member? initialMember;
  final DateTime? initialDueDate;

  const TempoDialog({
    super.key,
    this.initialMember,
    this.initialDueDate,
  });

  @override
  State<TempoDialog> createState() => _TempoDialogState();
}

class _TempoDialogState extends State<TempoDialog> {
  late Member? _selectedMember;
  late DateTime _selectedDate;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _memberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedMember = widget.initialMember;
    _selectedDate = widget.initialDueDate ?? DateTime.now();
    _updateDateText();
    _updateMemberText();
  }

  void _updateDateText() {
    _dateController.text = DateFormat('dd/MM/y').format(_selectedDate);
  }

  void _updateMemberText() {
    _memberController.text = _selectedMember?.name ?? '';
  }

  Future<void> _pickDate() async {
    final pickedAt = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF1D7AF3),
                ),
          ),
          child: child!,
        );
      },
    );
    if (pickedAt != null && mounted) {
      setState(() {
        _selectedDate = pickedAt;
        _updateDateText();
      });
    }
  }

  Future<void> _pickMember() async {
    final member = await Navigator.of(context).push<Member>(
      MaterialPageRoute(
        builder: (_) =>
            MemberPickerScreen(selectedMemberId: _selectedMember?.id),
      ),
    );
    if (member != null && mounted) {
      setState(() {
        _selectedMember = member;
        _updateMemberText();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    const blue = Color(0xFF1D7AF3);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top Icon ───────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 20),

            // ── Title ──────────────────────────────────────────────────────
            Text(
              'Jadikan transaksi tempo?',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // ── Description ───────────────────────────────────────────────
            Text(
              'Karena pembayaran kurang, transaksi akan dialihkan ke transaksi tempo.',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // ── Jatuh Tempo Field ─────────────────────────────────────────
            _buildInputField(
              label: 'Jatuh tempo',
              controller: _dateController,
              onTap: _pickDate,
              readOnly: true,
              blue: blue,
              textTheme: textTheme,
            ),
            const SizedBox(height: 16),

            // ── Nama Pelanggan Field ──────────────────────────────────────
            _buildInputField(
              label: 'Nama Pelanggan',
              controller: _memberController,
              onTap: _pickMember,
              readOnly: true,
              blue: blue,
              textTheme: textTheme,
              suffixIcon: _selectedMember != null
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedMember = null;
                          _updateMemberText();
                        });
                      },
                      child: Icon(
                        Icons.cancel_outlined,
                        color: colorScheme.onSurfaceVariant,
                        size: 22,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 32),

            // ── Buttons ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop({
                      'member': _selectedMember,
                      'dueDate': _selectedDate,
                    });
                  },
                  child: const Text(
                    'Simpan',
                    style: TextStyle(
                      color: blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required bool readOnly,
    required Color blue,
    required TextTheme textTheme,
    Widget? suffixIcon,
  }) {
    return InkWell(
      onTap: onTap,
      child: IgnorePointer(
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          style: textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: blue,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: suffixIcon,
                  )
                : null,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: blue, width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(22),
              borderSide: BorderSide(color: blue, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}
