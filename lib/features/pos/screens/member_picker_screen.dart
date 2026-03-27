import 'dart:io';
import 'package:flutter/material.dart';
import '../models/member.dart';
import 'create_member_screen.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/daos/member_dao.dart';
import '../data/repositories/member_repository_impl.dart';
import '../domain/repositories/member_repository.dart';

/// Full-screen member list picker.
///
/// Header follows the same structure as [SalesScreen]:
/// back button + search bar + profile avatar, animated on search expand.
///
/// Returns the selected [Member] via `Navigator.pop(context, member)`.
///
/// ## Layout
/// ```
/// ┌──────────────────────────────────────────┐
/// │  ←  [ Cari Member          🔍 ]  (avt)  │
/// ├──────────────────────────────────────────┤
/// │  (avt) ID: #8821                         │
/// │        Sarah Widodo      1,240 PTS       │
/// │        0895 0000 69                      │
/// │  ─────────────────────────────────────   │
/// │  ...more members...                      │
/// ├──────────────────────────────────────────┤
/// │                                   [+]    │
/// └──────────────────────────────────────────┘
/// ```
class MemberPickerScreen extends StatefulWidget {
  final String? selectedMemberId;
  final bool isManagementMode; // Penentu Mode

  const MemberPickerScreen({
    super.key,
    this.selectedMemberId,
    this.isManagementMode = false, // Default: Mode Picker (Pilih Member)
  });

  @override
  State<MemberPickerScreen> createState() => _MemberPickerScreenState();
}

