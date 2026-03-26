import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'penjualan_dao.g.dart';

@DriftAccessor(tables: [Penjualans])
class PenjualanDao extends DatabaseAccessor<AppDatabase> with _$PenjualanDaoMixin {
  PenjualanDao(AppDatabase db) : super(db);

  // Example operations
  Future<List<Penjualan>> getAllPenjualans() => select(penjualans).get();
  
  Future<List<Penjualan>> getUnsyncedPenjualans() {
    return (select(penjualans)..where((p) => p.isSynced.equals(false))).get();
  }

  Future<int> insertPenjualan(PenjualansCompanion penjualan) {
    return into(penjualans).insert(penjualan);
  }

  Future<bool> updatePenjualan(Penjualan penjualan) {
    return update(penjualans).replace(penjualan);
  }

  Future<int> markAsSynced(String id) {
    return (update(penjualans)..where((p) => p.id.equals(id))).write(
      const PenjualansCompanion(isSynced: Value(true)),
    );
  }
}
