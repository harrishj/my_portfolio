import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/widgets/device_frame_mockup.dart';
import 'package:portfolio/models/project_data.dart';
import 'package:portfolio/providers/app_providers.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/widgets/editable_media.dart';
import 'package:video_player/video_player.dart';
import 'dart:typed_data';

class ProjectsSection extends ConsumerStatefulWidget {
  const ProjectsSection({super.key});

  @override
  ConsumerState<ProjectsSection> createState() => _ProjectsSectionState();
}

class _ProjectsSectionState extends ConsumerState<ProjectsSection> {
  List<ProjectData>? _localProjects;
  int? _draggingIndex;
  int? _dropTargetIndex;

  Future<void> _reorderProjects(List<ProjectData> displayProjects, int fromIndex, int toIndex) async {
    if (fromIndex == toIndex) return;
    setState(() {
      final item = displayProjects.removeAt(fromIndex);
      displayProjects.insert(toIndex, item);
      _localProjects = List.from(displayProjects);
      _draggingIndex = null;
      _dropTargetIndex = null;
    });

    try {
      final orderedIds = displayProjects
          .map((p) => p.id)
          .where((id) => id.isNotEmpty)
          .toList();
      if (orderedIds.isNotEmpty) {
        await ref.read(dbServiceProvider).saveProjectsOrder(orderedIds);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project priority updated & saved to Supabase!'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error saving project order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;

    final contentAsync = ref.watch(contentProvider('projects'));
    final contentData = contentAsync.value ?? {};

    final sectionTitle = contentData['title'] ?? 'CROSS-PLATFORM PRODUCTIONS';
    final leftLabel = contentData['leftLabel'] ?? '04 / WORK';
    final leftEyebrow = contentData['leftEyebrow'] ?? 'SELECTED MOBILE APPS';
    final leftDesc = contentData['leftDesc'] ??
        'Curated client deployments, high-performance engines, and production Flutter architectures.';
    final reorderBadge = contentData['reorderBadge'] ?? 'DRAG TO REORDER';
    final addBtnLabel = contentData['addBtnLabel'] ?? 'ADD NEW PROJECT TO SHOWCASE';

    void updateDoc(String key, dynamic val) {
      ref.read(dbServiceProvider).updateContent('projects', {key: val});
    }

    final orderedAsync = ref.watch(orderedProjectsProvider);
    final isAdmin = ref.watch(isAdminProvider);

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

              // Header in Split Studio
              ScrollReveal(
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLeftStickyLabel(leftLabel, leftEyebrow, leftDesc, updateDoc, isAdmin),
                          const SizedBox(height: 24),
                          _buildHeaderTitle(
                            isMobile: isMobile,
                            isAdmin: isAdmin,
                            title: sectionTitle,
                            onTitleSave: (v) => updateDoc('title', v),
                            reorderBadge: reorderBadge,
                            onBadgeSave: (v) => updateDoc('reorderBadge', v),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 260,
                            child: _buildLeftStickyLabel(leftLabel, leftEyebrow, leftDesc, updateDoc, isAdmin),
                          ),
                          const SizedBox(width: 48),
                          Container(width: 1, height: 80, color: AppColors.hairline),
                          const SizedBox(width: 48),
                          Expanded(
                            child: _buildHeaderTitle(
                              isMobile: isMobile,
                              isAdmin: isAdmin,
                              title: sectionTitle,
                              onTitleSave: (v) => updateDoc('title', v),
                              reorderBadge: reorderBadge,
                              onBadgeSave: (v) => updateDoc('reorderBadge', v),
                            ),
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 64),

              // Projects Stream
              orderedAsync.when(
                data: (projects) {
                  final baseList = projects.isNotEmpty ? projects : _getDefaultProjects();

                  // Sync local state if not actively dragging and list has updated
                  if (_draggingIndex == null) {
                    final currentIds = _localProjects?.map((p) => p.id).join(',');
                    final baseIds = baseList.map((p) => p.id).join(',');
                    if (currentIds != baseIds) {
                      _localProjects = List.from(baseList);
                    }
                  }

                  final displayProjects = _localProjects ?? baseList;

                  return Column(
                    children: [
                      ...List.generate(displayProjects.length, (i) {
                        final project = displayProjects[i];
                        final isDropTarget = _dropTargetIndex == i;
                        final isDraggingThis = _draggingIndex == i;

                        return DragTarget<int>(
                          onWillAcceptWithDetails: (details) {
                            if (details.data != i) {
                              setState(() => _dropTargetIndex = i);
                              return true;
                            }
                            return false;
                          },
                          onLeave: (_) {
                            if (_dropTargetIndex == i) {
                              setState(() => _dropTargetIndex = null);
                            }
                          },
                          onAcceptWithDetails: (details) async {
                            final fromIndex = details.data;
                            final toIndex = i;
                            await _reorderProjects(displayProjects, fromIndex, toIndex);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: isDropTarget
                                  ? BoxDecoration(
                                      border: Border.all(color: AppColors.amber, width: 2),
                                      color: AppColors.amber.withValues(alpha: 0.05),
                                    )
                                  : null,
                              child: Column(
                                children: [
                                  if (isDropTarget)
                                    Container(
                                      height: 3,
                                      width: double.infinity,
                                      color: AppColors.amber,
                                    ),
                                  Opacity(
                                    opacity: isDraggingThis ? 0.35 : 1.0,
                                    child: _ProjectSplitBlock(
                                      project: project,
                                      index: i + 1,
                                      isMobile: isMobile,
                                      isAdmin: isAdmin,
                                      onMoveUp: i > 0
                                          ? () => _reorderProjects(displayProjects, i, i - 1)
                                          : null,
                                      onMoveDown: i < displayProjects.length - 1
                                          ? () => _reorderProjects(displayProjects, i, i + 1)
                                          : null,
                                      dragHandle: Draggable<int>(
                                        data: i,
                                        onDragStarted: () => setState(() => _draggingIndex = i),
                                        onDragEnd: (_) => setState(() {
                                          _draggingIndex = null;
                                          _dropTargetIndex = null;
                                        }),
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Container(
                                            width: 320,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              color: AppColors.bgSurface,
                                              border: Border.all(color: AppColors.amber, width: 1.5),
                                              borderRadius: BorderRadius.circular(AppTheme.radius),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0x66000000),
                                                  blurRadius: 20,
                                                  offset: Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.drag_indicator, color: AppColors.amber, size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    project.title,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: GoogleFonts.unbounded(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        child: MouseRegion(
                                          cursor: SystemMouseCursors.grab,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: AppColors.amber.withValues(alpha: 0.15),
                                              border: Border.all(
                                                color: AppColors.amber.withValues(alpha: 0.5),
                                                width: 1,
                                              ),
                                              borderRadius: BorderRadius.circular(AppTheme.radius),
                                            ),
                                            child: const Icon(
                                              Icons.drag_indicator,
                                              size: 16,
                                              color: AppColors.amber,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }),

                      // Admin Add Project Button
                      if (isAdmin) ...[
                        const SizedBox(height: 32),
                        InkWell(
                          onTap: () async {
                            final newProject = ProjectData(
                              id: 'proj_${DateTime.now().millisecondsSinceEpoch}',
                              title: 'NEW MOBILE APP',
                              description: 'Architectural overview of this cross-platform application.',
                              techUsed: const ['Flutter', 'Riverpod', 'Supabase'],
                              platforms: const ['iOS', 'Android'],
                              githubUrl: 'https://github.com',
                            );
                            await ref.read(dbServiceProvider).addProject(newProject);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.amber, width: 1.5),
                              borderRadius: BorderRadius.circular(AppTheme.radius),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add, size: 20, color: AppColors.amber),
                                const SizedBox(width: 10),
                                EditableTextWidget(
                                  text: addBtnLabel,
                                  onSave: (v) => updateDoc('addBtnLabel', v),
                                  style: GoogleFonts.interTight(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.6,
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
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60),
                    child: CircularProgressIndicator(color: AppColors.amber),
                  ),
                ),
                error: (err, _) => Center(
                  child: Text(
                    'Error loading projects: $err',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
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
            Container(width: 8, height: 8, color: AppColors.amber),
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

  Widget _buildHeaderTitle({
    required bool isMobile,
    required bool isAdmin,
    required String title,
    required Function(String) onTitleSave,
    required String reorderBadge,
    required Function(String) onBadgeSave,
  }) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        EditableTextWidget(
          text: title,
          onSave: onTitleSave,
          style: GoogleFonts.unbounded(
            fontSize: isMobile ? 22 : 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: AppColors.textPrimary,
          ),
        ),
        if (isAdmin)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amber.withValues(alpha: 0.15),
              border: Border.all(color: AppColors.amber),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: EditableTextWidget(
              text: reorderBadge,
              onSave: onBadgeSave,
              style: GoogleFonts.interTight(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: AppColors.amber,
              ),
            ),
          ),
      ],
    );
  }

  static List<ProjectData> _getDefaultProjects() {
    return const [
      ProjectData(
        id: 'sample-1',
        title: 'PULSE MOBILE ECOSYSTEM',
        description:
            'A high-performance cross-platform Flutter application featuring real-time synchronization, fluid 60fps animations, and enterprise backend integration.',
        techUsed: ['Flutter', 'Riverpod', 'Supabase', 'Node.js'],
        platforms: ['iOS', 'Android'],
        githubUrl: 'https://github.com/harrishj',
      ),
      ProjectData(
        id: 'sample-2',
        title: 'ARCHITECTURAL SUITE',
        description:
            'End-to-end mobile and web service architected with clean design patterns, reactive state management, and scalable cloud database structures.',
        techUsed: ['Flutter', 'Dart', 'Firebase', 'REST API'],
        platforms: ['iOS', 'Android', 'Web'],
        githubUrl: 'https://github.com/harrishj',
      ),
    ];
  }
}

class _ProjectSplitBlock extends ConsumerStatefulWidget {
  final ProjectData project;
  final int index;
  final bool isMobile;
  final bool isAdmin;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final Widget? dragHandle;

  const _ProjectSplitBlock({
    required this.project,
    required this.index,
    required this.isMobile,
    required this.isAdmin,
    this.onMoveUp,
    this.onMoveDown,
    this.dragHandle,
  });

  @override
  ConsumerState<_ProjectSplitBlock> createState() => _ProjectSplitBlockState();
}

class _ProjectSplitBlockState extends ConsumerState<_ProjectSplitBlock> {
  bool _isHovered = false;

  void _updateProject(String key, dynamic value) {
    final map = widget.project.toJson();
    map[key] = value;
    ref.read(dbServiceProvider).updateProject(ProjectData.fromJson({...map, 'id': widget.project.id}));
  }

  @override
  Widget build(BuildContext context) {
    final numStr = widget.index < 10 ? '0${widget.index}' : '${widget.index}';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.hairline, width: 1)),
        ),
        child: widget.isMobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mobile: Stack device stage above details
                  _buildDeviceStage(),
                  const SizedBox(height: 36),
                  _buildDetailsSide(numStr),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Desktop Left: Details & Actions
                  Expanded(
                    flex: 11,
                    child: _buildDetailsSide(numStr),
                  ),
                  const SizedBox(width: 48),
                  // Desktop Right: Charcoal Stage with Amber Glow & iPhone Frame
                  Expanded(
                    flex: 9,
                    child: _buildDeviceStage(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildDetailsSide(String numStr) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Number & Top Meta Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$numStr / PROJECT',
              style: GoogleFonts.unbounded(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.0,
                color: AppColors.amber,
              ),
            ),
            if (widget.isAdmin)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.dragHandle != null) widget.dragHandle!,
                  if (widget.onMoveUp != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, size: 16),
                      color: AppColors.amber,
                      tooltip: 'Move Priority Up',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: widget.onMoveUp,
                    ),
                  ],
                  if (widget.onMoveDown != null) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.arrow_downward, size: 16),
                      color: AppColors.amber,
                      tooltip: 'Move Priority Down',
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: widget.onMoveDown,
                    ),
                  ],
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                    tooltip: 'Delete Project',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      ref.read(dbServiceProvider).deleteProject(widget.project.id);
                    },
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Big Project Title in Unbounded
        EditableTextWidget(
          text: widget.project.title,
          onSave: (val) => _updateProject('title', val),
          style: GoogleFonts.unbounded(
            fontSize: widget.isMobile ? 26 : 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            color: _isHovered ? AppColors.amber : AppColors.textPrimary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),

        // Tech Tags Pill Row (Minimal Hairline Style)
        if (widget.project.techUsed.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.project.techUsed.map((tech) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.hairlineStrong, width: 1),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  color: AppColors.bgSurface,
                ),
                child: Text(
                  tech.toUpperCase(),
                  style: GoogleFonts.interTight(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.lightGrey,
                  ),
                ),
              );
            }).toList(),
          ),

        const SizedBox(height: 20),

        // Project Description
        EditableTextWidget(
          text: widget.project.description,
          onSave: (val) => _updateProject('description', val),
          style: GoogleFonts.interTight(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.7,
          ),
        ),

        const SizedBox(height: 24),

        // Admin Link Edit Fields
        if (widget.isAdmin) ...[
          _buildAdminUrlRow('GitHub URL:', widget.project.githubUrl, (v) => _updateProject('github_url', v)),
          _buildAdminUrlRow('Demo URL:', widget.project.demoUrl ?? '', (v) => _updateProject('demo_url', v)),
          _buildAdminUrlRow('Play Store:', widget.project.playStoreUrl ?? '', (v) => _updateProject('play_store_url', v)),
          _buildAdminUrlRow('App Store:', widget.project.appStoreUrl ?? '', (v) => _updateProject('app_store_url', v)),
          const SizedBox(height: 16),
        ],

        // Links Buttons
        Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            if (widget.project.githubUrl.isNotEmpty)
              _NikiLinkButton(
                label: 'GITHUB',
                icon: FontAwesomeIcons.github,
                url: widget.project.githubUrl,
              ),
            if (widget.project.demoUrl != null && widget.project.demoUrl!.isNotEmpty)
              _NikiLinkButton(
                label: 'LIVE DEMO',
                icon: Icons.open_in_new,
                url: widget.project.demoUrl!,
                isPrimary: true,
              ),
            if (widget.project.playStoreUrl != null && widget.project.playStoreUrl!.isNotEmpty)
              _NikiLinkButton(
                label: 'PLAY STORE',
                icon: FontAwesomeIcons.googlePlay,
                url: widget.project.playStoreUrl!,
              ),
            if (widget.project.appStoreUrl != null && widget.project.appStoreUrl!.isNotEmpty)
              _NikiLinkButton(
                label: 'APP STORE',
                icon: FontAwesomeIcons.apple,
                url: widget.project.appStoreUrl!,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdminUrlRow(String label, String value, Function(String) onSave) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: GoogleFonts.interTight(fontSize: 11, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: EditableTextWidget(
              text: value,
              onSave: onSave,
              style: GoogleFonts.interTight(fontSize: 12, color: AppColors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceStage() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      transform: Matrix4.translationValues(0, _isHovered ? -6 : 0, 0),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.bgStage,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: _isHovered ? AppColors.amber.withValues(alpha: 0.5) : AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isHovered ? const Color(0x33BA7924) : const Color(0x11000000),
            blurRadius: _isHovered ? 40 : 20,
            spreadRadius: _isHovered ? 4 : 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: DeviceFrameMockup(
          height: widget.isMobile ? 360 : 480,
          child: widget.project.id.isEmpty
              ? Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'Save project to upload media',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ),
                )
              : _ProjectMedia(
                  project: widget.project,
                  onUpload: (bytes, fileName, mimeType, isVideo) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final url = await ref.read(storageServiceProvider).uploadProjectMedia(
                            widget.project.id,
                            bytes,
                            fileName,
                            mimeType,
                            isVideo,
                          );
                      if (url != null) {
                        _updateProject(isVideo ? 'video_url' : 'image_url', url);
                      }
                    } catch (e) {
                      messenger.showSnackBar(
                        SnackBar(content: Text('Upload failed: $e')),
                      );
                    }
                  },
                ),
        ),
      ),
    );
  }
}

class _ProjectMedia extends StatelessWidget {
  final ProjectData project;
  final Function(Uint8List, String, String, bool) onUpload;

