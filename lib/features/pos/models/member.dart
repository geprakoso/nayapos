/// Represents a store member / loyalty customer.
class Member {
  final String id;
  final String name;
  final String phone;
  final int points;
  final String? avatarUrl;

  /// Optional status label, e.g. "Pembayaran tertunda".
  final String? statusLabel;

  const Member({
    required this.id,
    required this.name,
    required this.phone,
    required this.points,
    this.avatarUrl,
    this.statusLabel,
  });
}
