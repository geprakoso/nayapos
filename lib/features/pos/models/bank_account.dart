class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String ownerName;
  final String? imageAssetPath;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.ownerName,
    this.imageAssetPath,
  });
}
