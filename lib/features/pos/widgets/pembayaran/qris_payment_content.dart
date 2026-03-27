import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

// Reuse DashedRectPainter for the border
import 'transfer_selector_card.dart';

class QrisPaymentContent extends StatefulWidget {
  final String providerId; // e.g., 'qris'
  final String qrData; // Mock data for now, e.g. 'MOCK_QRIS_STRING_123'
  final int timeLimitSeconds; // e.g., 300 (5 minutes)
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback
  onTimeExpired; // Callback to notify parent (PembayaranScreen)

  const QrisPaymentContent({
    super.key,
    required this.providerId,
    required this.qrData,
    this.timeLimitSeconds = 300,
    required this.colorScheme,
    required this.textTheme,
    required this.onTimeExpired,
  });

  @override
  State<QrisPaymentContent> createState() => _QrisPaymentContentState();
}

class _QrisPaymentContentState extends State<QrisPaymentContent> {
  late int _remainingSeconds;
  Timer? _timer;
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isDownloading = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.timeLimitSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        widget.onTimeExpired(); // Notify parent
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '$minutes menit ${seconds.toString().padLeft(2, '0')} dtk';
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    try {
      // Capture the QR code widget
      final Uint8List? imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        // Save to temporary directory
        final directory = await getTemporaryDirectory();
        final imagePath = await File(
          '${directory.path}/qr_payment_${DateTime.now().millisecondsSinceEpoch}.png',
        ).create();
        await imagePath.writeAsBytes(imageBytes);

        // Share the image file
        await Share.shareXFiles(
          [XFile(imagePath.path)],
          subject: 'QR Pembayaran',
          text: 'Silakan scan QR code ini untuk melakukan pembayaran.',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunduh QR: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1D7AF3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // QR Code Container
        Center(
          child: CustomPaint(
            painter: DashedRectPainter(color: blueColor.withOpacity(0.6)),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Screenshot(
                controller: _screenshotController,
                child: Container(
                  color:
                      widget.colorScheme.surface, // Background for screenshot
                  child: QrImageView(
                    data: widget.qrData,
                    version: QrVersions.auto,
                    size: 200.0,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    // TODO: Replace with real QRIS logo or provider logo if available
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Timer & Download Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    'Batas Bayar ',
                    style: widget.textTheme.bodyMedium?.copyWith(
                      color: Colors.red.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: Colors.red.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  _formattedTime,
                  style: widget.textTheme.bodyMedium?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
              onPressed: _isDownloading ? null : _handleDownload,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share, size: 18),
              label: const Text('Bagikan'),
              style: FilledButton.styleFrom(
                backgroundColor: blueColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Instructions
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              'Tata Cara Pembayaran',
              style: widget.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.colorScheme.onSurface,
              ),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 16),
            children: [
              _buildInstructionStep(
                '1',
                'Tekan Unduh QR atau screenshot layar ini untuk menyimpan QR Code-nya sebagai gambar.',
              ),
              _buildInstructionStep(
                '2',
                'Buka aplikasi dompet elektronik atau mobile banking yang memiliki fitur pembayaran ${widget.providerId.toUpperCase()}.',
              ),
              _buildInstructionStep(
                '3',
                'Pilih menu QRIS pada aplikasi tersebut dan masukkan gambar QR Code yang sebelumnya sudah tersimpan di device Anda.',
              ),
              _buildInstructionStep(
                '4',
                'Periksa kembali detail pembayaran Anda dan selesaikan pembayarannya.',
              ),
              _buildInstructionStep(
                '5',
                'Buka kembali aplikasi dan cek kembali status pembelian Anda.',
              ),
              _buildInstructionStep(
                '6',
                'Jika belum terkonfirmasi, Anda bisa menekan tombol Konfirmasi Pembayaran di bawah.',
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              'Syarat & Ketentuan',
              style: widget.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.colorScheme.onSurface,
              ),
            ),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.only(bottom: 16),
            children: [
              Text(
                'Pembayaran bersifat final dan tidak dapat dibatalkan melalui aplikasi.\nSilakan hubungi provider layanan untuk kendala operasional transfer.',
                style: widget.textTheme.bodySmall?.copyWith(
                  color: widget.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: widget.textTheme.bodySmall?.copyWith(
              color: widget.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: widget.textTheme.bodySmall?.copyWith(
                color: widget.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
