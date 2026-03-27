class LainnyaProvider {
  final String id;
  final String name;
  final String description;

  const LainnyaProvider({
    required this.id,
    required this.name,
    required this.description,
  });
}

// Dummy data for Lainnya providers
const List<LainnyaProvider> mockLainnyaProviders = [
  LainnyaProvider(
    id: 'qris',
    name: 'QRIS Payment',
    description: 'Bayar pakai aplikasi dompet digital apa saja yang mendukung QRIS',
  ),
];
