import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:flutter_thermal_printer_plus/commands/print_builder.dart';
import 'package:flutter_thermal_printer_plus/flutter_thermal_printer_plus.dart';
import 'package:flutter_thermal_printer_plus/models/paper_size.dart';
import 'package:flutter_thermal_printer_plus/models/printer_info.dart';
import '../models/cart_item.dart';

class ThermalPrintService {
  /// We default to 58mm for typical POS receipts.
  static const PaperSize defaultPaperSize = PaperSize.mm58;

  /// Tries to find and print to the first available USB or Bluetooth printer.
  /// Note: This is a simplified auto-discovery print. In a real app,
  /// you'd want a settings screen to select and save the default printer.
  static Future<bool> printReceipt({
    required String storeName,
    required String storeAddress,
    required String transactionId,
    required String dateStr,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required String paymentMethod,
    double? amountReceived,
    double? change,
  }) async {
    try {
      if (kDebugMode) {
        print('Preparing thermal print...');
      }

      // In Linux Desktop development, we just simulate printing for now
      // as Bluetooth/USB scanning might not be fully configured natively.
      if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        await Future.delayed(const Duration(seconds: 1));
        if (kDebugMode) {
          print('Simulated print successful on Desktop environment.');
        }
        return true;
      }

      // Step 1: Scan for USB devices (most stable for POS)
      final usbDevices = await FlutterThermalPrinterPlus.getUsbDevices();
      PrinterInfo? targetPrinter;

      if (usbDevices.isNotEmpty) {
        targetPrinter = usbDevices.first;
      } else {
        // Fallback: Scan Bluetooth
        final btDevices = await FlutterThermalPrinterPlus.scanBluetoothDevices();
        if (btDevices.isNotEmpty) {
          targetPrinter = btDevices.first;
        }
      }

      if (targetPrinter == null) {
        if (kDebugMode) print('No thermal printers found.');
        return false;
      }

      // Step 2: Connect
      bool isConnected = false;
      if (targetPrinter.type == ConnectionType.usb) {
        isConnected = await FlutterThermalPrinterPlus.connectUsb(targetPrinter.address);
      } else if (targetPrinter.type == ConnectionType.bluetooth) {
        isConnected = await FlutterThermalPrinterPlus.connectBluetooth(targetPrinter.address);
      }

      if (!isConnected) {
        if (kDebugMode) print('Failed to connect to printer.');
        return false;
      }

      // Step 3: Build the receipt
      final builder = PrintBuilder(defaultPaperSize)
        // Header
        ..text(
          storeName,
          align: AlignPos.center,
          fontSize: FontSize.big,
          bold: true,
        )
        ..text(
          storeAddress,
          align: AlignPos.center,
        )
        ..feed(1)
        ..line(char: '=')
        
        // Transaction Info
        ..text('No: $transactionId')
        ..text('Waktu: $dateStr')
        ..line()
        
        // Items
        ..row(
          ['Item', 'Qty', 'Total'], 
          [35, 15, 50],
          aligns: [ColumnAlign.left, ColumnAlign.center, ColumnAlign.right],
        )
        ..line(char: '-');

      for (var item in items) {
        // Name on one line
        builder.text(item.product.name);
        // Price and total on next line
        final itemPrice = _formatCurrency(item.product.price);
        final itemTotal = _formatCurrency(item.totalPrice);
        builder.row(
          ['', '${item.quantity}x $itemPrice', itemTotal],
          [5, 45, 50],
          aligns: [ColumnAlign.left, ColumnAlign.left, ColumnAlign.right],
        );
      }

      builder
        ..line()
        // Totals
        ..row(['Subtotal', '', _formatCurrency(subtotal)], [30, 20, 50], aligns: [ColumnAlign.left, ColumnAlign.center, ColumnAlign.right])
        ..row(['Pajak', '', _formatCurrency(tax)], [30, 20, 50], aligns: [ColumnAlign.left, ColumnAlign.center, ColumnAlign.right])
        ..text(
          'TOTAL: ${_formatCurrency(total)}',
          align: AlignPos.right,
          bold: true,
          fontSize: FontSize.big,
        )
        ..line(char: '=')
        
        // Payment Info
        ..text('Metode: $paymentMethod');
      
      if (amountReceived != null) {
        builder.text('Bayar: ${_formatCurrency(amountReceived)}');
      }
      if (change != null) {
        builder.text('Kembali: ${_formatCurrency(change)}');
      }

      builder
        // Footer
        ..feed(1)
        ..text(
          'Terima kasih atas kunjungan Anda!',
          align: AlignPos.center,
          bold: true,
        )
        ..feed(3)
        ..cut();

      // Step 4: Print
      final success = await FlutterThermalPrinterPlus.print(builder);
      return success;
    } catch (e) {
      if (kDebugMode) {
        print('Error during thermal printing: $e');
      }
      return false;
    }
  }

  static String _formatCurrency(double amount) {
    String result = amount.toStringAsFixed(0);
    result = result.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return 'Rp $result';
  }
}
