// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategori_dao.dart';

// ignore_for_file: type=lint
mixin _$KategoriDaoMixin on DatabaseAccessor<AppDatabase> {
  $KategorisTable get kategoris => attachedDatabase.kategoris;
  KategoriDaoManager get managers => KategoriDaoManager(this);
}

class KategoriDaoManager {
  final _$KategoriDaoMixin _db;
  KategoriDaoManager(this._db);
  $$KategorisTableTableManager get kategoris =>
      $$KategorisTableTableManager(_db.attachedDatabase, _db.kategoris);
}
