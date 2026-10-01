import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portfolio/theme/app_theme.dart';
import 'package:portfolio/widgets/scroll_reveal.dart';
import 'package:portfolio/widgets/editable_text.dart';
import 'package:portfolio/providers/app_providers.dart';

class AboutSection extends ConsumerWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 960;

    final contentAsync = ref.watch(contentProvider('about'));
    final data = contentAsync.value ?? {};

    final leftLabel = data['leftLabel'] ?? '01 / ABOUT';
    final leftEyebrow = data['leftEyebrow'] ?? 'DISCIPLINE & CRAFT';
    final leftDesc = data['leftDesc'] ??
        'Focused on structural clarity, deterministic state pipelines, and tactile human interfaces.';

    final title = data['title'] ?? 'ENGINEERING FLUIDITY & ARCHITECTURAL DISCIPLINE';
    final subtitle = data['subtitle'] ?? 'Bridging high-fidelity design systems with resilient multiplatform codebases.';
    final description = data['description'] ??
        'I am a Full Stack Flutter Developer passionate about engineering scalable, visually stunning, and responsive applications across iOS, Android, and Web.\n\n'
        'With deep expertise in the Flutter framework, state management (Riverpod), and modern backend services (Node.js, Express, Supabase, Firebase, and MongoDB), I architect solutions that bridge human-centric design with rock-solid reliability.\n\n'
        'Every project I craft adheres to clean architecture principles, testable code patterns, and pixel-perfect design fidelity.';

    final stat1Label = data['stat1Label'] ?? 'YEARS EXPERIENCE';
    final stat1Value = data['stat1Value'] ?? '02+';
    final stat2Label = data['stat2Label'] ?? 'PROJECTS DELIVERED';
    final stat2Value = data['stat2Value'] ?? '12+';
    final stat3Label = data['stat3Label'] ?? 'CROSS-PLATFORM STACKS';
    final stat3Value = data['stat3Value'] ?? '08+';

    void updateDoc(String key, String val) {
      ref.read(dbServiceProvider).updateContent('about', {key: val});
    }

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
                          _buildRightContent(
                            title,
                            subtitle,
                            description,
                            stat1Label,
                            stat1Value,
                            stat2Label,
                            stat2Value,
                            stat3Label,
                            stat3Value,
                            updateDoc,
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
                            height: 600,
                            color: AppColors.hairline,
                          ),
                          const SizedBox(width: 48),
                          // Right Content Column
                          Expanded(
                            child: _buildRightContent(
                              title,
                              subtitle,
                              description,
                              stat1Label,
                              stat1Value,
                              stat2Label,
                              stat2Value,
                              stat3Label,
                              stat3Value,
                              updateDoc,
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
    Function(String, String) updateDoc,
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

  Widget _buildRightContent(
    String title,
    String subtitle,
    String description,
    String stat1Label,
    String stat1Value,
    String stat2Label,
    String stat2Value,
    String stat3Label,
    String stat3Value,
    Function(String, String) updateDoc,
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
        const SizedBox(height: 36),
        EditableTextWidget(
          text: description,
          onSave: (val) => updateDoc('description', val),
          style: GoogleFonts.interTight(
            fontSize: isMobile ? 15 : 16.5,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
            height: 1.85,
          ),
        ),
        const SizedBox(height: 48),

        // Quick Facts / Architectural Metric Rows
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.hairline, width: 1),
              bottom: BorderSide(color: AppColors.hairline, width: 1),
            ),
          ),
          child: isMobile
              ? Column(
                  children: [
                    _FactItem(
                      value: stat1Value,
                      label: stat1Label,
                      onValSave: (v) => updateDoc('stat1Value', v),
                      onLabelSave: (v) => updateDoc('stat1Label', v),
                    ),
                    const Divider(color: AppColors.hairline, height: 32),
                    _FactItem(
                      value: stat2Value,
                      label: stat2Label,
                      onValSave: (v) => updateDoc('stat2Value', v),
                      onLabelSave: (v) => updateDoc('stat2Label', v),
                    ),
                    const Divider(color: AppColors.hairline, height: 32),
                    _FactItem(
                      value: stat3Value,
                      label: stat3Label,
                      onValSave: (v) => updateDoc('stat3Value', v),
                      onLabelSave: (v) => updateDoc('stat3Label', v),
                    ),
                  ],
                )
              : Row(
                  children: [
                    Expanded(
                      child: _FactItem(
                        value: stat1Value,
                        label: stat1Label,
                        onValSave: (v) => updateDoc('stat1Value', v),
                        onLabelSave: (v) => updateDoc('stat1Label', v),
                      ),
                    ),
                    Container(width: 1, height: 60, color: AppColors.hairline),
                    Expanded(
                      child: _FactItem(
                        value: stat2Value,
                        label: stat2Label,
                        onValSave: (v) => updateDoc('stat2Value', v),
                        onLabelSave: (v) => updateDoc('stat2Label', v),
                      ),
                    ),
                    Container(width: 1, height: 60, color: AppColors.hairline),
                    Expanded(
                      child: _FactItem(
                        value: stat3Value,
                        label: stat3Label,
                        onValSave: (v) => updateDoc('stat3Value', v),
                        onLabelSave: (v) => updateDoc('stat3Label', v),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _FactItem extends StatelessWidget {
  final String value;
  final String label;
  final Function(String) onValSave;
  final Function(String) onLabelSave;

  const _FactItem({
    required this.value,
    required this.label,
    required this.onValSave,
    required this.onLabelSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditableTextWidget(
          text: value,
          onSave: onValSave,
          style: GoogleFonts.unbounded(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.0,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        EditableTextWidget(
          text: label,
          onSave: onLabelSave,
          style: GoogleFonts.interTight(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
