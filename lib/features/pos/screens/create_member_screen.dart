import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/member.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN
// ═══════════════════════════════════════════════════════════════════════════════

/// Screen for creating a new [Member].
///
/// Triggered by pressing the [+] FAB on [MemberPickerScreen].
/// Returns a freshly created [Member] via `Navigator.pop(context, member)`
/// when the user taps "Simpan".
///
/// ## Layout
/// ```
/// ┌───────────────────────────────────────┐
/// │  ←  Tambah Member        [Simpan]     │
/// ├───────────────────────────────────────┤
/// │          [ Add Photo ]                │
/// │                                       │
/// │  DETAIL MEMBER                        │
/// │  ┌─────────────────────────────────┐  │
/// │  │ 😊  Nama Member                │  │
/// │  └─────────────────────────────────┘  │
/// │  ┌─────────────────────────────────┐  │
/// │  │ 📞  No HP                      │  │
/// │  └─────────────────────────────────┘  │
/// │  ┌─────────────────────────────────┐  │
/// │  │ 🏠  Alamat                     │  │
/// │  └─────────────────────────────────┘  │
/// │                                       │
/// │  POIN & LOYALTI  ∧                   │
/// │  ┌─────────────────────────────────┐  │
/// │  │ 🏅  Poin                       │  │
/// │  └─────────────────────────────────┘  │
/// └───────────────────────────────────────┘
/// ```
class CreateMemberScreen extends StatefulWidget {
  const CreateMemberScreen({super.key});

  @override
  State<CreateMemberScreen> createState() => _CreateMemberScreenState();
}

class _CreateMemberScreenState extends State<CreateMemberScreen> {
  // ── Form ──────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _pointsController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _pointsFocus = FocusNode();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _loyaltyExpanded = true;
  String? _pickedImagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _pointsController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _addressFocus.dispose();
    _pointsFocus.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final member = Member(
      id: '#${DateTime.now().millisecondsSinceEpoch % 100000}',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      points: int.tryParse(_pointsController.text.trim()) ?? 0,
      avatarUrl: _pickedImagePath,
    );

    Navigator.of(context).pop(member);
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _pickedImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_pickedImagePath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _pickedImagePath = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _AppBar(
        colorScheme: colorScheme,
        textTheme: textTheme,
        onSave: _save,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // ── Photo picker ────────────────────────────────────────────────
            Center(
              child: _PhotoPicker(
                colorScheme: colorScheme,
                imagePath: _pickedImagePath,
                onTap: _showImageSourceDialog,
              ),
            ),

            const SizedBox(height: 32),

            // ── Detail Member section ────────────────────────────────────────
            _SectionHeader(
              label: 'DETAIL MEMBER',
              colorScheme: colorScheme,
              textTheme: textTheme,
            ),

            const SizedBox(height: 12),

            _MemberFormField(
              controller: _nameController,
              focusNode: _nameFocus,
              nextFocusNode: _phoneFocus,
              hintText: 'Nama Member',
              icon: Icons.person_outline_rounded,
              colorScheme: colorScheme,
              textInputAction: TextInputAction.next,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
            ),

            const SizedBox(height: 12),

            _MemberFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              nextFocusNode: _addressFocus,
              hintText: 'No HP',
              icon: Icons.phone_outlined,
              colorScheme: colorScheme,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),

            const SizedBox(height: 12),

            _MemberFormField(
              controller: _addressController,
              focusNode: _addressFocus,
              hintText: 'Alamat',
              icon: Icons.home_outlined,
              colorScheme: colorScheme,
              textInputAction: TextInputAction.done,
              maxLines: 1,
            ),

            const SizedBox(height: 28),

            // ── Poin & Loyalti section (collapsible) ──────────────────────────
            _CollapsibleSectionHeader(
              label: 'POIN & LOYALTI',
              expanded: _loyaltyExpanded,
              colorScheme: colorScheme,
              textTheme: textTheme,
              onToggle: () =>
                  setState(() => _loyaltyExpanded = !_loyaltyExpanded),
            ),

            AnimatedCrossFade(
              firstChild: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _MemberFormField(
                  controller: _pointsController,
                  focusNode: _pointsFocus,
                  hintText: 'Poin',
                  icon: Icons.workspace_premium_outlined,
                  colorScheme: colorScheme,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
              ),
              secondChild: const SizedBox.shrink(),
              crossFadeState: _loyaltyExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 220),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PRIVATE WIDGETS
// ═══════════════════════════════════════════════════════════════════════════════

// ── AppBar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onSave;

  const _AppBar({
    required this.colorScheme,
    required this.textTheme,
    required this.onSave,
  });

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 72,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 4,
      title: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 26),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),

          // Title
          Expanded(
            child: Text(
              'Tambah Member',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1D7AF3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo Picker ─────────────────────────────────────────────────────────────

class _PhotoPicker extends StatelessWidget {
  final ColorScheme colorScheme;
  final String? imagePath;
  final VoidCallback onTap;

  const _PhotoPicker({
    required this.colorScheme,
    this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.35),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          image: imagePath != null
              ? DecorationImage(
                  image: FileImage(File(imagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: imagePath == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 52,
                    color: colorScheme.primary.withValues(alpha: 0.55),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add Photo',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                ),
              ),
      ),
    );
  }
}

// ── Section Header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SectionHeader({
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: textTheme.labelMedium?.copyWith(
        color: colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ── Collapsible Section Header ────────────────────────────────────────────────

class _CollapsibleSectionHeader extends StatelessWidget {
  final String label;
  final bool expanded;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onToggle;

  const _CollapsibleSectionHeader({
    required this.label,
    required this.expanded,
    required this.colorScheme,
    required this.textTheme,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Row(
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 6),
          AnimatedRotation(
            turns: expanded ? 0.0 : -0.5,
            duration: const Duration(milliseconds: 220),
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 20,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Member Form Field ─────────────────────────────────────────────────────────

/// A single styled text field for the Create Member form.
///
/// Renders a rounded container with a leading [icon] and an inline [TextField].
class _MemberFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocusNode;
  final String hintText;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? Function(String?)? validator;

  const _MemberFormField({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.icon,
    required this.colorScheme,
    this.nextFocusNode,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        validator: validator,
        onFieldSubmitted: (_) {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          } else {
            focusNode.unfocus();
          }
        },
        style: TextStyle(
          fontSize: 15,
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontSize: 15,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 10),
            child: Icon(
              icon,
              size: 22,
              color: colorScheme.primary.withValues(alpha: 0.7),
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          errorStyle: TextStyle(
            fontSize: 11,
            color: colorScheme.error,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error, width: 1.2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colorScheme.error, width: 1.5),
          ),
        ),
      ),
    );
  }
}
