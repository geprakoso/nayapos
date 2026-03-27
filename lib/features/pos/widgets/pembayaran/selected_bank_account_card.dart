import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/bank_account.dart';

class SelectedBankAccountCard extends StatelessWidget {
  final BankAccount account;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onChangeTap;

  const SelectedBankAccountCard({
    super.key,
    required this.account,
    required this.colorScheme,
    required this.textTheme,
    required this.onChangeTap,
  });

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1D7AF3);

    return InkWell(
      onTap: onChangeTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              account.bankName,
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () async {
                                final copiedText = '${account.bankName}\n${account.ownerName}\n${account.accountNumber}';
                                await Clipboard.setData(ClipboardData(text: copiedText));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Detail rekening berhasil disalin'),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('SALIN', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              style: TextButton.styleFrom(
                                foregroundColor: blueColor,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.accountNumber,
                          style: textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.3), height: 1),
              const SizedBox(height: 12),
              Text(
                'PEMILIK REKENING',
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                account.ownerName,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: account.imageAssetPath != null
            ? Image.asset(
                account.imageAssetPath!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.account_balance, color: Colors.grey),
              )
            : const Icon(Icons.account_balance, color: Colors.grey),
      ),
    );
  }
}
