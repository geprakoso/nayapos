import 'package:drift/drift.dart';

@DataClassName('Penjualan')
class Penjualans extends Table {
  TextColumn get id => text()(); // UUID
  IntColumn get amount => integer()();
  TextColumn get type => text()(); // e.g. 'cash', 'qris', 'transfer'
  TextColumn get category => text().nullable()(); // optional category info
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Kategori')
class Kategoris extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get type => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Produk')
class Produks extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  IntColumn get price => integer()();
  IntColumn get stock => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MemberEntity')
class Members extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  IntColumn get points => integer().withDefault(const Constant(0))();
  TextColumn get avatarUrl => text().nullable()();
  TextColumn get statusLabel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
