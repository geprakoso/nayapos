import '../../models/member.dart';

abstract class MemberRepository {
  Future<List<Member>> getAllMembers();
  Future<void> saveMember(Member member);
  Future<void> updateMember(Member member);
  Future<void> deleteMember(String id);
}
