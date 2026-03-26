import 'package:flutter/material.dart';
import '../models/bank_account.dart';

class BankTransferPickerScreen extends StatefulWidget {
  final BankAccount? selectedAccount;

  const BankTransferPickerScreen({super.key, this.selectedAccount});

  @override
  State<BankTransferPickerScreen> createState() =>
      _BankTransferPickerScreenState();
}

class _BankTransferPickerScreenState extends State<BankTransferPickerScreen> {
  // Mock data representing local bank accounts
  final List<BankAccount> _allAccounts = [
    const BankAccount(
      id: '1',
      bankName: 'Bank Central Asia',
      accountNumber: '1234581234',
      ownerName: 'ALEXANDER GRAHAM',
      imageAssetPath: 'assets/images/banks/Swasta/bca.png',
    ),
    const BankAccount(
      id: '2',
      bankName: 'Bank Mandiri',
      accountNumber: '1234125678',
      ownerName: 'ALEXANDER GRAHAM',
      imageAssetPath: 'assets/images/banks/Himbara/mandiri.png',
    ),
    const BankAccount(
      id: '3',
      bankName: 'Bank Negara Indonesia',
      accountNumber: '12341234 9012',
      ownerName: 'ALEXANDER GRAHAM',
      imageAssetPath: 'assets/images/banks/Himbara/bni.png',
    ),
  ];

  late List<BankAccount> _filteredAccounts;
  final TextEditingController _searchController = TextEditingController();
  BankAccount? _selectedAccount;

  @override
  void initState() {
    super.initState();
    _filteredAccounts = _allAccounts;
    _selectedAccount = widget.selectedAccount;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAccounts = _allAccounts.where((acc) {
        return acc.bankName.toLowerCase().contains(query) ||
            acc.accountNumber.contains(query) ||
            acc.ownerName.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _onAccountTap(BankAccount account) async {
    setState(() {
      _selectedAccount = account;
    });

    // Provide a short delay so the user sees the 'selected' visual state
    await Future.delayed(const Duration(milliseconds: 250));
    if (mounted) {
      Navigator.of(context).pop(account);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari Rekening Bank',
                hintStyle:
                    const TextStyle(color: Color(0xFF9E9E9E), fontSize: 14),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                filled: true,
                fillColor: const Color(0xFFF0F2F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: const Icon(Icons.search,
                    color: Color(0xFF5A6270), size: 20),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredAccounts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final account = _filteredAccounts[index];
          final isSelected = _selectedAccount?.id == account.id;
          return _BankAccountCard(
            account: account,
            isSelected: isSelected,
            onTap: () => _onAccountTap(account),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement adding a new bank account
        },
        backgroundColor: const Color(0xFF1D7AF3),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccount account;
  final bool isSelected;
  final VoidCallback onTap;

  const _BankAccountCard({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const blueColor = Color(0xFF1D7AF3);
    final bgColor = isSelected ? blueColor : Colors.white;
    final borderColor = isSelected ? blueColor : const Color(0xFFE0E0E0);
    final mainTextColor = isSelected ? Colors.white : const Color(0xFF1A1C1E);
    final subTextColor =
        isSelected ? Colors.white.withValues(alpha: 0.8) : const Color(0xFF757575);
    final dividerColor = isSelected
        ? Colors.white.withValues(alpha: 0.2)
        : const Color(0xFFEEEEEE);
    final labelColor = isSelected
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF9E9E9E);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildLogo(isSelected),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: mainTextColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          account.accountNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: dividerColor, height: 1, thickness: 1),
              const SizedBox(height: 12),
              Text(
                'PEMILIK REKENING',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: labelColor,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                account.ownerName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: mainTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(bool isSelected) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFEBEBEB),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: account.imageAssetPath != null
                ? Image.asset(
                    account.imageAssetPath!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.account_balance,
                          color: Colors.grey);
                    },
                  )
                : const Icon(Icons.account_balance, color: Colors.grey),
          ),
        ),
        if (isSelected)
          Positioned(
            right: -6,
            bottom: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50), // Green checkmark
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
