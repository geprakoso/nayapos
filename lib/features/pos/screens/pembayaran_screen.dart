import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cart_item.dart';
import '../models/member.dart';
import '../models/bank_account.dart';
import '../widgets/cart_panel.dart';
import '../widgets/diskon_dialog.dart';
import '../widgets/tempo_dialog.dart';
import 'member_picker_screen.dart';
import 'bank_transfer_picker_screen.dart';
import 'camera_screen.dart';
import 'full_screen_image_screen.dart';
import '../models/lainnya_provider.dart';

// Import refactored widgets
import '../widgets/pembayaran/lainnya_picker_sheet.dart';
import '../widgets/pembayaran/qris_payment_content.dart';
import '../widgets/pembayaran/total_tagihan_card.dart';
import '../widgets/pembayaran/action_chips_row.dart';
import '../widgets/pembayaran/payment_method_tabs.dart';
import '../widgets/pembayaran/amount_received_card.dart';
import '../widgets/pembayaran/quick_amount_chips.dart';
import '../widgets/pembayaran/numpad_section.dart';
import '../widgets/pembayaran/transfer_selector_card.dart';
import '../widgets/pembayaran/selected_bank_account_card.dart';
import '../widgets/pembayaran/bukti_pembayaran_card.dart';

/// Payment screen shown after checkout.
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

  /// Selected bank account for Transfer method. Null until user picks one.
  BankAccount? _selectedBankAccount;

  /// Payment proof image for Transfer method.
  File? _buktiPembayaranImage;

  /// Selected other payment method provider.
  LainnyaProvider? _selectedLainnyaProvider;

  /// Tracks if the countdown timer for 'Lainnya' payment has expired.
  bool _isLainnyaTimerExpired = false;

  String _discountType = 'nominal';
  double _discountValue = 0;

  // ═══════════════════════════════════════════════════════════════════════════
  // COMPUTED
  // ═══════════════════════════════════════════════════════════════════════════

  int get _totalItems => widget.cart.fold(0, (s, i) => s + i.quantity);

  double get _amountReceived {
    if (_enteredAmount.isEmpty) return 0;
    return double.tryParse(_enteredAmount) ?? 0;
  }

  double get _calculatedDiscount {
    if (_discountValue == 0) return 0;
    if (_discountType == 'nominal') return _discountValue;
    return (widget.subtotal * _discountValue) / 100.0;
  }

  double get _calculatedTotal {
    final t = widget.subtotal + widget.tax - _calculatedDiscount;
    return t > 0 ? t : 0;
  }

  String get _diskonFormattedLabel {
    if (_discountValue == 0) return 'Diskon';
    if (_discountType == 'nominal') {
      return _formatCurrency(_discountValue);
    } else {
      String val = _discountValue.toString();
      if (val.endsWith('.0')) val = val.substring(0, val.length - 2);
      return '$val%';
    }
  }

  bool get _canPay {
    if (_selectedMethod != 0) return true;
    return _amountReceived >= _calculatedTotal;
  }

  bool get _canSubmit {
    if (_selectedMethod == 1) {
      return _selectedBankAccount != null && _buktiPembayaranImage != null;
    }
    if (_selectedMethod == 2) {
      return _selectedLainnyaProvider != null && !_isLainnyaTimerExpired;
    }
    return true;
  }

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
              diskon: _calculatedDiscount,
              total: _calculatedTotal,
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

  void _openDiskonDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DiskonDialog(
        initialType: _discountType,
        initialValue: _discountValue,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _discountType = result['type'];
        _discountValue = result['value'];
      });
    }
  }

  void _openBankPicker() async {
    final account = await Navigator.of(context).push<BankAccount>(
      MaterialPageRoute(
        builder: (_) =>
            BankTransferPickerScreen(selectedAccount: _selectedBankAccount),
      ),
    );
    if (account != null && mounted) {
      setState(() => _selectedBankAccount = account);
    }
  }

  Future<void> _pickBuktiPembayaran() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil Foto (Kamera)'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || result == null) return;

    XFile? image;
    if (result == 'camera') {
      image = await Navigator.push<XFile>(
        context,
        MaterialPageRoute(builder: (_) => const CameraScreen()),
      );
    } else {
      final ImagePicker picker = ImagePicker();
      image = await picker.pickImage(source: ImageSource.gallery);
    }

    if (image != null && mounted) {
      final imagePath = image.path;
      setState(() {
        _buktiPembayaranImage = File(imagePath);
      });
    }
  }

  void _openLainnyaSheet() async {
    final provider = await showModalBottomSheet<LainnyaProvider>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const LainnyaPickerSheet(providers: mockLainnyaProviders),
    );

    if (provider != null && mounted) {
      setState(() {
        _selectedMethod = 2;
        _selectedLainnyaProvider = provider;
        _isLainnyaTimerExpired = false;
      });
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
    setState(() => _enteredAmount = _calculatedTotal.toStringAsFixed(0));
  }

  void _handlePay() async {
    if (_canPay) {
      // For non-cash payments, we treat the amount received as the full bill.
      final confirmedAmount = _selectedMethod == 0 ? _amountReceived : _calculatedTotal;
      
      Navigator.of(context).pop({
        'status': 'success',
        'amountReceived': confirmedAmount,
        'paymentMethodIndex': _selectedMethod,
      });
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => TempoDialog(
        initialMember: _selectedMember,
        initialDueDate: DateTime.now().add(const Duration(days: 30)),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _selectedMember = result['member'];
      });

      Navigator.of(context).pop({
        'status': 'tempo',
        'member': _selectedMember,
        'dueDate': result['dueDate'],
        'amountReceived': _amountReceived,
        'discountType': _discountType,
        'discountValue': _discountValue,
      });
    }
  }

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
          TotalTagihanCard(
            total: _calculatedTotal,
            totalItems: _totalItems,
            formatCurrency: _formatCurrency,
            colorScheme: colorScheme,
            textTheme: textTheme,
            onTap: _showCartSheet,
          ),
          const SizedBox(height: 12),
          ActionChipsRow(
            colorScheme: colorScheme,
            selectedMemberName: _selectedMember?.name,
            hasDiskon: _discountValue > 0,
            diskonLabel: _diskonFormattedLabel,
            onPelangganTap: _openMemberPicker,
            onDiskonTap: _openDiskonDialog,
          ),
          const SizedBox(height: 12),
          PaymentMethodTabs(
            selectedIndex: _selectedMethod,
            selectedLainnyaId: _selectedLainnyaProvider?.id,
            onSelected: (i) {
              if (i == 2) {
                _openLainnyaSheet();
              } else {
                setState(() => _selectedMethod = i);
              }
            },
            colorScheme: colorScheme,
            textTheme: textTheme,
          ),
          const SizedBox(height: 16),
          _buildPaymentContent(colorScheme, textTheme),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildPaymentContent(ColorScheme colorScheme, TextTheme textTheme) {
    if (_selectedMethod == 1) {
      if (_selectedBankAccount != null) {
        return Column(
          children: [
            SelectedBankAccountCard(
              account: _selectedBankAccount!,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onChangeTap: _openBankPicker,
            ),
            const SizedBox(height: 16),
            BuktiPembayaranCard(
              imageFile: _buktiPembayaranImage,
              onTapPick: _pickBuktiPembayaran,
              onTapImage: () {
                if (_buktiPembayaranImage != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullScreenImageScreen(
                        imageFile: _buktiPembayaranImage!,
                        tag: 'bukti_pembayaran_hero',
                      ),
                    ),
                  );
                }
              },
              onClear: () => setState(() => _buktiPembayaranImage = null),
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),
          ],
        );
      }
      return TransferSelectorCard(
        colorScheme: colorScheme,
        textTheme: textTheme,
        onTap: _openBankPicker,
      );
    }

    if (_selectedMethod == 2) {
      if (_selectedLainnyaProvider != null) {
        return QrisPaymentContent(
          providerId: _selectedLainnyaProvider!.id,
          // TODO: Replace 'qrData' mock string below with actual data fetched from Payment Provider API.
          qrData: 'MOCK_${_selectedLainnyaProvider!.id.toUpperCase()}_${_calculatedTotal.toStringAsFixed(0)}',
          colorScheme: colorScheme,
          textTheme: textTheme,
          onTimeExpired: () {
            if (mounted) setState(() => _isLainnyaTimerExpired = true);
          },
        );
      }
      return Container(
        height: 120,
        alignment: Alignment.center,
        child: Text('Metode pembayaran lainnya', style: textTheme.bodyMedium),
      );
    }

    return AmountReceivedCard(
      formattedAmount: _formatEnteredAmount(),
      amountReceived: _amountReceived,
      total: _calculatedTotal,
      formatCurrency: _formatCurrency,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );
  }

  Widget _buildNumpad(
    ColorScheme colorScheme,
    TextTheme textTheme,
    Color blue,
  ) {
    return NumpadSection(
      onDigit: _onDigit,
      onBackspace: _onBackspace,
      onClear: _onClear,
      isAmountSufficient: _canPay,
      onPay: _handlePay,
      colorScheme: colorScheme,
      textTheme: textTheme,
      blue: blue,
      quickAmountChips: QuickAmountChips(
        total: _calculatedTotal,
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
            if (_selectedMethod == 0)
              _buildNumpad(colorScheme, textTheme, blue)
            else
              Padding(
                padding: const EdgeInsets.all(20),
                child: FilledButton.icon(
                  onPressed: _canSubmit ? _handlePay : null,
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(
                    _selectedMethod == 2 && _isLainnyaTimerExpired
                        ? 'Waktu Habis'
                        : (_selectedMethod == 2 ? 'Konfirmasi Pembayaran' : 'Lanjutkan Pembayaran'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colorScheme.outlineVariant,
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    }

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
                    TotalTagihanCard(
                      total: _calculatedTotal,
                      totalItems: _totalItems,
                      formatCurrency: _formatCurrency,
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                      onTap: _showCartSheet,
                    ),
                    const SizedBox(height: 16),
                    ActionChipsRow(
                      colorScheme: colorScheme,
                      selectedMemberName: _selectedMember?.name,
                      hasDiskon: _discountValue > 0,
                      diskonLabel: _diskonFormattedLabel,
                      onPelangganTap: _openMemberPicker,
                      onDiskonTap: _openDiskonDialog,
                    ),
                    const SizedBox(height: 16),
                    PaymentMethodTabs(
                      selectedIndex: _selectedMethod,
                      selectedLainnyaId: _selectedLainnyaProvider?.id,
                      onSelected: (i) {
                        if (i == 2) {
                          _openLainnyaSheet();
                        } else {
                          setState(() => _selectedMethod = i);
                        }
                      },
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildPaymentContent(colorScheme, textTheme),
                    ),
                  ],
                ),
              ),
            ),
            if (_selectedMethod == 0)
              Expanded(
                child: NumpadSection(
                  onDigit: _onDigit,
                  onBackspace: _onBackspace,
                  onClear: _onClear,
                  isAmountSufficient: _canPay,
                  onPay: _handlePay,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  blue: blue,
                  expandVertically: true,
                  quickAmountChips: QuickAmountChips(
                    total: _calculatedTotal,
                    onExact: _onExactAmount,
                    onQuickAmount: _onQuickAmount,
                    formatCurrency: _formatCurrency,
                    colorScheme: colorScheme,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                ),
                child: FilledButton.icon(
                  onPressed: _canSubmit ? _handlePay : null,
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(
                    _selectedMethod == 2 && _isLainnyaTimerExpired
                        ? 'Waktu Habis'
                        : (_selectedMethod == 2 ? 'Konfirmasi Pembayaran' : 'Lanjutkan Pembayaran'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: colorScheme.outlineVariant
                        .withValues(alpha: 0.5),
                    disabledForegroundColor: colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
