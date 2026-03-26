// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penjualan_dao.dart';

// ignore_for_file: type=lint
mixin _$PenjualanDaoMixin on DatabaseAccessor<AppDatabase> {
  $PenjualansTable get penjualans => attachedDatabase.penjualans;
  PenjualanDaoManager get managers => PenjualanDaoManager(this);
}

class PenjualanDaoManager {
  final _$PenjualanDaoMixin _db;
  PenjualanDaoManager(this._db);
  $$PenjualansTableTableManager get penjualans =>
      $$PenjualansTableTableManager(_db.attachedDatabase, _db.penjualans);
}
