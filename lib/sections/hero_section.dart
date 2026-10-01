import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/sections/admin_login_screen.dart';
import 'package:portfolio/providers/app_providers.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

class HeroSection extends ConsumerStatefulWidget {
  final VoidCallback onViewProjects;
  final VoidCallback onContactMe;

  const HeroSection({
    super.key,
    required this.onViewProjects,
    required this.onContactMe,
  });

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection> {
  Uint8List? _previewImageBytes;
  bool _isUploadingProfile = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 800;
    final isTablet = size.width < 1150 && !isMobile;

    final contentAsync = ref.watch(contentProvider('hero'));
    final data = contentAsync.value ?? {};

    final greeting = data['greeting'] ?? 'FULL-STACK MOBILE & WEB ARCHITECT';
    final statusLabel = data['statusLabel'] ?? 'AVAILABLE FOR SELECT ROLES';
    final name = (data['name'] ?? 'HARRISH').toString().toUpperCase();
    final description = data['description'] ??
        'Engineering fluid, pixel-precise mobile systems and high-throughput backends. Specializing in Flutter multiplatform architectures, real-time reactive streams, and production reliability.';

    final metaLocLabel = data['metaLocLabel'] ?? 'LOCATION';
    final metaLocVal = data['metaLocVal'] ?? 'CHENNAI, IN';
    final metaFocusLabel = data['metaFocusLabel'] ?? 'FOCUS';
    final metaFocusVal = data['metaFocusVal'] ?? 'FLUTTER / SUPABASE';
    final metaExpLabel = data['metaExpLabel'] ?? 'EXPERIENCE';
    final metaExpVal = data['metaExpVal'] ?? 'PRODUCTION READY';

    final projectsBtnLabel = data['projectsBtnLabel'] ?? 'VIEW SELECTED WORK';
    final resumeBtnLabel = data['resumeBtnLabel'] ?? 'RESUME / CV';
    final githubUrl = data['githubUrl'] ?? 'https://github.com/harrishj';
    final linkedinUrl = data['linkedinUrl'] ?? 'https://linkedin.com/in/harrish-j-908378269';

    final resumeUrl = data['resumeUrl'] as String?;

    void updateDoc(String key, String val) {
      ref.read(dbServiceProvider).updateContent('hero', {key: val});
    }

    Future<void> handleResumeAction() async {
      final isAdmin = ref.read(isAdminProvider);
      final messenger = ScaffoldMessenger.of(context);
      if (isAdmin) {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: ['pdf'],
            withData: true,
          );

          if (result != null && result.files.single.bytes != null) {
            messenger.showSnackBar(
              const SnackBar(content: Text('Uploading Resume...')),
            );
            final url = await ref.read(storageServiceProvider).uploadResume(
                  result.files.single.bytes!,
                  'resume.pdf',
                );
            if (url != null) {
              ref.read(dbServiceProvider).updateContent('hero', {'resumeUrl': url});
              messenger.showSnackBar(
                const SnackBar(content: Text('Resume uploaded successfully!')),
              );
            }
          }
        } catch (e) {
          messenger.showSnackBar(
            SnackBar(content: Text('Upload failed: ${e.toString().split(']').last}')),
          );
        }
      } else {
        if (resumeUrl != null && resumeUrl.isNotEmpty) {
          final uri = Uri.parse(resumeUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        } else {
          messenger.showSnackBar(
            const SnackBar(content: Text('Resume is currently being updated. Please reach out via contact!')),
          );
        }
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 64,
        vertical: isMobile ? 40 : 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Meta Bar: Subtitle & Availability Indicator (Responsive Wrap)
              ScrollReveal(
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 16,
                  runSpacing: 10,
                  children: [
                    EditableTextWidget(
                      text: greeting,
                      onSave: (val) => updateDoc('greeting', val),
                      style: GoogleFonts.interTight(
                        fontSize: isMobile ? 11 : 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: AppColors.amber,
                      ),
                    ),
                    // Availability Status
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AppColors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        EditableTextWidget(
                          text: statusLabel,
                          onSave: (val) => updateDoc('statusLabel', val),
                          style: GoogleFonts.interTight(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 36),

              // Giant Display Name / Heading Across Width
              ScrollReveal(
                delay: 0.1,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      EditableTextWidget(
                        text: name,
                        onSave: (val) => updateDoc('name', val),
                        style: GoogleFonts.unbounded(
                          fontSize: isMobile ? 54 : (isTablet ? 92 : 120),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2.5,
                          height: 0.85,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '.',
                        style: GoogleFonts.unbounded(
                          fontSize: isMobile ? 54 : (isTablet ? 92 : 120),
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber,
                          height: 0.85,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 36),

              // Split Studio Meta Row: Left Column Description + Right Column Profile/Actions
              ScrollReveal(
                delay: 0.2,
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileImage(data),
                          const SizedBox(height: 28),
                          _buildDescriptionBlock(
                            description: description,
                            metaLocLabel: metaLocLabel,
                            metaLocVal: metaLocVal,
                            metaFocusLabel: metaFocusLabel,
                            metaFocusVal: metaFocusVal,
                            metaExpLabel: metaExpLabel,
                            metaExpVal: metaExpVal,
                            updateDoc: updateDoc,
                          ),
                          const SizedBox(height: 32),
                          _buildActionsBlock(
                            handleResumeAction: handleResumeAction,
                            resumeUrl: resumeUrl,
                            projectsBtnLabel: projectsBtnLabel,
                            resumeBtnLabel: resumeBtnLabel,
                            githubUrl: githubUrl,
                            linkedinUrl: linkedinUrl,
                            updateDoc: updateDoc,
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left 65%: Description & Details
                          Expanded(
                            flex: 13,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDescriptionBlock(
                                  description: description,
                                  metaLocLabel: metaLocLabel,
                                  metaLocVal: metaLocVal,
                                  metaFocusLabel: metaFocusLabel,
                                  metaFocusVal: metaFocusVal,
                                  metaExpLabel: metaExpLabel,
                                  metaExpVal: metaExpVal,
                                  updateDoc: updateDoc,
                                ),
                                const SizedBox(height: 36),
                                _buildActionsBlock(
                                  handleResumeAction: handleResumeAction,
                                  resumeUrl: resumeUrl,
                                  projectsBtnLabel: projectsBtnLabel,
                                  resumeBtnLabel: resumeBtnLabel,
                                  githubUrl: githubUrl,
                                  linkedinUrl: linkedinUrl,
                                  updateDoc: updateDoc,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 48),
                          // Right 35%: Profile image with duotone treatment + quick facts
                          Expanded(
                            flex: 7,
                            child: _buildProfileImage(data),
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

  Widget _buildDescriptionBlock({
    required String description,
    required String metaLocLabel,
    required String metaLocVal,
    required String metaFocusLabel,
    required String metaFocusVal,
    required String metaExpLabel,
    required String metaExpVal,
    required Function(String, String) updateDoc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: description,
          onSave: (val) => updateDoc('description', val),
          style: GoogleFonts.interTight(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.7,
            letterSpacing: -0.1,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 14,
          children: [
            _MetaTag(
              label: metaLocLabel,
              value: metaLocVal,
              onLabelSave: (v) => updateDoc('metaLocLabel', v),
              onValSave: (v) => updateDoc('metaLocVal', v),
            ),
            _MetaTag(
              label: metaFocusLabel,
              value: metaFocusVal,
              onLabelSave: (v) => updateDoc('metaFocusLabel', v),
              onValSave: (v) => updateDoc('metaFocusVal', v),
            ),
            _MetaTag(
              label: metaExpLabel,
              value: metaExpVal,
              onLabelSave: (v) => updateDoc('metaExpLabel', v),
              onValSave: (v) => updateDoc('metaExpVal', v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsBlock({
    required Future<void> Function() handleResumeAction,
    required String? resumeUrl,
    required String projectsBtnLabel,
    required String resumeBtnLabel,
    required String githubUrl,
    required String linkedinUrl,
    required Function(String, String) updateDoc,
  }) {
    final isAdmin = ref.watch(isAdminProvider);

    return Wrap(
      spacing: 16,
      runSpacing: 14,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Primary Projects CTA
        _NikiButton(
          label: projectsBtnLabel,
          icon: Icons.arrow_forward_rounded,
          isPrimary: true,
          onTap: widget.onViewProjects,
        ),
        // Resume CTA
        _NikiButton(
          label: isAdmin ? 'UPLOAD RESUME (PDF)' : resumeBtnLabel,
          icon: Icons.download_rounded,
          isPrimary: false,
          onTap: handleResumeAction,
        ),
        // Quick Socials
        const SizedBox(width: 8),
        _SocialIconLink(
          icon: FontAwesomeIcons.github,
          tooltip: 'GitHub',
          url: githubUrl,
        ),
        _SocialIconLink(
          icon: FontAwesomeIcons.linkedinIn,
          tooltip: 'LinkedIn',
          url: linkedinUrl,
        ),
        _SocialIconLink(
          icon: Icons.alternate_email_rounded,
          tooltip: 'Email',
          onTap: widget.onContactMe,
        ),
      ],
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> data) {
    final isAdmin = ref.watch(isAdminProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onDoubleTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
            );
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 320, maxHeight: 380),
                decoration: BoxDecoration(
                  color: AppColors.bgSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  border: Border.all(color: AppColors.cardBorder, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                  // Grayscale / Duotone treatment with subtle warm amber tint
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.matrix(<double>[
                      0.85, 0, 0, 0, 18,
                      0, 0.80, 0, 0, 14,
                      0, 0, 0.70, 0, 6,
                      0, 0, 0, 1, 0,
                    ]),
                    child: _buildImageContent(data),
                  ),
                ),
              ),

              // Admin upload button
              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: _pickAndUploadProfileImage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.amber,
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.camera_alt, size: 12, color: Colors.black),
                          const SizedBox(width: 4),
                          Text(
                            'CHANGE',
                            style: GoogleFonts.interTight(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Uploading overlay indicator
              if (_isUploadingProfile)
                Positioned.fill(
                  child: Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.amber),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'FIG 01. / PROFILE / MONOCHROME AMBER',
          style: GoogleFonts.interTight(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent(Map<String, dynamic> data) {
    if (_previewImageBytes != null) {
      return Image.memory(
        _previewImageBytes!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/me.png', fit: BoxFit.cover),
      );
    }
    if (data['profileImage'] != null && data['profileImage'].toString().isNotEmpty) {
      return Image.network(
        data['profileImage'].toString(),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset('assets/me.png', fit: BoxFit.cover),
      );
    }
    return Image.asset(
      'assets/me.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.bgSurface,
        height: 280,
        child: const Center(child: Icon(Icons.person, size: 48, color: AppColors.textMuted)),
      ),
    );
  }

  Future<void> _pickAndUploadProfileImage() async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      final bytes = file.bytes;
      if (bytes == null) return;

      setState(() {
        _previewImageBytes = bytes;
        _isUploadingProfile = true;
      });

      final url = await ref.read(storageServiceProvider).uploadGeneralImage(
            'profile_image.png',
            bytes,
          );

      if (url != null) {
        await ref.read(dbServiceProvider).updateContent('hero', {'profileImage': url});
        ref.invalidate(contentProvider('hero'));
        messenger.showSnackBar(
          const SnackBar(content: Text('Profile image saved successfully!')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploadingProfile = false);
    }
  }
}

class _MetaTag extends StatelessWidget {
  final String label;
  final String value;
  final Function(String)? onLabelSave;
  final Function(String)? onValSave;

  const _MetaTag({
    required this.label,
    required this.value,
    this.onLabelSave,
    this.onValSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (onLabelSave != null)
          EditableTextWidget(
            text: label,
            onSave: onLabelSave!,
            style: GoogleFonts.interTight(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          )
        else
          Text(
            label,
            style: GoogleFonts.interTight(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: AppColors.textMuted,
            ),
          ),
        const SizedBox(height: 2),
        if (onValSave != null)
          EditableTextWidget(
            text: value,
            onSave: onValSave!,
            style: GoogleFonts.interTight(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          )
        else
          Text(
            value,
            style: GoogleFonts.interTight(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }
}

class _NikiButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _NikiButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  State<_NikiButton> createState() => _NikiButtonState();
}

class _NikiButtonState extends State<_NikiButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            color: widget.isPrimary
                ? (_hovered ? const Color(0xFFD68B2A) : AppColors.amber)
                : (_hovered ? AppColors.bgCardHover : Colors.transparent),
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
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: widget.isPrimary ? Colors.black : AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                widget.icon,
                size: 14,
                color: widget.isPrimary ? Colors.black : AppColors.amber,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIconLink extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final String? url;
  final VoidCallback? onTap;

  const _SocialIconLink({
    required this.icon,
    required this.tooltip,
    this.url,
    this.onTap,
  });

  @override
  State<_SocialIconLink> createState() => _SocialIconLinkState();
}

class _SocialIconLinkState extends State<_SocialIconLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () async {
          if (widget.onTap != null) {
            widget.onTap!();
          } else if (widget.url != null) {
            final uri = Uri.parse(widget.url!);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          }
        },
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _hovered ? AppColors.bgCardHover : AppColors.bgSurface,
              border: Border.all(
                color: _hovered ? AppColors.amber : AppColors.cardBorder,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: FaIcon(
              widget.icon,
              size: 15,
              color: _hovered ? AppColors.amber : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
