import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/member_dao.dart';
import '../../models/member.dart';
import '../../domain/repositories/member_repository.dart';

class MemberRepositoryImpl implements MemberRepository {
  final MemberDao _dao;

  MemberRepositoryImpl(this._dao);

  Member _mapToModel(MemberEntity entity) {
    return Member(
      id: entity.id,
      name: entity.name,
      phone: entity.phone ?? '',
      points: entity.points,
      avatarUrl: entity.avatarUrl,
      statusLabel: entity.statusLabel,
    );
  }

  MembersCompanion _mapToCompanion(Member model) {
    return MembersCompanion(
      id: Value(model.id),
      name: Value(model.name),
      phone: Value(model.phone),
      email: const Value(null),
      points: Value(model.points),
      avatarUrl: Value(model.avatarUrl),
      statusLabel: Value(model.statusLabel),
    );
  }

  @override
  Future<List<Member>> getAllMembers() async {
    final list = await _dao.getAllMembers();
    return list.map(_mapToModel).toList();
  }

  @override
  Future<void> saveMember(Member member) async {
    await _dao.insertMember(_mapToCompanion(member));
  }

  @override
  Future<void> updateMember(Member member) async {
    // Requires entity from model to replace
    final entity = MemberEntity(
      id: member.id,
      name: member.name,
      phone: member.phone,
      email: null,
      points: member.points,
      avatarUrl: member.avatarUrl,
      statusLabel: member.statusLabel,
    );
    await _dao.updateMember(entity);
  }

  @override
  Future<void> deleteMember(String id) async {
    await _dao.deleteMember(id);
  }
}
