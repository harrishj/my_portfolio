import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/providers/app_providers.dart';

class TechStackSection extends ConsumerStatefulWidget {
  const TechStackSection({super.key});

  @override
  ConsumerState<TechStackSection> createState() => _TechStackSectionState();
}

class _TechStackSectionState extends ConsumerState<TechStackSection> {
  String _selectedCategory = 'ALL';

  final List<String> _categories = [
    'ALL',
    'MOBILE & FRONTEND',
    'BACKEND & SERVICES',
    'DATABASE & CLOUD',
    'SYSTEMS & TOOLING',
  ];

  String _getCategoryForTech(String techName) {
    final name = techName.toLowerCase();
    if (name.contains('flutter') || name.contains('dart') || name.contains('android') || name.contains('ios') || name.contains('react') || name.contains('ui')) {
      return 'MOBILE & FRONTEND';
    }
    if (name.contains('node') || name.contains('express') || name.contains('api') || name.contains('python') || name.contains('java') || name.contains('c')) {
      return 'BACKEND & SERVICES';
    }
    if (name.contains('mongo') || name.contains('sql') || name.contains('db') || name.contains('fire') || name.contains('supabase')) {
      return 'DATABASE & CLOUD';
    }
    return 'SYSTEMS & TOOLING';
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;
    final isAdmin = ref.watch(isAdminProvider);

    final contentAsync = ref.watch(contentProvider('tech'));
    final data = contentAsync.value ?? {};

    final leftLabel = data['leftLabel'] ?? '02 / STACK';
    final leftEyebrow = data['leftEyebrow'] ?? 'TECHNOLOGY ECOSYSTEM';
    final leftDesc = data['leftDesc'] ??
        'Typographic catalog of core runtimes, databases, design primitives, and frameworks.';

    final title = data['title'] ?? 'TECHNICAL CAPABILITIES & SYSTEMS';
    final subtitle = data['subtitle'] ?? 'Battle-tested tools and languages architected for production stability.';

    List<dynamic> itemsData = data['items'] ?? [
      {'name': 'Flutter', 'description': 'Production multiplatform engine for iOS, Android, macOS & Web with native performance.'},
      {'name': 'Dart', 'description': 'Type-safe object-oriented language with AOT native compilation and async pipelines.'},
      {'name': 'Riverpod', 'description': 'Compile-safe, reactive state management, caching, and dependency injection.'},
      {'name': 'Node.js & Express', 'description': 'High-throughput event-driven microservices, token auth, and custom middleware.'},
      {'name': 'Supabase', 'description': 'PostgreSQL backend-as-a-service with Row Level Security, Storage, and Realtime streams.'},
      {'name': 'Firebase', 'description': 'Cloud Firestore, Push Notifications, Authentication and edge serverless triggers.'},
      {'name': 'MongoDB', 'description': 'Document-based flexible data modeling with compound indexes and aggregation.'},
      {'name': 'PostgreSQL', 'description': 'Relational data modeling, ACID transactions, complex joins and stored procedures.'},
      {'name': 'Git & CI/CD', 'description': 'Trunk-based development, GitHub Actions automation, release pipelines.'},
      {'name': 'REST & WebSockets', 'description': 'Contract-first API design, streaming channels, low-latency payload serialization.'},
    ];

    void updateDoc(String key, dynamic val) {
      ref.read(dbServiceProvider).updateContent('tech', {key: val});
    }

    void updateItem(int index, String key, String val) {
      final List<dynamic> newItems = List.from(itemsData);
      newItems[index] = Map<String, dynamic>.from(newItems[index]);
      newItems[index][key] = val;
      updateDoc('items', newItems);
    }

    final filteredItems = _selectedCategory == 'ALL'
        ? itemsData
        : itemsData.where((item) {
            final name = (item['name'] ?? '').toString();
            return _getCategoryForTech(name) == _selectedCategory;
          }).toList();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: isMobile ? 64 : 100,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            children: [
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 48),

              ScrollReveal(
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftStickyLabel(leftLabel, leftEyebrow, leftDesc, updateDoc),
                          const SizedBox(height: 32),
                          _buildContent(
                            title,
                            subtitle,
                            itemsData,
                            filteredItems,
                            updateDoc,
                            updateItem,
                            isAdmin,
                            isMobile,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Sticky Studio Column
                          SizedBox(
                            width: 260,
                            child: _buildLeftStickyLabel(leftLabel, leftEyebrow, leftDesc, updateDoc),
                          ),
                          const SizedBox(width: 48),
                          // Vertical Hairline Separator
                          Container(
                            width: 1,
                            height: 650,
                            color: AppColors.hairline,
                          ),
                          const SizedBox(width: 48),
                          // Right Typographic Columns
                          Expanded(
                            child: _buildContent(
                              title,
                              subtitle,
                              itemsData,
                              filteredItems,
                              updateDoc,
                              updateItem,
                              isAdmin,
                              isMobile,
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
                onSave: (v) => updateDoc('leftLabel', v),
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
          onSave: (v) => updateDoc('leftEyebrow', v),
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
          onSave: (v) => updateDoc('leftDesc', v),
          style: GoogleFonts.interTight(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
    String title,
    String subtitle,
    List<dynamic> itemsData,
    List<dynamic> filteredItems,
    Function(String, dynamic) updateDoc,
    Function(int, String, String) updateItem,
    bool isAdmin,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: title,
          onSave: (val) => updateDoc('title', val),
          style: GoogleFonts.unbounded(
            fontSize: isMobile ? 26 : 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            color: AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        EditableTextWidget(
          text: subtitle,
          onSave: (val) => updateDoc('subtitle', val),
          style: GoogleFonts.interTight(
            fontSize: isMobile ? 15 : 18,
            fontWeight: FontWeight.w500,
            color: AppColors.amber,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),

        // Filter pills in NIKI minimal style
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.amber : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? AppColors.amber : AppColors.hairline,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.interTight(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: isSelected ? Colors.black : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 36),

        // Typographic List with Hairline Separators
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredItems.length,
          separatorBuilder: (context, index) => const Divider(
            color: AppColors.hairline,
            height: 1,
          ),
          itemBuilder: (context, i) {
            final itemMap = filteredItems[i] as Map<String, dynamic>;
            final originalIndex = itemsData.indexOf(itemMap);
            final name = itemMap['name'] ?? '';
            final description = itemMap['description'] ?? '';

            return _TypographicSkillRow(
              index: i + 1,
              name: name,
              description: description,
              category: _getCategoryForTech(name),
              isAdmin: isAdmin,
              onNameSave: (val) => updateItem(originalIndex, 'name', val),
              onDescSave: (val) => updateItem(originalIndex, 'description', val),
              onDelete: () {
                final newItems = List.from(itemsData);
                newItems.removeAt(originalIndex);
                updateDoc('items', newItems);
              },
            );
          },
        ),

        const Divider(color: AppColors.hairline, height: 1),

        // Admin Add Skill Button
        if (isAdmin) ...[
          const SizedBox(height: 24),
          InkWell(
            onTap: () {
              final newItems = List.from(itemsData);
              newItems.add({
                'name': 'New Skill',
                'description': 'Production architecture and implementation details...',
              });
              updateDoc('items', newItems);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.amber, width: 1),
                borderRadius: BorderRadius.circular(AppTheme.radius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add, size: 16, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Text(
                    'ADD SKILL / TECHNOLOGY',
                    style: GoogleFonts.interTight(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.amber,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TypographicSkillRow extends StatefulWidget {
  final int index;
  final String name;
  final String description;
  final String category;
  final bool isAdmin;
  final Function(String) onNameSave;
  final Function(String) onDescSave;
  final VoidCallback onDelete;

  const _TypographicSkillRow({
    required this.index,
    required this.name,
    required this.description,
    required this.category,
    required this.isAdmin,
    required this.onNameSave,
    required this.onDescSave,
    required this.onDelete,
  });

  @override
  State<_TypographicSkillRow> createState() => _TypographicSkillRowState();
}

class _TypographicSkillRowState extends State<_TypographicSkillRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 960;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        color: _hovered ? AppColors.bgSurface : Colors.transparent,
        child: isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      EditableTextWidget(
                        text: widget.name,
                        onSave: widget.onNameSave,
                        style: GoogleFonts.unbounded(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _hovered ? AppColors.amber : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        widget.index < 10 ? '0${widget.index}' : '${widget.index}',
                        style: GoogleFonts.interTight(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  EditableTextWidget(
                    text: widget.description,
                    onSave: widget.onDescSave,
                    style: GoogleFonts.interTight(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (widget.isAdmin)
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                        onPressed: widget.onDelete,
                      ),
                    ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Row Index
                  SizedBox(
                    width: 48,
                    child: Text(
                      widget.index < 10 ? '0${widget.index}' : '${widget.index}',
                      style: GoogleFonts.interTight(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _hovered ? AppColors.amber : AppColors.textMuted,
                      ),
                    ),
                  ),
                  // Name (Bold Typographic)
                  SizedBox(
                    width: 200,
                    child: EditableTextWidget(
                      text: widget.name,
                      onSave: widget.onNameSave,
                      style: GoogleFonts.unbounded(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _hovered ? AppColors.amber : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Description
                  Expanded(
                    child: EditableTextWidget(
                      text: widget.description,
                      onSave: widget.onDescSave,
                      style: GoogleFonts.interTight(
                        fontSize: 14,
                        color: _hovered ? AppColors.textPrimary : AppColors.textSecondary,
                        height: 1.55,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Category Tag
                  Text(
                    widget.category,
                    style: GoogleFonts.interTight(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                      color: AppColors.textMuted,
                    ),
                  ),
                  if (widget.isAdmin) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                      onPressed: widget.onDelete,
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
