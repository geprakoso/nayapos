class PenjualanModel {
  final String id;
  final int amount;
  final String type;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;

  PenjualanModel({
    required this.id,
    required this.amount,
    required this.type,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });
}
