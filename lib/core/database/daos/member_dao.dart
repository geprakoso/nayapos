import 'package:drift/drift.dart';
import '../tables.dart';
import '../app_database.dart';

part 'member_dao.g.dart';

@DriftAccessor(tables: [Members])
class MemberDao extends DatabaseAccessor<AppDatabase> with _$MemberDaoMixin {
  MemberDao(AppDatabase db) : super(db);

  Future<List<MemberEntity>> getAllMembers() => select(members).get();

  Future<int> insertMember(MembersCompanion member) {
    return into(members).insert(member, mode: InsertMode.insertOrReplace);
  }

  Future<bool> updateMember(MemberEntity member) {
    return update(members).replace(member);
  }

  Future<int> deleteMember(String id) {
    return (delete(members)..where((m) => m.id.equals(id))).go();
  }
}
