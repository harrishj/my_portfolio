import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/providers/app_providers.dart';

class FooterSection extends ConsumerWidget {
  final VoidCallback? onScrollToTop;

  const FooterSection({super.key, this.onScrollToTop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = MediaQuery.of(context).size.width < 960;
    final contentAsync = ref.watch(contentProvider('footer'));
    final data = contentAsync.value ?? {};

    final text1 = data['text1'] ?? '© 2026 ';
    final name = data['name'] ?? 'HARRISH';
    final text2 = data['text2'] ?? ' — CRAFTED WITH ';
    final tech = data['tech'] ?? 'FLUTTER & SUPABASE';
    final text3 = data['text3'] ?? ' — ALL RIGHTS RESERVED.';
    final githubUrl = data['githubUrl'] ?? 'https://github.com/harrishj';
    final linkedinUrl = data['linkedinUrl'] ?? 'https://linkedin.com/in/harrish-j-908378269';

    void updateDoc(String key, String val) {
      ref.read(dbServiceProvider).updateContent('footer', {key: val});
    }

    return Container(
      width: double.infinity,
      color: AppColors.bgDark,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 24 : 64,
        vertical: 48,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Column(
            children: [
              const Divider(color: AppColors.hairline, height: 1),
              const SizedBox(height: 36),

              isMobile
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildBrandWordmark(name),
                        const SizedBox(height: 20),
                        _buildCopyright(text1, name, text2, tech, text3, updateDoc),
                        const SizedBox(height: 24),
                        _buildSocials(githubUrl, linkedinUrl),
                        const SizedBox(height: 24),
                        if (onScrollToTop != null)
                          _buildBackToTop(onScrollToTop!),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left: Brand & Copyright
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 24,
                            runSpacing: 12,
                            children: [
                              _buildBrandWordmark(name),
                              Container(width: 1, height: 24, color: AppColors.hairline),
                              _buildCopyright(text1, name, text2, tech, text3, updateDoc),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right: Socials & Back to Top
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSocials(githubUrl, linkedinUrl),
                            const SizedBox(width: 32),
                            if (onScrollToTop != null)
                              _buildBackToTop(onScrollToTop!),
                          ],
                        ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandWordmark(String name) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          style: GoogleFonts.unbounded(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 4, top: 4),
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.amber,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyright(
    String text1,
    String name,
    String text2,
    String tech,
    String text3,
    Function(String, String) updateDoc,
  ) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        EditableTextWidget(
          text: text1,
          onSave: (v) => updateDoc('text1', v),
          style: GoogleFonts.interTight(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.2),
        ),
        EditableTextWidget(
          text: name,
          onSave: (v) => updateDoc('name', v),
          style: GoogleFonts.interTight(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 1.2),
        ),
        EditableTextWidget(
          text: text2,
          onSave: (v) => updateDoc('text2', v),
          style: GoogleFonts.interTight(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.2),
        ),
        EditableTextWidget(
          text: tech,
          onSave: (v) => updateDoc('tech', v),
          style: GoogleFonts.interTight(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.amber, letterSpacing: 1.2),
        ),
        EditableTextWidget(
          text: text3,
          onSave: (v) => updateDoc('text3', v),
          style: GoogleFonts.interTight(fontSize: 11, color: AppColors.textMuted, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildSocials(String githubUrl, String linkedinUrl) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _FooterLink(
          label: 'GITHUB',
          onTap: () async {
            final uri = Uri.parse(githubUrl);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
        ),
        const SizedBox(width: 16),
        _FooterLink(
          label: 'LINKEDIN',
          onTap: () async {
            final uri = Uri.parse(linkedinUrl);
            if (await canLaunchUrl(uri)) await launchUrl(uri);
          },
        ),
      ],
    );
  }

  Widget _buildBackToTop(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BACK TO TOP',
              style: GoogleFonts.interTight(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_upward, size: 12, color: AppColors.amber),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: GoogleFonts.interTight(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: _hovered ? AppColors.amber : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
