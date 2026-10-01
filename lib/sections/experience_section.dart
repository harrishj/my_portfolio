import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/providers/app_providers.dart';
import 'package:portfolio/models/experience_item.dart';

class ExperienceSection extends ConsumerStatefulWidget {
  const ExperienceSection({super.key});

  @override
  ConsumerState<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends ConsumerState<ExperienceSection> {
  int _activeTab = 0; // 0: Experience (work), 1: Education

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;
    final isAdmin = ref.watch(isAdminProvider);

    final contentAsync = ref.watch(contentProvider('experience'));
    final data = contentAsync.value ?? {};

    final sectionTitle = data['title'] ?? 'TRACK RECORD & INDUSTRY JOURNEY';
    final sectionSubtitle = data['subtitle'] ??
        'Years of architectural rigor, full-stack shipping, and high-performance engineering.';
    final leftLabel = data['leftLabel'] ?? '03 / EXPERIENCE';
    final leftEyebrow = data['leftEyebrow'] ?? 'CHRONOLOGY & ROLES';
    final leftDesc = data['leftDesc'] ??
        'Timeline rows with period, role, organization, and architectural accomplishments.';
    final tabWorkLabel = data['tabWorkLabel'] ?? 'PRODUCTION EXPERIENCE';
    final tabEduLabel = data['tabEduLabel'] ?? 'EDUCATION & CREDENTIALS';

    void updateDoc(String key, dynamic val) {
      ref.read(dbServiceProvider).updateContent('experience', {key: val});
    }

    // Extract all items or fallback to legacy/default items
    final allItems = _extractExperienceItems(data);

    // Filter items for current active tab
    final currentTabType = _activeTab == 0 ? 'work' : 'education';
    final filteredItems = allItems.where((it) {
      if (it.type != currentTabType) return false;
      // If not admin, only show active entries
      if (!isAdmin && !it.isActive) return false;
      return true;
    }).toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 56 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 48),

