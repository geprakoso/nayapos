import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/penjualan_dao.dart';
import '../../domain/models/penjualan_model.dart';
import '../../domain/repositories/penjualan_repository.dart';

class PenjualanRepositoryImpl implements PenjualanRepository {
  final PenjualanDao _dao;

  PenjualanRepositoryImpl(this._dao);

  // Helper method: Convert Drift DB Entity to Clean Architecture Model
  PenjualanModel _mapToModel(Penjualan entity) {
    return PenjualanModel(
      id: entity.id,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }

  // Helper method: Convert Clean Architecture Model to Drift Companion
  PenjualansCompanion _mapToCompanion(PenjualanModel model) {
    return PenjualansCompanion(
      id: Value(model.id),
      amount: Value(model.amount),
      type: Value(model.type),
      category: Value(model.category),
      createdAt: Value(model.createdAt),
      updatedAt: Value(model.updatedAt),
      isSynced: Value(model.isSynced),
    );
  }

  @override
  Future<List<PenjualanModel>> getSemuaPenjualan() async {
    final list = await _dao.getAllPenjualans();
    return list.map(_mapToModel).toList();
  }

  @override
  Future<List<PenjualanModel>> getPenjualanBelumSync() async {
    final list = await _dao.getUnsyncedPenjualans();
    return list.map(_mapToModel).toList();
  }

  @override
  Future<void> simpanPenjualan(PenjualanModel penjualan) async {
    await _dao.insertPenjualan(_mapToCompanion(penjualan));
  }

  @override
  Future<void> tandaiSudahSync(String id) async {
    await _dao.markAsSynced(id);
  }
}