class _MemberPickerScreenState extends State<MemberPickerScreen>
    with SingleTickerProviderStateMixin {
  // ═════════════════════════════════════════════════════════════════════════════
  // DATA
  // ═════════════════════════════════════════════════════════════════════════════

  late final MemberRepository _repository;
  List<Member> _members = [];
  bool _isLoading = true;

  // ═════════════════════════════════════════════════════════════════════════════
  // SEARCH STATE
  // ═════════════════════════════════════════════════════════════════════════════

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late final AnimationController _searchAnimController;
  late final Animation<double> _searchExpandAnimation;

  @override
  void initState() {
    super.initState();
    _repository = MemberRepositoryImpl(MemberDao(appDb));
    _loadMembers();

    _searchAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
    );
    _searchExpandAnimation = CurvedAnimation(
      parent: _searchAnimController,
      curve: Curves.easeInOutCubicEmphasized,
      reverseCurve: Curves.easeInOutCubicEmphasized,
    );
  }

  Future<void> _loadMembers() async {
    final list = await _repository.getAllMembers();
    if (mounted) {
      if (list.isEmpty) {
        // Seed initial dummy data if DB is empty
        final initialMembers = [
          const Member(
            id: '#8821',
            name: 'Sarah Widodo',
            phone: '0895 0000 69',
            points: 1240,
          ),
          const Member(
            id: '#8850',
            name: 'Huda Rakabuming',
            phone: '0895 6969 69',
            points: 5240,
          ),
          const Member(
            id: '#8830',
            name: 'Galih Latadahiya',
            phone: '0895 2400 24',
            points: 2300,
          ),
          const Member(
            id: '#8851',
            name: 'Hasan Pangarep',
            phone: '0895 2400 24',
            points: 2300,
            statusLabel: 'Pembayaran tertunda',
          ),
          const Member(
            id: '#8810',
            name: 'Surya Binsar Panjahitan',
            phone: '0895 2400 24',
            points: 3200,
            statusLabel: 'Pembayaran tertunda',
          ),
        ];
        for (final m in initialMembers) {
          await _repository.saveMember(m);
        }
        setState(() {
          _members = initialMembers;
          _isLoading = false;
        });
      } else {
        // Reverse so the newest comes first or just assign
        setState(() {
          // Typically latest member at bottom, let's reverse to show latest added first if no specific order is in DB
          _members = list.reversed.toList();
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchAnimController.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() => _isSearching = true);
    _searchAnimController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocusNode.unfocus();
    _searchAnimController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchController.clear();
        });
      }
    });
  }

  List<Member> get _filteredMembers {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _members;
    return _members.where((m) {
      return m.name.toLowerCase().contains(query) ||
          m.phone.contains(query) ||
          m.id.contains(query);
    }).toList();
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // HELPERS
  // ═════════════════════════════════════════════════════════════════════════════

  String _formatPoints(int points) {
    return points.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // BUILD
  // ═════════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        toolbarHeight: 76,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: AnimatedBuilder(
          animation: _searchExpandAnimation,
          builder: (context, child) {
            final t = _searchExpandAnimation.value;
            return Row(
              children: [
                // ── Back button — slides out on search expand ──────
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: AlwaysStoppedAnimation(1.0 - t),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0 - t),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, size: 28),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                SizedBox(width: 4 * (1.0 - t)),

                // ── Search bar — full width ───────────────────────
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    padding: EdgeInsets.only(left: t > 0 ? 4 : 16, right: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Back button inside search bar (on expand)
                        SizeTransition(
                          axis: Axis.horizontal,
                          sizeFactor: AlwaysStoppedAnimation(t),
                          child: FadeTransition(
                            opacity: AlwaysStoppedAnimation(t),
                            child: SizedBox(
                              height: 52,
                              child: Center(
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: _closeSearch,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Text field or tappable hint
                        Expanded(
                          child: _isSearching
                              ? TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  autofocus: true,
                                  decoration: const InputDecoration(
                                    hintText: 'Cari Member',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  style: const TextStyle(fontSize: 16),
                                  onChanged: (value) => setState(() {}),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _openSearch,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Cari Member',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ),
                        ),

                        // Right icon: clear or search
                        if (_isSearching)
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.close,
                                    size: 22,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  onPressed: () {
                                    setState(() => _searchController.clear());
                                  },
                                )
                              : const SizedBox.shrink()
                        else
                          IconButton(
                            icon: Icon(
                              Icons.search,
                              size: 22,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: _openSearch,
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 4 * (1.0 - t)),

                // ── Profile avatar — slides out on search expand ──
                SizeTransition(
                  axis: Axis.horizontal,
                  sizeFactor: AlwaysStoppedAnimation(1.0 - t),
                  child: FadeTransition(
                    opacity: AlwaysStoppedAnimation(1.0 - t),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary,
                          width: 2.5,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: colorScheme.primaryContainer,
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredMembers.isEmpty
          ? _EmptyState(
              colorScheme: colorScheme,
              textTheme: textTheme,
              query: _searchController.text,
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _filteredMembers.length,
              separatorBuilder: (_, _) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                final member = _filteredMembers[index];
                final isSelected = member.id == widget.selectedMemberId;
                return _MemberCard(
                  member: member,
                  formatPoints: _formatPoints,
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                  isSelected: isSelected,
                  onTap: () async {
                    if (widget.isManagementMode) {
                      // MODE SCREEN (Management): Buka layar edit
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CreateMemberScreen(member: member),
                        ),
                      );
                      if (result is Member && mounted) {
                        // Update member
                        await _repository.saveMember(result);
                        _loadMembers(); // Refresh list
                      } else if (result == 'delete' && mounted) {
                        // Delete member
                        await _repository.deleteMember(member.id);
                        _loadMembers(); // Refresh list
                      }
                    } else {
                      // MODE PICKER: Kembalikan data member ke layar sebelumnya (Pembayaran)
                      Navigator.of(context).pop(member);
                    }
                  },
                );
              },
            ),

      // ── FAB: Add new member ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMember = await Navigator.of(context).push<Member>(
            MaterialPageRoute(builder: (_) => const CreateMemberScreen()),
          );
          // If a new member was created, add it to the list and save to DB.
          if (newMember != null && mounted) {
            await _repository.saveMember(newMember);
            setState(() {
              _members.insert(0, newMember);
            });
          }
        },
        backgroundColor: const Color(0xFF1D7AF3),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final String query;

  const _EmptyState({
    required this.colorScheme,
    required this.textTheme,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_search_outlined,
            size: 64,
            color: colorScheme.outline.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? 'Belum ada member' : 'Member tidak ditemukan',
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.outline),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Coba kata kunci lain',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Member Card ─────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  final Member member;
  final String Function(int) formatPoints;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _MemberCard({
    required this.member,
    required this.formatPoints,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeBlue = const Color(0xFF1D7AF3);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? activeBlue
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // ── Avatar ──────────────────────────────────────────
                _MemberAvatar(
                  name: member.name,
                  avatarUrl: member.avatarUrl,
                  colorScheme: colorScheme,
                  isSelected: isSelected,
                ),
                const SizedBox(width: 14),

                // ── Info column ─────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ID label
                      Text(
                        'ID: ${member.id}',
                        style: textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Name
                      Text(
                        member.name,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      // Phone
                      Text(
                        member.phone,
                        style: textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.8)
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // ── Points + status ─────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Points badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : (member.points >= 5000
                                  ? const Color(0xFF4CAF50)
                                  : activeBlue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${formatPoints(member.points)} PTS',
                        style: TextStyle(
                          color: isSelected ? activeBlue : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    // Status label (if any)
                    if (member.statusLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        member.statusLabel!,
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.redAccent,
                          fontStyle: FontStyle.italic,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Member Avatar ───────────────────────────────────────────────────────────

class _MemberAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final ColorScheme colorScheme;
  final bool isSelected;

  const _MemberAvatar({
    required this.name,
    required this.avatarUrl,
    required this.colorScheme,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    DecorationImage? image;
    if (avatarUrl != null) {
      if (avatarUrl!.startsWith('assets')) {
        image = DecorationImage(
          image: AssetImage(avatarUrl!),
          fit: BoxFit.cover,
        );
      } else {
        image = DecorationImage(
          image: FileImage(File(avatarUrl!)),
          fit: BoxFit.cover,
        );
      }
    }

    final avatarWidget = Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.4)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 2,
        ),
        image: image,
      ),
      child: avatarUrl == null
          ? CircleAvatar(
              radius: 23,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                _initials(name),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            )
          : null,
    );

    if (!isSelected) return avatarWidget;

    return Stack(
      children: [
        avatarWidget,
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }
}