              ScrollReveal(
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftStickyLabel(leftLabel, leftEyebrow, leftDesc, updateDoc, isAdmin),
                          const SizedBox(height: 32),
                          _buildContent(
                            sectionTitle: sectionTitle,
                            sectionSubtitle: sectionSubtitle,
                            tabWorkLabel: tabWorkLabel,
                            tabEduLabel: tabEduLabel,
                            allItems: allItems,
                            filteredItems: filteredItems,
                            updateDoc: updateDoc,
                            isAdmin: isAdmin,
                            isMobile: isMobile,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Sticky Studio Column
                          SizedBox(
                            width: 260,
                            child: _buildLeftStickyLabel(
                              leftLabel,
                              leftEyebrow,
                              leftDesc,
                              updateDoc,
                              isAdmin,
                            ),
                          ),
                          const SizedBox(width: 48),
                          // Vertical Hairline Separator
                          Container(
                            width: 1,
                            height: 650,
                            color: AppColors.hairline,
                          ),
                          const SizedBox(width: 48),
                          // Right Content Column
                          Expanded(
                            child: _buildContent(
                              sectionTitle: sectionTitle,
                              sectionSubtitle: sectionSubtitle,
                              tabWorkLabel: tabWorkLabel,
                              tabEduLabel: tabEduLabel,
                              allItems: allItems,
                              filteredItems: filteredItems,
                              updateDoc: updateDoc,
                              isAdmin: isAdmin,
                              isMobile: isMobile,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftStickyLabel(
    String leftLabel,
    String leftEyebrow,
    String leftDesc,
    Function(String, dynamic) updateDoc,
    bool isAdmin,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              color: AppColors.amber,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: EditableTextWidget(
                text: leftLabel,
                onSave: (val) => updateDoc('leftLabel', val),
                style: GoogleFonts.unbounded(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: AppColors.amber,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        EditableTextWidget(
          text: leftEyebrow,
          onSave: (val) => updateDoc('leftEyebrow', val),
          style: GoogleFonts.interTight(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.6,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 24),
        EditableTextWidget(
          text: leftDesc,
          onSave: (val) => updateDoc('leftDesc', val),
          style: GoogleFonts.interTight(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildContent({
    required String sectionTitle,
    required String sectionSubtitle,
    required String tabWorkLabel,
    required String tabEduLabel,
    required List<ExperienceItem> allItems,
    required List<ExperienceItem> filteredItems,
    required Function(String, dynamic) updateDoc,
    required bool isAdmin,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: sectionTitle,
          onSave: (val) => updateDoc('title', val),
          style: GoogleFonts.unbounded(
            fontSize: isMobile ? 24 : 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        EditableTextWidget(
          text: sectionSubtitle,
          onSave: (val) => updateDoc('subtitle', val),
          style: GoogleFonts.interTight(
            fontSize: isMobile ? 14 : 17,
            fontWeight: FontWeight.w500,
            color: AppColors.amber,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Tab Row + Admin Add Button
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _buildTabPill(tabWorkLabel, 0, (v) => updateDoc('tabWorkLabel', v), isAdmin),
            _buildTabPill(tabEduLabel, 1, (v) => updateDoc('tabEduLabel', v), isAdmin),
            if (isAdmin)
              InkWell(
                onTap: () => _openCreateDialog(allItems),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    border: Border.all(color: AppColors.amber, width: 1.2),
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 14, color: AppColors.amber),
                      const SizedBox(width: 6),
                      Text(
                        _activeTab == 0 ? 'ADD EXPERIENCE' : 'ADD CREDENTIAL',
                        style: GoogleFonts.interTight(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 36),

        // Timeline Items
        if (filteredItems.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            alignment: Alignment.centerLeft,
            child: Text(
              _activeTab == 0
                  ? 'No work experience entries published yet.'
                  : 'No education or credentials published yet.',
              style: GoogleFonts.interTight(
                fontSize: 14,
                color: AppColors.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredItems.length,
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.hairline,
              height: 1,
            ),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _ExperienceItemCard(
                key: ValueKey(item.id),
                item: item,
                index: index,
                totalCount: filteredItems.length,
                isMobile: isMobile,
                isAdmin: isAdmin,
                onEdit: () => _openEditDialog(allItems, item),
                onToggleActive: () => _toggleItemActive(allItems, item),
                onMoveUp: index > 0 ? () => _reorderItem(allItems, filteredItems, index, index - 1) : null,
                onMoveDown: index < filteredItems.length - 1
                    ? () => _reorderItem(allItems, filteredItems, index, index + 1)
                    : null,
                onDelete: () => _confirmDeleteItem(allItems, item),
                onSaveField: (field, value) => _updateItemDirectField(allItems, item, field, value),
              );
            },
          ),
      ],
    );
  }

  Widget _buildTabPill(String label, int index, Function(String) onSave, bool isAdmin) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amber : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.amber : AppColors.hairline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radius),
        ),
        child: Text(
          label,
          style: GoogleFonts.interTight(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isSelected ? Colors.black : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // --- CRUD Operations ---

  List<ExperienceItem> _extractExperienceItems(Map<String, dynamic> data) {
    if (data['items'] is List && (data['items'] as List).isNotEmpty) {
      final list = data['items'] as List;
      return list
          .map((e) => ExperienceItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    // Default Seed Items (with fallback to legacy exp1/edu1 keys if present)
    return [
      ExperienceItem(
        id: 'exp-1',
        type: 'work',
        role: data['exp1Role'] ?? 'Full-Stack Flutter Engineer',
        company: data['exp1Company'] ?? 'Independent / Client Projects',
        period: data['exp1Period'] ?? '2024 — PRESENT',
        description: data['exp1Desc'] ??
            'Architecting and shipping end-to-end mobile & web applications. Leading client engagements from requirement engineering to App Store & Play Store releases, integrating Supabase/Node.js backends and real-time state synchronization with Riverpod.',
        location: 'Chennai, IN',
        isActive: true,
        orderIndex: 0,
      ),
      ExperienceItem(
        id: 'exp-2',
        type: 'work',
        role: data['exp2Role'] ?? 'Mobile Application Developer',
        company: data['exp2Company'] ?? 'Software & Product Labs',
        period: data['exp2Period'] ?? '2023 — 2024',
        description: data['exp2Desc'] ??
            'Engineered responsive cross-platform user interfaces, custom canvas animations, and secure authentication flows. Optimized render frame rates to maintain a consistent 60+ FPS on mid-tier mobile devices.',
        location: 'Chennai, IN',
        isActive: true,
        orderIndex: 1,
      ),
      ExperienceItem(
        id: 'edu-1',
        type: 'education',
        role: data['edu1Degree'] ?? 'B.Tech — Computer Science & Business Systems',
        company: data['edu1Inst'] ?? 'Engineering University / Institute',
        period: data['edu1Period'] ?? '2022 — 2026',
        description: data['edu1Desc'] ??
            'Comprehensive coursework covering Algorithms, Object-Oriented Software Engineering, Database Systems, Computer Networks, and Modern Application Development methodologies.',
        location: 'Chennai, IN',
        isActive: true,
        orderIndex: 0,
      ),
      ExperienceItem(
        id: 'edu-2',
        type: 'education',
        role: data['cert1Title'] ?? 'Flutter & Dart Certified Specialist',
        company: data['cert1Org'] ?? 'Professional Certifications',
        period: data['cert1Period'] ?? 'VERIFIED CREDENTIAL',
        description: data['cert1Desc'] ??
            'Validated expertise in advanced state management, asynchronous programming, custom animations, and automated testing for Flutter multiplatform apps.',
        location: 'Online Credential',
        isActive: true,
        orderIndex: 1,
      ),
    ];
  }

  void _persistItems(List<ExperienceItem> items) {
    ref.read(dbServiceProvider).saveExperienceItems(items);
  }

  void _updateItemDirectField(
    List<ExperienceItem> allItems,
    ExperienceItem item,
    String field,
    String value,
  ) {
    final updatedList = allItems.map((it) {
      if (it.id == item.id) {
        switch (field) {
          case 'role':
            return it.copyWith(role: value);
          case 'company':
            return it.copyWith(company: value);
          case 'period':
            return it.copyWith(period: value);
          case 'description':
            return it.copyWith(description: value);
          case 'location':
            return it.copyWith(location: value);
          default:
            return it;
        }
      }
      return it;
    }).toList();

    _persistItems(updatedList);
  }

  void _toggleItemActive(List<ExperienceItem> allItems, ExperienceItem item) {
    final updatedList = allItems.map((it) {
      if (it.id == item.id) {
        return it.copyWith(isActive: !it.isActive);
      }
      return it;
    }).toList();

    _persistItems(updatedList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          !item.isActive
              ? 'Entry activated and now visible to visitors.'
              : 'Entry deactivated (hidden from public portfolio).',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _reorderItem(
    List<ExperienceItem> allItems,
    List<ExperienceItem> currentCategoryItems,
    int oldIndex,
    int newIndex,
  ) {
    if (newIndex < 0 || newIndex >= currentCategoryItems.length) return;

    final itemA = currentCategoryItems[oldIndex];
    final itemB = currentCategoryItems[newIndex];

    final updatedList = allItems.map((it) {
      if (it.id == itemA.id) {
        return it.copyWith(orderIndex: itemB.orderIndex);
      }
      if (it.id == itemB.id) {
        return it.copyWith(orderIndex: itemA.orderIndex);
      }
      return it;
    }).toList();

    _persistItems(updatedList);
  }

  void _confirmDeleteItem(List<ExperienceItem> allItems, ExperienceItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: const BorderSide(color: AppColors.hairlineStrong),
        ),
        title: Text(
          'Delete Entry?',
          style: GoogleFonts.unbounded(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete "${item.role}" at ${item.company}?',
          style: GoogleFonts.interTight(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              final updated = allItems.where((it) => it.id != item.id).toList();
              _persistItems(updated);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Entry removed successfully.')),
              );
            },
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _openCreateDialog(List<ExperienceItem> allItems) {
    final type = _activeTab == 0 ? 'work' : 'education';
    _showItemFormDialog(
      title: type == 'work' ? 'ADD WORK EXPERIENCE' : 'ADD EDUCATION / CREDENTIAL',
      initialItem: ExperienceItem(
        id: 'item_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        role: '',
        company: '',
        period: '',
        description: '',
        location: '',
        isActive: true,
        orderIndex: allItems.length,
      ),
      onSave: (newItem) {
        final updated = [...allItems, newItem];
        _persistItems(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New entry saved to Supabase!')),
        );
      },
    );
  }

  void _openEditDialog(List<ExperienceItem> allItems, ExperienceItem item) {
    _showItemFormDialog(
      title: item.type == 'work' ? 'EDIT WORK EXPERIENCE' : 'EDIT EDUCATION / CREDENTIAL',
      initialItem: item,
      onSave: (editedItem) {
        final updated = allItems.map((it) => it.id == editedItem.id ? editedItem : it).toList();
        _persistItems(updated);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entry updated successfully!')),
        );
      },
    );
  }

  void _showItemFormDialog({
    required String title,
    required ExperienceItem initialItem,
    required Function(ExperienceItem) onSave,
  }) {
    final roleCtrl = TextEditingController(text: initialItem.role);
    final companyCtrl = TextEditingController(text: initialItem.company);
    final periodCtrl = TextEditingController(text: initialItem.period);
    final locationCtrl = TextEditingController(text: initialItem.location);
    final descCtrl = TextEditingController(text: initialItem.description);
    String selectedType = initialItem.type;
    bool isActive = initialItem.isActive;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.bgSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radius),
              side: const BorderSide(color: AppColors.hairlineStrong),
            ),
            title: Text(
              title,
              style: GoogleFonts.unbounded(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: AppColors.amber,
              ),
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type selector
                    Row(
                      children: [
                        Text(
                          'CATEGORY: ',
                          style: GoogleFonts.interTight(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Work Experience'),
                          selected: selectedType == 'work',
                          selectedColor: AppColors.amber,
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = 'work');
                          },
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Education & Creds'),
                          selected: selectedType == 'education',
                          selectedColor: AppColors.amber,
                          onSelected: (val) {
                            if (val) setDialogState(() => selectedType = 'education');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Role / Degree
                    TextField(
                      controller: roleCtrl,
                      style: GoogleFonts.interTight(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: selectedType == 'work' ? 'JOB ROLE / TITLE *' : 'DEGREE / CERTIFICATION *',
                        labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 12),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hairlineStrong)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Company / Institution
                    TextField(
                      controller: companyCtrl,
                      style: GoogleFonts.interTight(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: selectedType == 'work' ? 'COMPANY / CLIENT / ORG *' : 'UNIVERSITY / INSTITUTION *',
                        labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 12),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hairlineStrong)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Period & Location Row
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: periodCtrl,
                            style: GoogleFonts.interTight(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'PERIOD / YEARS * (e.g. 2024 — PRESENT)',
                              labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 12),
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hairlineStrong)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: locationCtrl,
                            style: GoogleFonts.interTight(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'LOCATION (e.g. Chennai / Remote)',
                              labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 12),
                              border: const OutlineInputBorder(),
                              enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hairlineStrong)),
                              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: descCtrl,
                      maxLines: 4,
                      style: GoogleFonts.interTight(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'DESCRIPTION & KEY ACCOMPLISHMENTS',
                        labelStyle: GoogleFonts.interTight(color: AppColors.textMuted, fontSize: 12),
                        border: const OutlineInputBorder(),
                        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.hairlineStrong)),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: AppColors.amber)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Active Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Visible in Public Portfolio',
                        style: GoogleFonts.interTight(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                      subtitle: Text(
                        isActive ? 'Active: visible to all visitors' : 'Inactive: hidden from public visitors',
                        style: GoogleFonts.interTight(fontSize: 11, color: AppColors.textMuted),
                      ),
                      value: isActive,
                      activeThumbColor: AppColors.amber,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radius)),
                ),
                onPressed: () {
                  if (roleCtrl.text.trim().isEmpty || companyCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill out the Title and Organization fields.')),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  onSave(
                    initialItem.copyWith(
                      type: selectedType,
                      role: roleCtrl.text.trim(),
                      company: companyCtrl.text.trim(),
                      period: periodCtrl.text.trim(),
                      location: locationCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      isActive: isActive,
                    ),
                  );
                },
                child: const Text('SAVE ENTRY', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExperienceItemCard extends StatefulWidget {
  final ExperienceItem item;
  final int index;
  final int totalCount;
  final bool isMobile;
  final bool isAdmin;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback onDelete;
  final Function(String field, String value) onSaveField;

  const _ExperienceItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.totalCount,
    required this.isMobile,
    required this.isAdmin,
    required this.onEdit,
    required this.onToggleActive,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onSaveField,
  });

  @override
  State<_ExperienceItemCard> createState() => _ExperienceItemCardState();
}

class _ExperienceItemCardState extends State<_ExperienceItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isInactive = !item.isActive;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          vertical: widget.isMobile ? 20 : 26,
          horizontal: widget.isMobile ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.bgSurface
              : (isInactive ? Colors.white.withValues(alpha: 0.02) : Colors.transparent),
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: isInactive
              ? Border.all(color: Colors.white12, style: BorderStyle.solid)
              : null,
        ),
        child: Opacity(
          opacity: isInactive && !widget.isAdmin ? 0.0 : (isInactive ? 0.6 : 1.0),
          child: widget.isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Period & Active status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: EditableTextWidget(
                            text: item.period,
                            onSave: (v) => widget.onSaveField('period', v),
                            style: GoogleFonts.interTight(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              color: AppColors.amber,
                            ),
                          ),
                        ),
                        if (widget.isAdmin) _buildActivePill(item.isActive),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Role Title
                    EditableTextWidget(
                      text: item.role,
                      onSave: (v) => widget.onSaveField('role', v),
                      style: GoogleFonts.unbounded(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _hovered ? AppColors.amber : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Company & Location
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        EditableTextWidget(
                          text: item.company,
                          onSave: (v) => widget.onSaveField('company', v),
                          style: GoogleFonts.interTight(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (item.location.isNotEmpty) ...[
                          const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                          EditableTextWidget(
                            text: item.location,
                            onSave: (v) => widget.onSaveField('location', v),
                            style: GoogleFonts.interTight(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Description
                    EditableTextWidget(
                      text: item.description,
                      onSave: (v) => widget.onSaveField('description', v),
                      style: GoogleFonts.interTight(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                        height: 1.6,
                      ),
                    ),

                    // Admin Action Bar on Mobile
                    if (widget.isAdmin) ...[
                      const SizedBox(height: 16),
                      const Divider(color: AppColors.hairline, height: 1),
                      const SizedBox(height: 8),
                      _buildAdminActionsBar(isMobile: true),
                    ],
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Period Column (Flexible width)
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditableTextWidget(
                            text: item.period,
                            onSave: (v) => widget.onSaveField('period', v),
                            style: GoogleFonts.interTight(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.3,
                              color: _hovered ? AppColors.amber : AppColors.textMuted,
                            ),
                          ),
                          if (widget.isAdmin) ...[
                            const SizedBox(height: 6),
                            _buildActivePill(item.isActive),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Role & Organization Column
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditableTextWidget(
                            text: item.role,
                            onSave: (v) => widget.onSaveField('role', v),
                            style: GoogleFonts.unbounded(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: _hovered ? AppColors.amber : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              EditableTextWidget(
                                text: item.company,
                                onSave: (v) => widget.onSaveField('company', v),
                                style: GoogleFonts.interTight(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              if (item.location.isNotEmpty) ...[
                                const Text('•', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                EditableTextWidget(
                                  text: item.location,
                                  onSave: (v) => widget.onSaveField('location', v),
                                  style: GoogleFonts.interTight(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Description Column
                    Expanded(
                      flex: 5,
                      child: EditableTextWidget(
                        text: item.description,
                        onSave: (v) => widget.onSaveField('description', v),
                        style: GoogleFonts.interTight(
                          fontSize: 13.5,
                          color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ),

                    // Admin Toolbar on Desktop
                    if (widget.isAdmin) ...[
                      const SizedBox(width: 16),
                      _buildAdminActionsBar(isMobile: false),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildActivePill(bool isActive) {
    return GestureDetector(
      onTap: widget.onToggleActive,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
            border: Border.all(
              color: isActive ? Colors.greenAccent : Colors.redAccent,
              width: 0.8,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            isActive ? 'ACTIVE' : 'HIDDEN',
            style: GoogleFonts.interTight(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: isActive ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActionsBar({required bool isMobile}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: isMobile ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        // Reorder Up
        IconButton(
          icon: const Icon(Icons.arrow_upward, size: 16),
          color: widget.onMoveUp != null ? AppColors.amber : AppColors.hairlineStrong,
          tooltip: 'Move Up',
          onPressed: widget.onMoveUp,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 2),
        // Reorder Down
        IconButton(
          icon: const Icon(Icons.arrow_downward, size: 16),
          color: widget.onMoveDown != null ? AppColors.amber : AppColors.hairlineStrong,
          tooltip: 'Move Down',
          onPressed: widget.onMoveDown,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Activate/Deactivate Toggle
        IconButton(
          icon: Icon(
            widget.item.isActive ? Icons.visibility : Icons.visibility_off,
            size: 16,
            color: widget.item.isActive ? Colors.greenAccent : Colors.redAccent,
          ),
          tooltip: widget.item.isActive ? 'Deactivate (Hide)' : 'Activate (Show)',
          onPressed: widget.onToggleActive,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Edit Dialog
        IconButton(
          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.amber),
          tooltip: 'Edit Details',
          onPressed: widget.onEdit,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 4),
        // Delete
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
          tooltip: 'Delete',
          onPressed: widget.onDelete,
          padding: const EdgeInsets.all(6),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