  const _ProjectMedia({required this.project, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    Widget media = Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smartphone, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              'PREVIEW ACTIVE',
              style: GoogleFonts.interTight(fontSize: 10, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );

    if (project.videoUrl != null && project.videoUrl!.isNotEmpty) {
      media = _VideoPlayerWidget(videoUrl: project.videoUrl!);
    } else if (project.imageUrl != null && project.imageUrl!.isNotEmpty) {
      media = Image.network(project.imageUrl!, fit: BoxFit.cover);
    }

    return EditableMediaWidget(
      mediaUrl: project.imageUrl ?? project.videoUrl,
      fallbackWidget: media,
      onUpload: onUpload,
    );
  }
}

class _VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const _VideoPlayerWidget({required this.videoUrl});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  VideoPlayerController? _videoController;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        _videoController!.setLooping(true);
        _videoController!.setVolume(0.0);
        _videoController!.play();
        if (mounted) setState(() {});
      });
  }

  @override
  void didUpdateWidget(covariant _VideoPlayerWidget oldWidget) {
    if (oldWidget.videoUrl != widget.videoUrl) {
      _videoController?.dispose();
      _initVideo();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.amber),
        ),
      );
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
}

class _NikiLinkButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final String url;
  final bool isPrimary;

  const _NikiLinkButton({
    required this.label,
    required this.icon,
    required this.url,
    this.isPrimary = false,
  });

  @override
  State<_NikiLinkButton> createState() => _NikiLinkButtonState();
}

class _NikiLinkButtonState extends State<_NikiLinkButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(widget.url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_hovered ? const Color(0xFFD68B2A) : AppColors.amber)
                : (_hovered ? AppColors.bgSurface : Colors.transparent),
            border: Border.all(
              color: widget.isPrimary ? Colors.transparent : AppColors.hairlineStrong,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.interTight(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: widget.isPrimary ? Colors.black : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                widget.icon,
                size: 13,
                color: widget.isPrimary ? Colors.black : AppColors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
