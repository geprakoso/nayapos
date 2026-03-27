import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'transfer_selector_card.dart'; // Reuse DashedRectPainter

class BuktiPembayaranCard extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTapPick;
  final VoidCallback onClear;
  final VoidCallback? onTapImage;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const BuktiPembayaranCard({
    super.key,
    required this.imageFile,
    required this.onTapPick,
    required this.onClear,
    this.onTapImage,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1D7AF3);

    if (imageFile != null) {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Bukti Pembayaran',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    onPressed: onClear,
                    icon: const Icon(Icons.close, size: 20),
                    color: colorScheme.onSurfaceVariant,
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: onTapImage,
                borderRadius: BorderRadius.circular(12),
                child: Hero(
                  tag: 'bukti_pembayaran_hero',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      imageFile!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CustomPaint(
      painter: DashedRectPainter(color: blueColor.withValues(alpha: 0.6)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTapPick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: blueColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_outlined, size: 28, color: blueColor),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ambil Bukti Pembayaran',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
