import '../models/penjualan_model.dart';

abstract class PenjualanRepository {
  Future<List<PenjualanModel>> getSemuaPenjualan();
  Future<List<PenjualanModel>> getPenjualanBelumSync();
  Future<void> simpanPenjualan(PenjualanModel penjualan);
  Future<void> tandaiSudahSync(String id);
}
