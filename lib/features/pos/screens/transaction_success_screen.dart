import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/cart_item.dart';
import '../services/thermal_print_service.dart';
import '../widgets/pembayaran/thermal_receipt_card.dart';

class TransactionSuccessScreen extends StatefulWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double total;
  final double amountReceived;
  final int paymentMethodIndex;
  final bool isDialog;

  const TransactionSuccessScreen({
    super.key,
    required this.cart,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.amountReceived,
    required this.paymentMethodIndex,
    this.isDialog = false,
  });

  @override
  State<TransactionSuccessScreen> createState() => _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  final String _storeName = 'NAYA POS SERVER';
  final String _storeAddress = 'Jl. Kebon Jeruk No.12, Jakarta';
  late String _transactionId;
  late String _dateStr;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    _transactionId = 'TRX-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    _dateStr = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
  }

  String _getPaymentMethodName() {
    switch (widget.paymentMethodIndex) {
      case 0:
        return 'Tunai';
      case 1:
        return 'Transfer Bank';
      case 2:
        return 'QRIS / Lainnya';
      default:
        return 'Lainnya';
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

  Future<void> _handlePrint() async {
    setState(() => _isPrinting = true);
    
    final success = await ThermalPrintService.printReceipt(
      storeName: _storeName,
      storeAddress: _storeAddress,
      transactionId: _transactionId,
      dateStr: _dateStr,
      items: widget.cart,
      subtotal: widget.subtotal,
      tax: widget.tax,
      total: widget.total,
      paymentMethod: _getPaymentMethodName(),
      amountReceived: widget.paymentMethodIndex == 0 ? widget.amountReceived : null,
      change: widget.paymentMethodIndex == 0 && widget.amountReceived > widget.total
          ? widget.amountReceived - widget.total
          : null,
    );

    if (mounted) {
      setState(() => _isPrinting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Berhasil mencetak struk' : 'Gagal mencetak struk/Tidak ada printer terhubung'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Widget _buildReceiptContent(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _storeName,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _storeAddress,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        const DashedDivider(),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('No: $_transactionId', style: textTheme.bodySmall),
            Text(_dateStr, style: textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 12),
        const DashedDivider(),
        const SizedBox(height: 12),
        // Items
        ...widget.cart.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: textTheme.bodyMedium),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity} x ${_formatCurrency(item.product.price)}',
                      style: textTheme.bodySmall,
                    ),
                    Text(
                      _formatCurrency(item.totalPrice),
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        const DashedDivider(),
        const SizedBox(height: 12),
        // Totals
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Subtotal'),
            Text(_formatCurrency(widget.subtotal)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pajak (10%)'),
            Text(_formatCurrency(widget.tax)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TOTAL',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              _formatCurrency(widget.total),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const DashedDivider(),
        const SizedBox(height: 12),
        // Payment Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Metode Pembayaran'),
            Text(_getPaymentMethodName()),
          ],
        ),
        if (widget.paymentMethodIndex == 0) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Bayar (Tunai)'),
              Text(_formatCurrency(widget.amountReceived)),
            ],
          ),
          if (widget.amountReceived > widget.total) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Kembali'),
                Text(_formatCurrency(widget.amountReceived - widget.total)),
              ],
            ),
          ]
        ],
        const SizedBox(height: 24),
        Text(
          'Terima kasih atas kunjungan Anda!',
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.isDialog) const SizedBox(height: 20),
        Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 64),
        const SizedBox(height: 16),
        Text(
          'Transaksi Berhasil!',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Flexible(
          child: SingleChildScrollView(
            child: Center(
              child: ThermalReceiptCard(
                width: widget.isDialog ? double.infinity : 360,
                child: _buildReceiptContent(textTheme),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              FilledButton.icon(
                onPressed: _isPrinting ? null : _handlePrint,
                icon: _isPrinting 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.print_outlined),
                label: Text(_isPrinting ? 'Mencetak...' : 'Cetak Struk', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // We close this screen. The parent (SalesScreen) 
                  // will already be clear and ready for the next tx.
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Transaksi Baru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );

    if (widget.isDialog) {
      return Material(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Status Pembayaran'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Force them to click 'Transaksi Baru'
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: content,
      ),
    );
  }
}
