import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'kategori_dao.g.dart';

@DriftAccessor(tables: [Kategoris])
class KategoriDao extends DatabaseAccessor<AppDatabase> with _$KategoriDaoMixin {
  KategoriDao(AppDatabase db) : super(db);

  Future<List<Kategori>> getAllKategoris() => select(kategoris).get();

  Future<int> insertKategori(KategorisCompanion kategori) {
    return into(kategoris).insert(kategori);
  }

  Future<bool> updateKategori(Kategori kategori) {
    return update(kategoris).replace(kategori);
  }

  Future<int> deleteKategori(String id) {
    return (delete(kategoris)..where((k) => k.id.equals(id))).go();
  }
}
