import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

import 'tables.dart';
import 'daos/penjualan_dao.dart';
import 'daos/kategori_dao.dart';
import 'daos/member_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Penjualans, Kategoris, Produks, Members],
  daos: [PenjualanDao, KategoriDao, MemberDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pos_db.sqlite'));

    final cachebase = (await getTemporaryDirectory()).path;
    sqlite3.tempDirectory = cachebase;

    return NativeDatabase.createInBackground(file);
  });
}

// Global instance of the database to ensure we only open one connection.
final appDb = AppDatabase();
